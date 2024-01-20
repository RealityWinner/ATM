if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))



-- 3/24 21:00:07.228  SPELL_AURA_APPLIED,Creature-0-4411-469-24547-12435-00007AAB73,"Razorgore the Untamed",0x10a48,0x0,Player-4410-00662340,"Player-Server",0x511,0x0,23958,"Mind Exhaustion",0x20,DEBUFF
local function MindExhaustion(...)
	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _ = ...
    if subevent == "SPELL_AURA_APPLIED" then
        ATM:wipeThreat(sourceGUID)
        ATM:getPlayer(destGUID):setThreat(449700, sourceGUID)
    end
end

local Razorgore = {
    spells = {
        ["Mind Exhaustion"] = {
            id = 23958,
            type = "DEBUFF",
            handler = MindExhaustion
        },
    },
}
ATM.NPCs[12435] = Razorgore


local Broodlord = {
    spells = {
        ["Knock Away"] = {
            id = 18670,
            type = "DAMAGE",
            handler = ATM.NPC.HalfThreatDrop
        },
    },
}
ATM.NPCs[12017] = Broodlord


local FiremawEbonrocFlamegore = {
    spells = {
        ["Wing Buffet"] = {
            id = 23339,
            type = "DAMAGE",
            handler = ATM.NPC.HalfThreatDrop
        },
    },
}
ATM.NPCs[11983] = FiremawEbonrocFlamegore
ATM.NPCs[14601] = FiremawEbonrocFlamegore
ATM.NPCs[11981] = FiremawEbonrocFlamegore

-- Ignore healing done by Shadow of Ebonroc
-- 3/23 21:34:52.326  SPELL_HEAL,Player-4410-00662340,"Player-Server",0x511,0x80,Creature-0-4389-469-32359-14601-0000795A39,"Ebonroc",0x10a48,0x0,23394,"Shadow of Ebonroc",0x20,Creature-0-4389-469-32359-14601-0000795A39,0000000000000000,16,100,0,0,0,-1,0,0,0,-7368.47,-972.38,0,6.0707,63,25000,25000,0,0,nil
ATM.Player.spells["Shadow of Ebonroc"] = {
    ranks = { 23394 },
    ignored = true,
}


local Wyrmguard = {
    spells = {
        ["Brood Power: Green"] = {
            id = 22289,
            type = "DEBUFF",
            handler = ATM.NPC.HalfThreatDrop
        },
    },
}
ATM.NPCs[12460] = Wyrmguard


local Chromaggus = {
    spells = {
        ["Time Lapse"] = {
            id = 23311,
            type = "DEBUFF",
            handler = ATM.NPC.QuarterThreatDrop
        },
    },
}
ATM.NPCs[14020] = Chromaggus