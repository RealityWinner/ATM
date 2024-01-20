if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))


local prototype = {
    class = "ROGUE",
}
prototype.color = "|c"..RAID_CLASS_COLORS[prototype.class].colorStr
ATM.playerMixins[prototype.class] = prototype

function prototype:scanTalents()
    -- ATM:print("ROGUE:scanTalents")
end

function prototype:classThreatModifier()
    return 0.71
end

prototype.spells = {
    ["Feint"] = {
        ranks = {
            [25302] = ATM.Player.levelBasedThreat(-800, -1, 60, 60), --maxLevel is technically 70
            [11303] = ATM.Player.levelBasedThreat(-600, -1, 52, 60), --maxLevel is technically 62
             [8637] = ATM.Player.levelBasedThreat(-390, -1, 40, 50),
             [6768] = ATM.Player.levelBasedThreat(-240, -1, 28, 38),
             [1966] = ATM.Player.levelBasedThreat(-150, -1, 16, 26),
        },
    },

    ["Vanish"] = {
        ranks = {
            1857,
            1856,
        },
        type = "CAST",
        handler = ATM.Player.wipeThreat
    },

    

    ["Cheap Shot"] = {
        ranks = {
            1833,
        },
        type = "CC",
    },
    ["Kidney Shot"] = {
        ranks = {
            [8643] = 100,
            [408] = 50,
        },
        type = "CC",
    },
    ["Gouge"] = {
        ranks = {
            11286,
            11285,
            8629,
            1777,
            1776,
        },
        type = "CC",
    },
    ["Blind"] = {
        ranks = {
            [2094] = 68,
        },
        type = "CC",
    },


    
    --[[ Season of Discovery ]]--
    ["Tease"] = {
        ranks = {
            410412
        },
        handler = ATM.Taunt,
    },
    --TODO: Just a Flesh Wound
}