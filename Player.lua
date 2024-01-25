if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))







ATM._players = {}
local function PlayersIndex(table, key)
    local player = ATM:newPlayer(key);
    if player then
        table[key] = player
    end
    return player
end
setmetatable(ATM._players, {
    __index = PlayersIndex,
    __mode = "k", --weak
});

function ATM:getPlayer(playerGUID, skipCreate)
    if not playerGUID or not ATM.starts_with(playerGUID, "Player-") then
        return nil
    end

    -- self:print("ATM:getPlayer", playerGUID)
    if skipCreate then
        return rawget(self._players, playerGUID)
    else
        return self._players[playerGUID]
    end
end

function ATM:newPlayer(playerGUID)
    local _, playerClass, _, playerRace, gender, playerName, server = GetPlayerInfoByGUID(playerGUID)
    self:print("[+player]", playerGUID, playerClass, playerName)

    if not self._player and self.me == playerGUID then
        playerClass = ({UnitClass("player")})[2]
        playerName = UnitName("player")
    end

    if not playerClass then
        ATM:print("[ATM] FAIL PLAYER CLASS", playerGUID, playerClass, playerName)
        -- This fails for enemy players, players not yet loaded, or players too far away
        return nil
    end

    local player = CreateFromMixins(ATM.Player, self.playerMixins[playerClass] or {})
    player:init()
    player:setGUID(playerGUID)
    player:setName(playerName)
    player:setRace(playerRace)
    player:setGender(gender)
    player:setServer(server)
    if playerGUID == self.me then
        player:scanTalents()
    end
    return player
end



local Player = CreateFromMixins(ATM.Unit, {
    color = "",
    inCombat = false,
    _isLocal = false,
    _equipment = {},
    _talents = {},
})


function Player:init()
    self._talents = {}
    self._equipment = {}
    self.globalThreat = {}
    self.globalThreatMod = {}

    self.threatBuffs = {}
    local function ThreatBuffsNewIndex(table, key, value)
        --Assign the key
        rawset(table, key, value)

        --Nil out our cached modifier so it's recalculated next call
        rawset(table, '__value', nil)
    end
    local function ThreatBuffsIndex(table, key)
        --Check for the cached value
        local mul = rawget(table, '__value')

        if not mul then
            mul = {}
            for name,threat in pairs(table) do
                for school,value in pairs(threat) do
                    local mask = 1
                    while mask <= school do
                        local isMask = bit.band(mask, school) > 0
                        if isMask then
                            mul[mask] = (mul[mask] or 1.0) * value
                        end
                        mask = bit.lshift(mask, 1)
                    end
                end
            end
            rawset(table, '__value', mul)
        end

        return mul[key] or 1.0
    end
    setmetatable(self.threatBuffs, {
        __newindex = ThreatBuffsNewIndex,
        __index = ThreatBuffsIndex,
        __mode = "k", --weak
    });
end

function Player:setGUID(guid)
    self.guid = guid
end
function Player:getGUID()
    return self.guid
end

function Player:setName(name)
    self.name = name
end
function Player:getName()
    return self.name
end

function Player:setRace(race)
    self.race = race
end
function Player:getRace()
    return self.race
end

function Player:setGender(gender)
    self.gender = gender
end
function Player:getGender()
    return self.gender
end

function Player:setServer(server)
    self.server = server
end
function Player:getServer()
    return self.server
end

function Player:setLevel(level)
    self.level = level
end
function Player:getLevel()
    return self.level
end


function Player:update()
    self:scanTalents()
    self:scanEquipment()
end

function Player:scanEquipment()
    if self._isLocal then
        for i = 0, 19 do
            local itemLink = GetInventoryItemLink("player", i)
            if itemLink then
                local itemId, enchantId = itemLink:match("item:(%d+):(%d-):")
                local engravingInfo = C_Engraving and C_Engraving.GetRuneForEquipmentSlot(i)
                local newData = {tonumber(itemId), tonumber(enchantId), tonumber(engravingInfo and engravingInfo.itemEnchantmentID)}

                if not self._equipment[i]
                or newData[1] ~= self._equipment[i][1]
                or newData[2] ~= self._equipment[i][2]
                or newData[3] ~= self._equipment[i][3]
                then
                    self.equipChange = ATM:GetTime()
                    self._equipment[i] = newData
                end
            end
        end
    end

    if self._equipment[15] and self._equipment[15][2] == 2621 then
        self.threatBuffs["Cloak - Subtlety"] = {[127] = 0.98}
    else
        self.threatBuffs["Cloak - Subtlety"] = nil
    end

    if self._equipment[10] and self._equipment[10][2] == 2613 then
        self.threatBuffs["Gloves - Threat"] = {[127] = 1.02}
    else
        self.threatBuffs["Gloves - Threat"] = nil
    end
end

function Player:serialize(oldestTransmit)
    local data = {}

    --All talents with points allocated
    if not self.talentsTime or self.talentsTime > oldestTransmit then
        data['T'] = {}
        for x = 1, 3 do
            for y = 1, 99 do
                local name, iconTexture, tier, column, rank, maxRank, isExceptional, available = GetTalentInfo(x, y)
                if not name then break end
                if rank and rank > 0 then
                    if not data['T'][x] then data['T'][x] = {} end
                    data['T'][x][y] = rank
                    -- print(x, y, rank)
                end
            end
        end
    end

    --Equipped items, enchants, and runes
    if not self.equipmentTime or self.equipmentTime > oldestTransmit then
        data['G'] = self._equipment
    end

    if self.classFields and (not self.classTime or self.classTime > oldestTransmit) then
        data['C'] = {}
        for field in pairs(self.classFields) do
            data['C'][field] = self[field]
        end
    end

    return data
end

function Player:deserialize(data)
    ATM:print("Player:deserialize", self:getName())
    self.lastReceived = ATM:GetTime()

    self._talents = {}
    for x,xd in pairs(data['T'] or {}) do
        self._talents[x] = {}
        for y,yd in pairs(xd) do
            -- print("Talent", x, y, yd)
            self._talents[x][y] = yd
        end
    end

    self._equipment = {}
    for slot,itemInfo in pairs(data['G'] or {}) do
        -- print("Equipped", slot, itemInfo[1], itemInfo[2], itemInfo[3])
        self._equipment[slot] = itemInfo
    end

    for field,value in pairs(data['C'] or {}) do
        if self.classFields[field] then
            self[field] = value
        end
    end

    self:update()
end

function Player:GetTalent(x,y)
    if self._isLocal then
        return select(5, GetTalentInfo(x, y))
    else
        return self._talents[x] and self._talents[x][y] or 0
    end
end

function Player:getCombat()
    return self.inCombat
end

function Player:setCombat(newCombat)
    if not newCombat and self.inCombat then
		self:wipeThreat()
    end
    self.inCombat = newCombat
end



function Player:getThreat(enemyGUID, skipCreate)
    if skipCreate then
        return rawget(ATM._threat[self.guid], enemyGUID) or -1
    else
        return ATM._threat[self.guid][enemyGUID]
    end
end

function Player:addThreat(amount, enemyGUID)
    if C.debug then
        ATM:print(self.currentEvent.." T:"..tostring(amount).." E:"..(enemyGUID or "GLOBAL"))
    end
    self:_addThreat(amount, enemyGUID)
end

function Player:_addThreat(amount, enemyGUID)
    if enemyGUID then
        self.lastUpdate = ATM:GetTime()
        
        local newThreat = ATM._threat[self.guid][enemyGUID] + amount

        if newThreat > ATM._highest[self.guid] then
            ATM._highest[self.guid] = newThreat
        end
        if newThreat > ATM._highest[enemyGUID] then
            ATM._highest[enemyGUID] = newThreat
        end

        ATM._threat[self.guid][enemyGUID] = newThreat
        ATM._threat[enemyGUID][self.guid] = newThreat

        local enemy = ATM:getEnemy(enemyGUID)
        if enemy and enemy.tankGUID == self.guid then
            enemy.tankThreat = newThreat
        end
    else
        -- threat is divided amongst linked enemies (support = very hard; need to track via global threat discrepencies between API updates)
        for enemyGUID,enemy in ATM:enemiesInCombat() do
            --Only add global threat if target is NOT CC'd
            if not enemy.isCC then
                --track amount of global threat added between api syncs
                if amount > 0 then --neg threat isn't split
                    amount = amount * (self.globalThreatMod[enemyGUID] or 1)
                    self.globalThreat[enemyGUID] = (self.globalThreat[enemyGUID] or 0) + amount
                end

                local newThreat = ATM._threat[self.guid][enemyGUID] + amount
                if newThreat > ATM._highest[self.guid] then
                    ATM._highest[self.guid] = newThreat
                end
                if newThreat > ATM._highest[enemyGUID] then
                    ATM._highest[enemyGUID] = newThreat
                end

                ATM._threat[self.guid][enemyGUID] = newThreat
                ATM._threat[enemyGUID][self.guid] = newThreat

                local enemy = ATM:getEnemy(enemyGUID)
                if enemy and enemy.tankGUID == self.guid then
                    enemy.tankThreat = newThreat
                end
            end
        end
    end
end


function Player:setThreat(amount, enemyGUID)
    ATM._threat[self.guid][enemyGUID] = amount
    ATM._threat[enemyGUID][self.guid] = amount
    ATM._highest[self.guid] = nil
    ATM._highest[enemyGUID] = nil

    if amount == nil then
        self.globalThreatMod[enemyGUID] = nil
        self.globalThreat[enemyGUID] = nil
    end

    local enemy = ATM:getEnemy(enemyGUID)
    if enemy and enemy.tankGUID == self.guid then
        enemy.tankThreat = amount
    end
end

function Player:wipeThreat()
    ATM:print("Player:wipeThreat", self.name)
    for enemyGUID,_ in ATM:enemiesInCombat() do
        ATM._threat[self.guid][enemyGUID] = nil
        ATM._threat[enemyGUID][self.guid] = nil
        ATM._highest[self.guid] = nil
        ATM._highest[enemyGUID] = nil
    end
    self.globalThreatMod = {}
    self.globalThreat = {}
end

function Player:UpdateThreat(destUnit)
    local destGUID = UnitGUID(destUnit)
    if not destGUID then return end

    local selfUnit = ATM:PlayerGUIDToUnit(self.guid)
    if not selfUnit then return end

	local isTanking, status, threatpct, rawthreatpct, threatvalue = UnitDetailedThreatSituation(selfUnit, destUnit)
	if threatvalue then
        local enemy = ATM:getEnemy(destGUID)
        if enemy and not enemy.seenAPI and threatvalue > 0 then
            enemy.seenAPI = true
        end
        enemy:setCombat(true, true)
        
        if isTanking then
            enemy.tankGUID = self.guid
        end
        
        local newThreat = threatvalue/100
        local oldThreat = self:getThreat(destGUID)
        local mismatch = (newThreat - oldThreat)

		--If we have updated our threat the same frame as a threat update ignore API sync
		--This is required because events are processed in reverse order (combat log events before threat event)
		if self.lastUpdate == ATM:GetTime() then
			ATM:print("Ignoring same frame threat update for", self:getName(), mismatch, newThreat, oldThreat)
			return
		end

        if oldThreat > 0 and newThreat > 0 and mismatch > 0.02 or mismatch < -0.02 then
            local globalThreatSinceLast = self.globalThreat[destGUID] or 0

            -- only split threat if we have done global threat recently
            if globalThreatSinceLast > 0 then
                -- local globalThreatMod = (globalThreatSinceLast + mismatch) / globalThreatSinceLast * (self.globalThreatMod[destGUID] or 1)

                -- local numInCombat = math.floor(1/globalThreatMod+0.1)/1
                -- if numInCombat > 20 then numInCombat = 20 end
                -- if numInCombat < 1 then numInCombat = 1 end
                -- ATM:print("splitting between num enemies", 1/globalThreatMod, numInCombat)
                -- self.globalThreatMod[destGUID] = 1/numInCombat
            elseif C.debug then
				print("|cffFF0000[ATM] Threat API mismatch|r", mismatch, oldThreat, newThreat)
			end
		end

        self.globalThreat[destGUID] = 0
		self:setThreat(newThreat, destGUID)
	end
end

function Player.levelBasedThreat(baseThreat, perLevelThreat, minLevel, maxLevel)
    return function(self)
        if self and self.level then
            return baseThreat + ((math.min(self.level, maxLevel) - minLevel) * perLevelThreat)
        else
            return baseThreat + ((maxLevel - minLevel) * perLevelThreat)
        end
    end
end

-- Classes should override these
function Player:scanTalents() end

ATM.Player = Player




function Player:SWING_DAMAGE(...)
    local destGUID = select(8, ...)
	local amount = select(12, ...)

    if C.debug then
        self.currentEvent = self.currentEvent.." R:"..tostring(amount).." M:"..tostring(self.threatBuffs[1])
    end
    amount = amount * self.threatBuffs[1]

    self:setCombat(true)
    local enemy = ATM:getEnemy(destGUID)
    if enemy then
        enemy:setCombat(true)
    end
    self:addThreat(amount, destGUID)
end

function Player:RANGE_DAMAGE(...)
    local destGUID = select(8, ...)
	local amount = select(15, ...)
    
    if C.debug then
        self.currentEvent = self.currentEvent.." R:"..tostring(amount).." M:"..tostring(self.threatBuffs[1])
    end
    amount = amount * self.threatBuffs[1]
    
    self:setCombat(true)
    local enemy = ATM:getEnemy(destGUID)
    if enemy then
        enemy:setCombat(true)
    end
    self:addThreat(amount, destGUID)
end


function Player:SPELL_CAST_SUCCESS(...)
    local spellID, spellName = select(12, ...)

    --Checking if we care about the spell
    local spellData = ATM.spells[spellName]
	if spellData and spellData.onCast then
        local timestamp, subevent, spellSchool, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _ = ...
        -- ATM:print("SPELL_CAST_SUCCESS", timestamp, spellName)

        local threat = spellData.threat * self.threatBuffs[spellSchool]
        if spellData.threatMod then
            if type(spellData.threatMod) == "function" then
                threat = threat * spellData.threatMod(self)
            else
                threat = threat * spellData.threatMod
            end
        end

        if bit.band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then
            self:addThreat(threat)
        else
            local enemy = ATM:getEnemy(destGUID)
            if not enemy then
                return print("[ATM] Bad enemy", spellName, sourceName, destName, destGUID)
            end
            enemy:setCombat(true)
            self:addThreat(threat, destGUID)
        end
        return
    end
end

function Player:SPELL_MISSED(...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID, spellName = ...
    
    local enemy = ATM:getEnemy(destGUID)
    if enemy then
        enemy:setCombat(true)
    end

    local spellData = ATM.spells[spellID]
    if spellData and spellData.onCast then
        local threat = spellData.threat * self.threatBuffs[spellSchool]
        if spellData.threatMod then
            if type(spellData.threatMod) == "function" then
                threat = threat * spellData.threatMod(self)
            else
                threat = threat * spellData.threatMod
            end
        end

        if bit.band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then
            self:addThreat(-threat) --can this happen?
        else
            self:addThreat(-threat, destGUID)
        end
    end
end


function Player:SPELL_DAMAGE(...)
	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
	local spellID, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)

    if C.debug then
        self.currentEvent = self.currentEvent.." R:"..tostring(amount)
    end
    local threat = amount
    local spellData = ATM.spells[spellID]
    if spellData then
        if spellData.onDamage and spellData.threat then
            threat = threat + spellData.threat
        end
        if spellData.threatMod then
            if type(spellData.threatMod) == "function" then
                threat = threat * spellData.threatMod(self)
            else
                threat = threat * spellData.threatMod
            end
        end
    end
    
    local schoolThreatMod = self.threatBuffs[spellSchool]
    threat = threat * schoolThreatMod
    if C.debug and schoolThreatMod ~= 1.0 then
        self.currentEvent = self.currentEvent.." M:"..tostring(schoolThreatMod)
    end
    

    self:setCombat(true)
    local player = ATM:getEnemy(destGUID)
    if player then
        player:setCombat(true)
    end
    
    self:addThreat(threat, destGUID)
end
Player.SPELL_PERIODIC_DAMAGE = Player.SPELL_DAMAGE
Player.DAMAGE_SHIELD = Player.SPELL_DAMAGE


function Player:SPELL_HEAL(...)
	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID, spellName, spellSchool, amount, overhealing, absorbed, critical = ...

    -- Only care about healing done to friendlies
    if bit.band(destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) == 0 then
        return
    end

    if C.debug then
        self.currentEvent = self.currentEvent.." R:"..tostring(amount-overhealing)
    end
    
    local threat = (amount-overhealing) / 2.0
    
    local spellData = ATM.spells[spellID]
    if spellData then
        -- Ignore healing done from leech spells
        if spellData.isLeech then return end

        local t = type(spellData.threatMod)
        if t == "number" then
            threat = threat * spellData.threatMod
            if C.debug then
                self.currentEvent = self.currentEvent.." S:"..tostring(spellData.threatMod)
            end
        elseif t == "function" then
            threat = threat * spellData.threatMod(self)
            if C.debug then
                self.currentEvent = self.currentEvent.." S:"..tostring(spellData.threatMod(self))
            end
        end
    end

    local schoolThreatMod = self.threatBuffs[spellSchool]
    threat = threat * schoolThreatMod
    if C.debug and schoolThreatMod ~= 1.0 then
        self.currentEvent = self.currentEvent.." M:"..tostring(schoolThreatMod)
    end


    local player = ATM:getPlayer(destGUID)
    if player and player:getCombat() then
        self:setCombat(true)
    end
	self:addThreat(threat)
end
Player.SPELL_PERIODIC_HEAL = Player.SPELL_HEAL


function Player:SPELL_ENERGIZE(...)
    local spellID, spellName, spellSchool, amount, _, powerType = select(12, ...)
    -- print("SPELL_ENERGIZE", spellID, spellName, spellSchool, amount, powerType)

    if powerType == ATM.PowerType.Mana then
        self:addThreat(amount * 0.5)
    elseif powerType == ATM.PowerType.Rage then
        if spellID == 29131 then --bloodrage ticks
            self:addThreat(amount * 5.0 * self.threatBuffs[spellSchool])
        else
            self:addThreat(amount * 5.0)
        end
    elseif powerType == ATM.PowerType.Energy then
        self:addThreat(amount * 5.0)
    end
end
Player.SPELL_PERIODIC_ENERGIZE = Player.SPELL_ENERGIZE


function Player:AURA_THREAT(...)
	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
    local spellID, spellName, spellSchool, auraType, amount = select(12, ...)

    local spellData = ATM.spells[spellID]
    -- If this ability doesn't generate threat just ignore
    if not spellData or (not spellData.onBuff and not spellData.onDebuff) then
        return
    end

    local enemy = ATM:getEnemy(destGUID)
    if enemy and spellData.isCC then
        enemy:setCC(spellName, true)
    end
    
    if enemy and auraType == "DEBUFF" then
        enemy:setCombat(true)
    end


    -- ATM:print("AURA_THREAT", spellName, spellID)
    local threat = spellData.threat
    local t = type(spellData.threatMod)
    if t == "number" then
        threat = threat * spellData.threatMod
        if C.debug then
            self.currentEvent = self.currentEvent.." S:"..tostring(spellData.threatMod)
        end
    elseif t == "function" then
        threat = threat * spellData.threatMod(self)
    end

    local schoolThreatMod = self.threatBuffs[spellSchool]
    threat = threat * schoolThreatMod
    if C.debug and schoolThreatMod ~= 1.0 then
        self.currentEvent = self.currentEvent.." M:"..tostring(schoolThreatMod)
    end


    if auraType == "BUFF" then
        if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
            if not self:getCombat() and ATM:getPlayer(destGUID):getCombat() then
                self:setCombat(true)
            end
        end
        self:addThreat(threat)
    elseif auraType == "DEBUFF" then
        self:setCombat(true)
        self:addThreat(threat, destGUID)
    end
end
Player.SPELL_AURA_APPLIED = Player.AURA_THREAT
Player.SPELL_AURA_REFRESH = Player.AURA_THREAT


function Player:SPELL_AURA_REMOVED(...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
    local spellID, spellName = select(12, ...)

    local spellData = ATM.spells[spellID]
    if not spellData or not spellData.isCC then return end
    
    if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_NPC) > 0 then
        local enemy = ATM:getEnemy(destGUID)
        enemy:setCC(spellName, false)
        enemy.lastThreatUpdate = ATM:GetTime() --ignore threat updates while still CC'd
    end
end
