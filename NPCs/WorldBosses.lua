if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))


local function ArcaneVacuum(self, ...)
    local player = ATM:player()
    local savedPlayerThreat = player:getThreat(self.guid)
    self:GlobalThreatWipe()

    -- Check if we are close, if not restore our threat to previous value
    local t = ATM:EnemyGUIDToTarget(self.guid)
    if t and not CheckInteractDistance(t, 5) then
        player:setThreat(savedPlayerThreat, self.guid)
    end
end

local Azuregoes = {
    spells = {
        ["Arcane Vacuum"] = {
            id = 21147,
            type = "CAST",
            handler = ArcaneVacuum,
        },
    }
}
ATM.NPCs[6109] = Azuregoes



