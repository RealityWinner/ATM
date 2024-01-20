if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))


local Noth = {
    spells = {
        ["Blink"] = {
            id = 29211,
            type = "CAST",
            handler = ATM.NPC.GlobalThreatWipe
        },
    },  
}
ATM.NPCs[15954] = Noth


local KelThuzad = {
    spells = {
        ["Chains of Kel'Thuzad"] = {
            id = 28410,
            type = "CAST",
            handler = ATM.NPC.GlobalThreatWipe
        },
    },  
}
ATM.NPCs[15990] = KelThuzad
