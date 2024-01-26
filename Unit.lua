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
    
    local unitType = strsplit("-", unitGUID)
    if unitType == "Player" then
        return ATM:GetPlayer(unitGUID)
    end
    if unitType == "Creature" then
        return ATM:GetEnemy(unitGUID)
    end
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

    dead = false,
}
ATM.Unit = Unit

function Unit:MarkDead()
    self.dead = true
    if self.type == "Player" then
        self:setCombat(false)
    end
    if self.type == "Creature" then
        C_Timer.After(0.1, function()
            ATM:wipeThreat(self.guid)
        end)
    end
end

function Unit:SPELL_CAST_SUCCESS(...)
    local spellID, spellName = select(12, ...)

    --Checking if we care about the spell
    local spellData = ATM.spells[spellID]
	if spellData and spellData.onCast then
        local _, _, spellSchool, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _ = ...
        if bit.band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then
            self:addThreat(threat)
        else
            local enemy = ATM:GetUnit(destGUID)
            if enemy then
                enemy:setCombat(true)
                self:addThreat(threat, destGUID)
            end
        end
    end
end