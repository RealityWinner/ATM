if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))



-- Ouro - Sand Blast
ATM.spells[26102] = {
    onDebuff = true,
    handler = ATM.NPC.FullThreatDrop
}


-- When casting whirlwind is a global threat wipe
-- Satura's Whirlwind removes all threat from current tank (when hit?)
local function whirlwind(self, ...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _ = ...
    local spellID, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
    ATM:print("ATM:NPC:AQ40:sartura:whirlwind", subevent, sourceGUID, spellName, spellID)

    if subevent == "SPELL_AURA_REMOVED" then
        self:GlobalThreatWipe() --Pretty sure
    elseif self:getID() == 15516 and subevent == "SPELL_DAMAGE" and destGUID == self.tankGUID then
        self:FullThreatDrop(...)
    end
end

-- Sartura (Guard) - Whirlwind
ATM.spells[26083] = {
    onDamage = true,
    handler = whirlwind
}
ATM.spells[26084] = {
    onDamage = true,
    handler = whirlwind
}
