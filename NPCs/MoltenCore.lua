if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))


local MoltenGiant = {
    spells = {
        ["Knock Away"] = {
            id = 18945,
            type = "CAST",
            handler = ATM.NPC.HalfThreatDrop
        },
    },
}
ATM.NPCs[11658] = MoltenGiant


local LavaAnnihilator = {}
LavaAnnihilator.SWING_DAMAGE = ATM.NPC.FullThreatDrop
ATM.NPCs[11665] = LavaAnnihilator


local Shazzrah = {
    spells = {
        ["Gate of Shazzrah"] = {
            id = 23138,
            type = "CAST",
            handler = ATM.NPC.GlobalThreatWipe
        },
    },
}
ATM.NPCs[12264] = Shazzrah


local Ragnaros = {
    meleeOnly = true,
    spells = {
        ["Wrath of Ragnaros"] = {
            id = 20566,
            type = "CAST",
            handler = ATM.NPC.GlobalThreatWipe
        },
    },
}
ATM.NPCs[11502] = Ragnaros

