if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))

--Stratholme
local Ramstein = {
    spells = {
        ["Knockout"] = {
            id = 17307,
            type = "CAST",
            handler = ATM.NPC.HalfThreatDrop
        },
    },
}
ATM.NPCs[10439] = Ramstein

--Gnomergon
local MekgineerThermaplugg = {
    spells = {
        ["Knock Away"] = {
            id = 11130,
            type = "CAST",
            handler = ATM.NPC.HalfThreatDrop
        },
    },
}
ATM.NPCs[7800] = MekgineerThermaplugg

local MechanizedGuardian = {
    spells = {
        ["Electrified Net"] = {
            id = 11820,
            type = "CAST",
            handler = ATM.NPC.FullThreatDrop
        },
    },
}
ATM.NPCs[6234] = MechanizedGuardian
