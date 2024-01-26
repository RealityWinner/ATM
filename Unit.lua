if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))


function ATM:GetUnit(unitGUID, skipCreate)
    if not unitGUID then return end
    local unit = rawget(ATM._units, unitGUID)
    if unit or skipCreate then return unit end
    if not skipCreate then return ATM._units[unitGUID] end
end

function ATM:NewUnit(unitGUID)
    if not unitGUID then return end
    
    local unit
    local tag, _, _, _, _, npcID, spawn_uid = strsplit('-', unitGUID)
    if tag == "Player" then
        local _, playerClass, _, playerRace, gender, playerName, server = GetPlayerInfoByGUID(unitGUID)

        if not ATM._player and ATM.me == unitGUID then
            playerClass = ({UnitClass("player")})[2]
            playerName = UnitName("player")
        end
        if not playerClass then
            ATM:print("[ATM] FAIL PLAYER CLASS", unitGUID, playerClass, playerName)
            return nil
        end

        unit = CreateFromMixins(ATM.Unit, ATM.Player, ATM.playerMixins[playerClass] or {})
        unit:init()
        unit:setGUID(unitGUID)
        unit:setName(playerName)
        unit:setRace(playerRace)
        unit:setGender(gender)
        unit:setServer(server)
        if unitGUID == ATM.me then
            unit:scanTalents()
        end
    end
    if tag == "Creature" then
        unit = CreateFromMixins(ATM.Unit, ATM.NPC, ATM.NPCs[tonumber(npcID)] or {})
        unit:init()
        unit:setID(npcID)
        unit:setGUID(enemyGUID)
        unit:setSubGUID(spawn_uid)
    end

    return unit
end

ATM._units = {}
local function UnitsIndex(table, key)
    local unit = ATM:NewUnit(key);
    rawset(table, key, unit)
    return unit
end
setmetatable(ATM._units, {
    __index = UnitsIndex,
    __mode = "k", --weak
});


local Unit = {
    type = "", --"Player" or "Creature"
    guid = "",
    name = "",

    inCombat = false,
    dead = false,
}
ATM.Unit = Unit

function Unit:init()
end


function Unit:setGUID(guid)
    self.guid = guid
end
function Unit:getGUID()
    return self.guid
end

function Unit:getCombat()
    return self.inCombat
end
function Unit:setCombat(newCombat)
    if not newCombat and self.inCombat then
		self:wipeThreat()
    end
    self.inCombat = newCombat
end

function Unit:MarkDead()
    self.dead = true
    self:setCombat(false)
end


function Unit:SPELL_CAST_SUCCESS(...)
    local spellID, spellName = select(12, ...)
    local spellData = ATM.spells[spellID]
	if spellData and spellData.onCast then
        local threat = spellData.threat
        if type(threat) == "function" then
            threat = threat(self)
        end
        if not threat then return end

        local _, _, spellSchool, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _ = ...
        threat = threat * self.threatBuffs[spellSchool]
        if bit.band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then
            self:addThreat(-threat)
        else
            local enemy = ATM:GetUnit(destGUID)
            if enemy then
                enemy:setCombat(true)
                self:addThreat(-threat, destGUID)
            end
        end
    end
end

function Unit:SPELL_MISSED(...)
    local spellID, spellName = select(12, ...)
    local spellData = ATM.spells[spellID]
	if spellData and spellData.onCast then
        local threat = spellData.threat
        if type(threat) == "function" then
            threat = threat(self)
        end
        if not threat then return end

        local _, _, spellSchool, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _ = ...
        threat = threat * self.threatBuffs[spellSchool]
        if bit.band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then
            self:addThreat(-threat)
        else
            local enemy = ATM:GetUnit(destGUID)
            if enemy then
                enemy:setCombat(true)
                self:addThreat(-threat, destGUID)
            end
        end
    end
end