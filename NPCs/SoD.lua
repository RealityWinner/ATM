if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))

--Blackfathom Deeps
local Ghamoo = {
    spells = {
        ["Aqua Shell"] = {
            id = 414370,
            type = "CAST",
            handler = ATM.NPC.GlobalThreatWipe
        },
    },  
}
ATM.NPCs[201722] = Ghamoo
