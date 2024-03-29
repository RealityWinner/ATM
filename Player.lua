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


ATM.BuffThreatMod = function(threatMod)
    return function(self, ...)
        local subevent = select(2, ...)
        local spellID, spellName = select(12, ...)
        if subevent == "SPELL_AURA_APPLIED" then
            self.threatBuffs[spellName] = threatMod
        end
        if subevent == "SPELL_AURA_REMOVED" then
            self.threatBuffs[spellName] = nil
        end
    end
end

ATM.TemporaryThreat = function(self, ...)
    local subevent = select(2, ...)
    local spellID = select(12, ...)
    
    local threat = ATM.spellThreat[spellID]
    if type(threat) == "function" then
        threat = threat(self)
    end
    if not threat then return end

    --TODO: reduce to 0, add back amount reduced when expired
    if subevent == "SPELL_AURA_APPLIED" then
        self:addThreat(threat)
    elseif subevent == "SPELL_AURA_REMOVED" then
        self:addThreat(-threat)
    end
end



local Player = {
    color = "",
    inCombat = false,
    _isLocal = false,
    _equipment = {},
    _talents = {},
    spells = {
        --[[
            The spell name is the key and gets replaced by a localized version of the spell name retrieved by GetSpellInfo(ranks[1])
            ["Spell name"] = {
                ranks:
                    A table of spell IDs or spell IDs and accompanied +threat values
                threatMod:
                    Either a number or function that returns the threat modifier to be used for the ability
                ignored:
                    For spells that have side effects but generate no threat
                handler:
                    Custom handler function for handling complex threat abilities
                        (Taunt)
                
                type:
                     [none]: Applies threat on SPELL_DAMAGE, HEAL, default handlers
                     DAMAGE: Ignore +threat in AURA_THREAT
                       BUFF: Apply +threat in AURA_THREAT
                     DEBUFF: Only apply +threat on DEBUFF_APPLIED/REFRESH
                      LEECH: healing ignored
                         CC: DEBUFF, Marking target as cc'd, ignoring global threat
                             For players saving their threat to preserve on the threat table for display (TODO)
                       CAST: Apply +threat on CAST_SUCCESS -threat on MISS
                    DISPELL: Apply threat on success dispells
            }
        ]]

        -- Zero threat
        ["Mana Tide"] = {
            ranks = {
                17360,
                17355,
                16191,
            },
            ignored = true,
        },
        ["Mana Spring"] = {
            ranks = {
                24853,
                10494,
                10493,
                10491,
                5677,
            },
            ignored = true,
        },


        -- Fetish of the Sand Reaver (26400 Arcane Shroud -70%)
        ["Arcane Shroud"] = {
            ranks = { 26400 },
            handler = ATM.BuffThreatMod({[127] = 0.3}),
        },
        -- Fungal Bloom - Loatheb (29232 0%)
        ["Fungal Bloom"] = {
            ranks = { 29232 },
            handler = ATM.BuffThreatMod({[127] = 0}),
        },
        -- Burning Adrenaline -75%; Don't believe this is real, is not hidden from combat log and doesn't show up in combat log
        -- ["Burning Adrenaline"] = {
        --     ranks = { 24701 },
        --     handler = ATM.BuffThreatMod({[127] = 0.25}),
        -- },
        -- Frostfire Regalia (Mage T3) 8 set bonus (28762 Not There 0%)
        ["Not There"] = {
            ranks = { 28762 },
            handler = ATM.BuffThreatMod({[127] = 0}),
        },
        -- Eye of Diminution (28862 -35%)
        ["Eye of Diminution"] = {
            ranks = { 28862 },
            handler = ATM.BuffThreatMod({[127] = 0.65}),
        },


        --Paladin Salvation
        ["Blessing of Salvation"] = {
            ranks = { 1038 },
            handler = ATM.BuffThreatMod({[127] =  0.7}),
        },
        ["Greater Blessing of Salvation"] = {
            ranks = { 25895 },
            handler = ATM.BuffThreatMod({[127] = 0.7}),
        },


        --[[ Season of Discovery ]]--
        ["Void Madness"] = {
            ranks = { 429868, 429867 },
            handler = ATM.BuffThreatMod({[127] = 1.21}),
        },
        ["Planar Shift"] = {
            ranks = { [428489] = -1000 },
            handler = ATM.TemporaryThreat,
        },
    },
}


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


    -- Check against the global spell table on a miss
    -- Save nils to improve speed at the cost of small amounts of memory
    local function SpellIndex(table, key)
        local spell = rawget(ATM.Player.spells, key)
        table[key] = spell
        return spell
    end
    setmetatable(self.spells, {
        __index = SpellIndex,
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
    amount = amount * self:classThreatModifier()
    if C.debug then
        ATM:print(self.currentEvent.." T:"..tostring(amount).." E:"..(enemyGUID or "GLOBAL"))
    end
    self:_addThreat(amount, enemyGUID)
end

function Player:addRawThreat(amount, enemyGUID)
    if C.debug then
        ATM:print(self.currentEvent.." M:RAW T:"..tostring(amount).." E:"..(enemyGUID or "GLOBAL"))
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
        enemy:setCombat(true, true)

        if not enemy or (not enemy.seenAPI and threatvalue == 0) then return end
        if enemy and not enemy.seenAPI and threatvalue > 0 then
            --TODO: UpdateThreat on all previous threatvalue == 0 players
            enemy.seenAPI = true
        end
        

        
        local newThreat = threatvalue/100
        local oldThreat = self:getThreat(destGUID)
        local mismatch = (newThreat - oldThreat)
        if isTanking then
            enemy.tankGUID = self.guid
            enemy.tankThreat = newThreat
        end

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
function Player:classThreatModifier()
    return 1.0
end

ATM.Player = Player




function Player:SPELL_CAST_SUCCESS(...)
    local spellID, spellName = select(12, ...)

    --Checking if we care about the spell
    local spellData = self.spells[spellName]
	if spellData and spellData.type == "CAST" then
        local timestamp, subevent, spellSchool, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _ = ...
        -- ATM:print("SPELL_CAST_SUCCESS", timestamp, spellName)

        local threat = ATM.spellThreat[spellID] * self.threatBuffs[spellSchool]
        if ATM.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
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

    local spellData = self.spells[spellName]
    if spellData and spellData.type == "CAST" then
        local threat = ATM.spellThreat[spellID]
        if not threat then
            return print("NIL SPELL THREAT FOR", spellID, spellName, ...)
        end
        if ATM.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
            self:addThreat(-threat) --can this happen?
        else
            self:addThreat(-threat, destGUID)
        end
    end
end


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

function Player:SPELL_DAMAGE(...)
	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
	local spellID, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)

    if C.debug then
        self.currentEvent = self.currentEvent.." R:"..tostring(amount)
    end
    local threat = amount
    local spellData = self.spells[spellName]
    if spellData then
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

        if not spellData.type or spellData.type ~= "DEBUFF" then
            threat = threat + (ATM.spellThreat[spellID] or 0)
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

    -- Only care about healing done to Players (TODO: support pets/friendlies)
    if ATM.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == 0 then
        return
    end

    if C.debug then
        self.currentEvent = self.currentEvent.." R:"..tostring(amount-overhealing)
    end
    
    local threat = (amount-overhealing) / 2.0
    
    local spellData = self.spells[spellName]
    if spellData then
        -- Ignore healing done from leech spells
        if spellData.type == "LEECH" then
            return
        end

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
        self:addRawThreat(amount * 0.5)
    elseif powerType == ATM.PowerType.Rage then
        if spellID == 29131 then --bloodrage ticks
            self:addThreat(amount * 5.0 * self.threatBuffs[spellSchool])
        else
            self:addRawThreat(amount * 5.0)
        end
    elseif powerType == ATM.PowerType.Energy then
        self:addRawThreat(amount * 5.0)
    end
end
Player.SPELL_PERIODIC_ENERGIZE = Player.SPELL_ENERGIZE


function Player:AURA_THREAT(...)
	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
    local spellID, spellName, spellSchool, auraType, amount = select(12, ...)

    local spellData = self.spells[spellName]

    -- If this ability doesn't generate threat just ignore
    if not spellData or spellData.type == "DAMAGE" or spellData.type == "CAST" then
        return
    end

    local enemy = ATM:getEnemy(destGUID)
    if spellData.type == "CC" and ATM.band(destFlags, COMBATLOG_OBJECT_TYPE_NPC) > 0 then
        enemy:setCC(spellName, true)
    end
    if spellData.ignored then return end
    
    if auraType == "DEBUFF" and ATM.band(destFlags, COMBATLOG_OBJECT_TYPE_NPC) > 0 then
        enemy:setCombat(true)
    end


    local threat = ATM.spellThreat[spellID]
    if not threat then return end

    -- ATM:print("AURA_THREAT", spellName, spellID)

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


    if threat then
        if auraType == "BUFF" then
            if ATM.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
                self:setCombat(ATM:getPlayer(destGUID):getCombat())
            end
            self:addThreat(threat)
        elseif auraType == "DEBUFF" then
            self:setCombat(true)
            self:addThreat(threat, destGUID)
        end
    end
end
Player.SPELL_AURA_APPLIED = Player.AURA_THREAT
Player.SPELL_AURA_REFRESH = Player.AURA_THREAT


function Player:SPELL_AURA_REMOVED(...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
    local spellID, spellName = select(12, ...)

    local spellData = self.spells[spellName]
    if not spellData or spellData.type ~= "CC" then return end
    
    if ATM.band(destFlags, COMBATLOG_OBJECT_TYPE_NPC) > 0 then
        local enemy = ATM:getEnemy(destGUID)
        enemy:setCC(spellName, false)
        enemy.lastThreatUpdate = ATM:GetTime() --ignore threat updates while still CC'd
    end
end
