if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))


local Onyxia = {
    spells = {
        ["Knock Away"] = {
            id = 19633,
            type = "CAST",
            handler = ATM.NPC.QuarterThreatDrop
        },
        ["Fireball"] = {
            id = 18392,
            type = "CAST",
            handler = ATM.NPC.FullThreatDrop
        },
    },
    boundary = 75,
}
ATM.NPCs[10184] = Onyxia
