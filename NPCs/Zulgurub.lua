if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))



local Hakkar = {
    spells = {
        ["Aspect of Arlokk"] = {
            id = 24690,
            type = "CAST",
            handler = ATM.NPC.FullThreatDrop,
        },
        ["Cause Insanity"] = {
            id = 24327,
            type = "CC",
        },
    }
}
ATM.NPCs[14834] = Hakkar
