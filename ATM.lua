if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))

ATM.spells = {}
ATM.playerMixins = {}


ATM.frame = CreateFrame("Frame")
ATM.frame:SetScript("OnEvent", function(self, event, ...)
	-- print(event)
	return ATM[event] and ATM[event](ATM, ...)
end)


ATM.frame:RegisterEvent("PLAYER_LOGIN")
function ATM:PLAYER_LOGIN()
	self.PowerType = {}
	for k,v in pairs(Enum.PowerType) do
		self.PowerType[k] = v
	end

	self.me = UnitGUID("player")

	self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.frame:RegisterEvent("GROUP_ROSTER_UPDATE")
	self.frame:RegisterEvent("UNIT_LEVEL")

	-- Track events that require us to transmit self
	self.frame:RegisterEvent("CHARACTER_POINTS_CHANGED")
	self.frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	if C_EventUtils.IsEventValid("RUNE_UPDATED") then
		self.frame:RegisterEvent("RUNE_UPDATED");
	end
	self.frame:RegisterEvent("GROUP_JOINED")

	-- For handling threat and enemy combat scanning
	self.frame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")

	self.frame:RegisterEvent("PLAYER_TARGET_CHANGED")
	self.frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	self.frame:RegisterEvent("UNIT_TARGET")

	self.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.CombatLogger.OnInitialize()


	self.frame:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end

function ATM:PLAYER_ENTERING_WORLD()
	local player = self:player()
	if player then
		player:update()
	end

	if C.enabled then
		self.CombatLogger:Enable()
	else
		self.CombatLogger:Disable()
	end

	self:TransmitSelf()
end


ATM._highest = {}
local function HighestIndex(table, key)
    local highestThreat = -1

	for guid,threat in pairs(ATM._threat[key]) do
		if threat > highestThreat then
			highestThreat = threat
		end
	end

    table[key] = highestThreat
    return highestThreat
end
setmetatable(ATM._highest, {
    __index = HighestIndex,
    __mode = "k", --weak
});

ATM._threat = {}
local function ThreatThreatIndex(table, key)
    local var = 0
	rawset(table, key, var)
    return var
end
local function ThreatIndex(table, key)
    local var = {}
	setmetatable(var, {
		__index = ThreatThreatIndex,
		__mode = "k", --weak
	});
    table[key] = var
    return var
end
setmetatable(ATM._threat, {
    __index = ThreatIndex,
    __mode = "k", --weak
});


ATM._startTime = GetServerTime()
ATM.frame.currentTime = GetTime()
ATM.frame:SetScript("OnUpdate", function(self, elapsed)
	self.currentTime = self.currentTime+elapsed
end)
function ATM:GetTime()
	return self.frame.currentTime
end

function ATM:player()
	if self._player then
		return self._player
	else
		self._player = self:getPlayer(UnitGUID("player"))
		if not self._player then return end
		self._player._isLocal = true
		self._player.unit = "player"
		self._player:init() --reinit hack todo
		return self._player
	end
end

-- We want to pre-create players
ATM.groupUnits = {}
function ATM:GROUP_ROSTER_UPDATE()
	self.groupUnits = {}
	if IsInRaid() then
		for i=1, GetNumGroupMembers() do
			local n = "raid"..i
			local p = self:getPlayer(UnitGUID(n))
			if p then
				p.unit = n
				self.groupUnits[n] = p
			end
		end
	elseif IsInGroup() then
		for i=1, GetNumGroupMembers()-1 do
			local n = "party"..i
			local p = self:getPlayer(UnitGUID(n))
			if p then
				p.unit = n
				self.groupUnits[n] = p
			end
		end
	end
end

function ATM:UNIT_LEVEL(unit)
	-- print("ATM:UNIT_LEVEL")
	local player = self:getPlayer(UnitGUID(unit))
	if player then
		player:setLevel(UnitLevel(unit))
	end
end



-------------------
-- Communication --
-------------------

function ATM:CHARACTER_POINTS_CHANGED()
	self:player():update()

	self.talentsTime = GetServerTime(); --always transmit

	self:TransmitSelf()
end

function ATM:PLAYER_EQUIPMENT_CHANGED()
	if InCombatLockdown() then return end

	self:player():update()
	if self:player().equipChange < self:GetTime() then return end

	self:TransmitSelf()
end
ATM.RUNE_UPDATED = ATM.PLAYER_EQUIPMENT_CHANGED

function ATM:GROUP_JOINED()
	self:TransmitSelf()
end



function ATM:TransmitSelf(dontReset)
	if self.transmitSelfTimer then
		if dontReset then return end
		self.transmitSelfTimer:Cancel()
	end
	self.transmitSelfTimer = C_Timer.NewTimer(3, function()
		self.transmitSelfTimer = nil
		self:_TransmitSelf()
	end)
end


local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local Comm = LibStub:GetLibrary("AceComm-3.0")
local function TableToString(inTable)
	local serialized = LibSerialize:SerializeEx({ errorOnUnserializableType = false }, inTable)
	local compressed = LibDeflate:CompressDeflate(serialized, { level = 9 })
	local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
	return encoded
end

local function StringToTable(inString)
	local compressed = LibDeflate:DecodeForWoWAddonChannel(inString)
	local serialized = LibDeflate:DecompressDeflate(compressed)
	local success, decoded = LibSerialize:Deserialize(serialized)
	return decoded
end

function ATM:_TransmitSelf()
	if not IsInRaid() and not IsInGroup() then
		return
	end

	local inInstance, kind = IsInInstance()
	if inInstance and (kind == "pvp" or kind == "arena") then
		return
	end

	local oldestTransmit = GetServerTime()
	local now = GetServerTime()
	if IsInRaid() then
		for i=1, GetNumGroupMembers() do
			local p = self:getPlayer(UnitGUID("raid"..i))
			if p then
				if p.lastTransmit and p.lastTransmit < oldestTransmit then
					oldestTransmit = p.lastTransmit
				end
				p.lastTransmit = now
			end
		end
	elseif IsInGroup() then
		for i=1, GetNumGroupMembers()-1 do
			local p = self:getPlayer(UnitGUID("party"..i))
			if p then
				if p.lastTransmit and p.lastTransmit < oldestTransmit then
					oldestTransmit = p.lastTransmit
				end
				p.lastTransmit = now
			end
		end
	end

	local data = self:player():serialize(oldestTransmit)
	data['CMD'] = "SELF"
	data['VER'] = C.VERSION
	data['TIME'] = self._startTime
	local transmitString = TableToString(data);
	Comm:SendCommMessage(C.PREFIX, transmitString, IsInRaid() and "RAID" or "PARTY")
end

Comm:RegisterComm(C.PREFIX, function(prefix, message, distribution, sender)
	ATM:print("ATM Received", sender, #message)

	local data = StringToTable(message)
	if not data then
		return ATM:print("DESERIALIZE FAILED")
	end
	-- ATM:print(DevTools_Dump(data))

	
	local player = ATM:getPlayer(UnitGUID(sender))
	if not player then return end --This should never happen but better safe than sorry

	local version = data['VER']
	player.version = version
	if version < C.MINVER then return end
	if version > C.VERSION and not ATM.updateNag then
		print("[ATM] You are using an outdated version of AccurateThreatMeter. Please update.")
		ATM.updateNag = true
	end

	local cmd = data['CMD']
	if cmd == "SELF" then
		if not player._isLocal then
			local startTime = data['TIME']
			if not player.lastTransmit or player.lastTransmit < startTime then
				ATM:TransmitSelf(true)
			end

			player:deserialize(data)
		end
	end
end)



------------------
-- GUID to Unit --
------------------

function ATM:PlayerGUIDToUnit(playerGUID)
	local player = self:getPlayer(playerGUID)
	if not player then return end

	if not player.unit or UnitGUID(player.unit) ~= player.guid then
		player.unit = self:_PlayerGUIDToUnit(playerGUID)
	end

	return player.unit
end

function ATM:_PlayerGUIDToUnit(playerGUID)
	-- if true then return end
	local function check(t)
		return UnitGUID(t) == playerGUID
	end

	local t = "player"
	if check(t) then return t end

	if IsInRaid() then
		for i=1, GetNumGroupMembers() do
			local t = "raid"..i
			if check(t) then return t end
		end
	elseif IsInGroup() then
		for i=1, GetNumGroupMembers()-1 do
			local t = "party"..i
			if check(t) then return t end
		end
	end
	for i=1,40 do
		local t = "nameplate"..i
		if check(t) then return t end
	end


	-- If we got this far hope someone or something nearby is targetting
	if IsInRaid() then
		for i=1, GetNumGroupMembers() do
			local t = "raid"..i.."target"
			if check(t) then return t end
		end
	elseif IsInGroup() then
		for i=1, GetNumGroupMembers()-1 do
			local t = "party"..i.."target"
			if check(t) then return t end
		end
	end
	for i=1,40 do
		local t = "nameplate"..i.."target"
		if check(t) then return t end
	end

	
	-- One last hail mary
	if IsInRaid() then
		for i=1, GetNumGroupMembers() do
			local t = "raid"..i.."targettarget"
			if check(t) then return t end
		end
	elseif IsInGroup() then
		for i=1, GetNumGroupMembers()-1 do
			local t = "party"..i.."targettarget"
			if check(t) then return t end
		end
	end
	for i=1,40 do
		local t = "nameplate"..i.."targettarget"
		if check(t) then return t end
	end
end


function ATM:EnemyGUIDToTarget(enemyGUID, checkPets)
	local enemy = self:getEnemy(enemyGUID)
	if not enemy then return end

	if not enemy.unit or UnitGUID(enemy.unit) ~= enemy.guid then
		enemy.unit = self:_EnemyGUIDToTarget(enemyGUID, checkPets)
	end

	if enemy.unit and not enemy.name then
		enemy.name = UnitName(enemy.unit)
	end

	return enemy.unit
end

function ATM:_EnemyGUIDToTarget(enemyGUID, checkPets)
	-- if true then return end
	local function check(t)
		return UnitGUID(t) == enemyGUID
	end

	local t = "playertarget"
	if check(t) then return t end
			
	if checkPets then
		local t = "playerpet"
		if check(t) then return t end
		
		local t = "playerpettarget"
		if check(t) then return t end
	end


	for i=1,40 do
		local t = "nameplate"..i
		if check(t) then return t end
	end


	-- If we got this far hope someone or something nearby is targetting
	if IsInRaid() then
		for i=1, GetNumGroupMembers() do
			local t = "raid"..i.."target"
			if check(t) then return t end
			
			if checkPets then
				local t = "raid"..i.."pet"
				if check(t) then return t end
				
				local t = "raid"..i.."pettarget"
				if check(t) then return t end
			end
		end
	elseif IsInGroup() then
		for i=1, GetNumGroupMembers()-1 do
			local t = "party"..i.."target"
			if check(t) then return t end
			
			if checkPets then
				local t = "party"..i.."pet"
				if check(t) then return t end
				
				local t = "party"..i.."pettarget"
				if check(t) then return t end
			end
		end
	end
	for i=1,40 do
		local t = "nameplate"..i.."target"
		if check(t) then return t end
	end

	
	-- One last hail mary
	if IsInRaid() then
		for i=1, GetNumGroupMembers() do
			local t = "raid"..i.."targettarget"
			if check(t) then return t end
		end
	elseif IsInGroup() then
		for i=1, GetNumGroupMembers()-1 do
			local t = "party"..i.."targettarget"
			if check(t) then return t end
		end
	end
	for i=1,40 do
		local t = "nameplate"..i.."targettarget"
		if check(t) then return t end
	end
end



------------------
-- Helper Funcs --
------------------

function ATM:MarkDead(timestamp, destGUID)
	-- print("ATM:MarkDead", timestamp, destGUID)

	C_Timer.After(0.1, function()
		ATM:wipeThreat(destGUID)
	end)
end


--[[-------------------------------------------

Handle entering and dropping combat

--]]-------------------------------------------

function ATM:PLAYER_REGEN_DISABLED()
	ATM:print("++combat++")
	self.inCombat = true
	
	self:scanTargets()
end

function ATM:PLAYER_REGEN_ENABLED()
	ATM:print("---combat---")

	-- Sometimes combat drops for a moment, use a timer
	C_Timer.After(0.1, function()
		self:DropCombat()
	end)

	self:scanTargets()
end

function ATM:DropCombat()
	-- check if we actually dropped combat
	if InCombatLockdown() then
		return
	end

	self.inCombat = false
	self:player():wipeThreat()

	self:scanTargets()
end

-- Called when an NPC fails UnitAffectingCombat or dies
function ATM:wipeThreat(enemyGUID)
	ATM:print("ATM:wipeThreat", enemyGUID)
	for playerGUID, player in pairs(self._players) do
		player:setThreat(nil, enemyGUID)
	end
	self._threat[enemyGUID] = nil
end



--[[-------------------------------------------
Scan targets and nameplates to identify NPCs combat status. There are no events fired when an NPC
initially aggro's a player except for checking if they are targetting a friendly player.

A unit can be aggro'd and have a target but not have UnitAffectingCombat set
--]]-------------------------------------------

function ATM:PLAYER_TARGET_CHANGED()
	self:checkTargetStatus("target")
end

function ATM:UPDATE_MOUSEOVER_UNIT()
	self:checkTargetStatus("mouseover")
	self:checkTargetStatus("mouseovertarget")
end

function ATM:UNIT_TARGET(unit)
	self:checkTargetStatus(unit)
	self:checkTargetStatus(unit.."target")
end
ATM.NAME_PLATE_UNIT_ADDED = ATM.UNIT_TARGET

function ATM:scanTargets()
	-- if IsInRaid() then
	-- 	for i=1, GetNumGroupMembers() do
	-- 		self:checkTargetStatus("raid"..i)
	-- 	end
	-- elseif IsInGroup() then
	-- 	for i=1, GetNumGroupMembers()-1 do
	-- 		self:checkTargetStatus("party"..i)
	-- 	end
	-- end

	-- for i=1,40 do
	-- 	--Be greedy and also check nameplate targets
	-- 	local t = "nameplate"..i
	-- 	self:checkTargetStatus(t)
	-- 	self:checkTargetStatus(t.."target")
	-- end
	-- for _, frame in pairs(C_NamePlate.GetNamePlates(issecure())) do
	-- 	self:checkTargetStatus(frame.namePlateUnitToken)
	-- 	self:checkTargetStatus(frame.namePlateUnitToken.."target")
	-- end
end

function ATM:checkTargetStatus(t)
	-- We don't need UnitExists(t) because other checks will return false if target doesn't exist
	-- UnitIsPlayer(t) and UnitIsOtherPlayersPet(t) can be marged into a single UnitCanCooperate check
	-- UnitCanCooperate seems to returns true for all friendly NPCs

	if UnitIsPlayer(t) then
		local player = ATM:getPlayer(t)
		if player then
			player:setCombat(UnitAffectingCombat(t))
		end

		t = t.."target"
	end
	
	if UnitCanAttack("player", t) then
		local enemy = self:getEnemy(UnitGUID(t))
		if enemy then
			enemy:setCombat(UnitAffectingCombat(t) or UnitCanCooperate("player", t.."target"))
		end
	end
end



--Return all enemies where combat=true
function ATM:enemiesInCombat()
	local k,e = nil,nil
	return function()
		while true do
			k,e = next(self._enemies, k)
			if not k then
				return
			elseif e.isCombat then
				return k, e
			end
		end
	end
end

function ATM:numEnemiesInCombat()
	local i=0
	for _,_ in self:enemiesInCombat() do
		i=i+1
	end
	return i
end

function ATM:playersInCombat(destUnit, destGUID)
	local enemy = self:getEnemy(destGUID or UnitGUID(destUnit), true)
	if not enemy then return end

	local out = {}
	for guid,threat in pairs(self._threat[enemy.guid]) do
		out[self:getPlayer(guid):getName()] = threat
	end
	return out
end

function ATM:highestThreat(destUnit, destGUID)
	local enemy = self:getEnemy(destGUID or UnitGUID(destUnit), true)
	if not enemy then return end

	local highestThreat,highestGUID = 0,""
	for guid,threat in pairs(self._threat[enemy.guid]) do
		if threat > highestThreat then
			highestThreat = threat
			highestGUID = guid
		end
	end
	return highestThreat, highestGUID
end


function ATM:getTank(enemyUnit)
	local enemyGUID = UnitGUID(enemyUnit)
	local enemy = ATM:getEnemy(enemyGUID)
	if not enemy or not enemy.tankGUID then return end
	return ATM:getPlayer(enemy.tankGUID)
end

local function findTank(enemyUnit)
	local enemyGUID = UnitGUID(enemyUnit)
	local enemy = ATM:getEnemy(enemyGUID)
	if not enemy.tankGUID then
		local isTanking, status, threatpct, rawthreatpct, threatvalue = UnitDetailedThreatSituation(enemyUnit.."target", enemyUnit)
		if isTanking then
			enemy.tankGUID = UnitGUID(enemyUnit.."target")
			enemy.tankThreat = threatvalue / 100
			return
		end

		for playerUnit in pairs(ATM.groupUnits) do
			isTanking = UnitDetailedThreatSituation(playerUnit, enemyUnit)
			if isTanking then
				enemy.tankGUID = UnitGUID(playerUnit)
				enemy.tankThreat = ATM:getPlayer(UnitGUID(playerUnit)):getThreat(enemyGUID)
				return
			end
		end
	end
end

function ATM:UNIT_THREAT_LIST_UPDATE(destUnit)
	local destGUID = UnitGUID(destUnit)
	local enemy = self:getEnemy(destGUID)
	if not enemy then return end

	if enemy.lastThreatUpdate == ATM:GetTime() then return end
	enemy.lastThreatUpdate = ATM:GetTime()

	--scan for tank changes
	if enemy.tankGUID then
		local tankUnit = self:PlayerGUIDToUnit(enemy.tankGUID)
		if not tankUnit then
			tankUnit = destUnit.."target"
		end
		local isTanking, status, threatpct, rawthreatpct, threatvalue = UnitDetailedThreatSituation(tankUnit, destUnit)
		if not isTanking then
			enemy.tankGUID = nil
			enemy.tankThreat = nil
			--ignore threat updates triggered by isTanking change
			findTank(destUnit)
			return
		end
		if not ATM:getPlayer(UnitGUID(destUnit)) then
			enemy.tankThreat = threatvalue / 100 --use API for NPCs
		end
	else
		findTank(destUnit)
	end

	for guid,player in pairs(self._players) do
		player:UpdateThreat(destUnit)
	end
end


function ATM:UnitDetailedThreatSituation(sourceUnit, destUnit)
	local isTanking, status, threatpct, rawthreatpct, threatvalue = UnitDetailedThreatSituation(sourceUnit, destUnit)
	if threatpct == 100 then rawthreatpct = 100 end

	local enemyGUID = UnitGUID(destUnit)
	local enemy = self:getEnemy(enemyGUID)
	local player = self:getPlayer(UnitGUID(sourceUnit))
	if enemy and player then
		threatvalue = player:getThreat(enemyGUID, true)
		if threatvalue > 0 then
			local tankThreat = enemy.tankThreat
			if not tankThreat then
				tankThreat = self._highest[enemyGUID]
			end
			
			if tankThreat > 0 then
				local pullMultiplier = (rawthreatpct or 100)/(threatpct or 100)
				rawthreatpct = threatvalue / tankThreat
				threatpct = rawthreatpct * pullMultiplier
			end
		end
	end

	return isTanking, status, threatpct, rawthreatpct, threatvalue > -1 and threatvalue or nil
end



ATM.tooltip = CreateFrame("GameTooltip", "ATMTooltip", nil, "GameTooltipTemplate")

--[[-------------------------------------------

Really basic options

--]]-------------------------------------------
ATM.SlashCmds = {
	["debug"] = {
		"enable debug mode",
		function()
			ATM:EnableDebug()
		end
	},
	
	["enable"] = {
		"enable threat meter",
		function()
			if not C.enabled then
				C.enabled = true
				ATM.CombatLogger:Enable()
			end
		end
	},
	["disable"] = {
		"disable threat meter",
		function()
			if C.enabled then
				C.enabled = false
				ATM.CombatLogger:Disable()
			end
		end
	},
	
	["help"] = {
		"print this",
		function()
			print("Accurate Threat Meter v"..ATM.version)
			for key,data in pairs(ATM.SlashCmds) do
				print(" "..key..": "..data[1])
			end
		end
	},
}
SlashCmdList['ATM_SLASHCMD'] = function(arg)
	local f = ATM.SlashCmds[strsplit(' ', arg)]
	if f then
		f[2]()
	else
		ATM.SlashCmds["help"][2]()
		if (#arg > 0) then
			print("Unknown command:", arg)
		end
	end
end
SLASH_ATM_SLASHCMD1 = '/ATM'
SLASH_ATM_SLASHCMD1 = '/atm'


function ATM:EnableDebug()
	print("[ATM] Debug mode enabled")
	C.debug = true

	for i = 1, NUM_CHAT_WINDOWS do
		local cf = getglobal("ChatFrame"..i)
		if cf and cf.name == "ATM" then
			ATM.debugChatFrame = cf
		end
    end
    if not ATM.debugChatFrame then
		ATM.print = function (self, ...)
			print(...)
		end
	else
		ATM.print = function (self, ...)
			local args = {...}
			for k,v in ipairs(args) do
				args[k] = tostring(v) or "nil"
			end
			ATM.debugChatFrame:AddMessage(table.concat(args, " "))
		end
	end
end

if C.debug then
	ATM:EnableDebug()
else
	ATM.print = function() end
end
