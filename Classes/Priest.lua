if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))


local prototype = {
    class = "PRIEST",

    shadowMod = 1,
}
prototype.color = "|c"..RAID_CLASS_COLORS[prototype.class].colorStr
ATM.playerMixins[prototype.class] = prototype

function prototype:scanTalents()
    -- ATM:print("PRIEST:scanTalents")
    
    --Silent Resolve (98)
    local silentResolve = 1 - 0.4 * self:GetTalent(1, 3)
    if silentResolve < 1 then
        self.threatBuffs["Priest - Silent Resolve"] = { [98] = silentResolve } --Holy, Shadow, Arcane
    else
        self.threatBuffs["Priest - Silent Resolve"] = nil
    end

    --Shadow Affinity
    self.shadowMod = 1 - ({0.00, 0.08, 0.16, 0.25})[self:GetTalent(3, 3) + 1]
end

function prototype:shadowAffinity()
    return self.shadowMod
end

prototype.spells = {
    --Martyrdom, Inner Focus, Inspiration, Lightwell, Silence cause no threat
    --DISCIPLINE SPELLS
    ["Dispel Magic"] = {
        ranks = {
            --2x if used on enemy
            [988] = 36, --CONFIRMED 
            [527] = 18, --CONFIRMED 
        },
        handler = ATM.Dispel,
    },

    ["Divine Spirit"] = {
        ranks = {
            [27841] =  60,
            [14819] =  50,
            [14818] =  40,
            [14752] =  30,
        },
        type = "BUFF",
    },

    --MULTIPLY BY NUMBER OF BUFFED PLAYERS
    ["Prayer of Spirit"] = {
        ranks = {
            [27681] =  60,
        },
        type = "BUFF",
    },

    ["Inner Fire"] = {
        ranks = {
            [10952] =  60, --CONFIRMED
            [10951] =  50, --CONFIRMED
             [1006] =  40, --CONFIRMED
              [602] =  30, --CONFIRMED
             [7128] =  20, --CONFIRMED
              [588] =  10, --CONFIRMED           
        },
        type = "BUFF",
    },

    ["Levitate"] = {
        ranks = {
            [1706] = 34, --CONFIRMED
        },
        type = "BUFF",
    },
    
    ["Power Infusion"] = {
        ranks = {
            [10060] = 40, --CONFIRMED
        },
        type = "BUFF",
    },

    ["Power Word: Fortitude"] = {
        ranks = {
            [10938] = 60, --CONFIRMED
            [10937] = 48, --CONFIRMED
             [2791] = 36, --CONFIRMED
             [1245] = 24, --CONFIRMED
             [1244] = 12, --CONFIRMED
             [1243] =  1, --CONFIRMED
        },
        type = "BUFF",
    },

    ["Power Word: Shield"] = {
        ranks = {
            [10901] = 99,   --CONFIRMED
            [10900] = 99,
            [10899] = 99,
            [10898] = 99,
             [6066] = 99,   --CONFIRMED
             [6065] = 76,   --CONFIRMED
             [3747] = 53.5, --CONFIRMED
              [600] = 35,   --CONFIRMED
              [592] = 20.5, --CONFIRMED
               [17] = 11,   --CONFIRMED
        },
        type = "BUFF",
    },

    --MULTIPLY BY NUMBER OF BUFFED PLAYERS
    ["Prayer of Fortitude"] = {
        ranks = {
            [21564] = 60, 
            [21562] = 48, 
        },
        type = "BUFF",
    },

    ["Shackle Undead"] = {
        ranks = {
            [10955] = 120, --CONFIRMED
             [9485] =  80, --CONFIRMED
             [9484] =  40, --CONFIRMED
        },
        type = "CC",
    },
    
    ["Abolish Disease"] = {
        ranks = {
            [552] = 32, --CONFIRMED
        },
        type = "BUFF",
    },

    ["Cure Disease"] = {
        ranks = {
            [528] = 14, --CONFIRMED
        },
        type = "CAST"
    },

    ["Fear Ward"] = {
        ranks = {
            [6346] = 20, --CONFIRMED
        },
        type = "BUFF",
    },
    
    --HOLY SPELLS
    ["Holy Nova"] = {
        ranks = {
            27801,
            27800,
            27799,
            15431,
            15430,
            15237,
        },
        ignored = true,
    },

    ["Lightwell Renew"] = {
        ranks = {
            27874,
            27873,
            7001,
        },
        ignored = true,
    },

    --SHADOW SPELLS
    ["Mind Soothe"] = {
        ranks = {
            10953,
            8192,
            453,
        },
        ignored = true,
    },
    ["Mind Vision"] = {
        ranks = {
            10909,
            2096,
        },
        ignored = true,
    },

    ["Fade"] = {
        ranks = {
            [10942] = ATM.Player.levelBasedThreat(-820, -3, 60, 70),
            [10941] = ATM.Player.levelBasedThreat(-620, -3, 50, 60),
             [9592] = ATM.Player.levelBasedThreat(-440, -3, 40, 50),
             [9579] = ATM.Player.levelBasedThreat(-285, -3, 30, 40),
             [9578] = ATM.Player.levelBasedThreat(-155, -3, 20, 30),
              [586] = ATM.Player.levelBasedThreat( -55, -3,  8, 18),
        },
        handler = ATM.TemporaryThreat
    },

    ["Mind Blast"] = {
        ranks = {
            [10947] = 540, --CONFIRMED
            [10946] = 460, --CONFIRMED
            [10945] = 380, --CONFIRMED
             [8106] = 303, --CONFIRMED
             [8105] = 236, --CONFIRMED
             [8104] = 180, --CONFIRMED
             [8103] = 121, --CONFIRMED
             [8102] =  77, --CONFIRMED
             [8092] =  40, --CONFIRMED
        },
        threatMod = prototype.shadowAffinity,
        type = "DAMAGE",
    },

    --APPLY ONLY ONCE ON DEBUFF
    ["Mind Flay"] = {
        ranks = {
            [18807] = 120, --CONFIRMED
            [17314] = 104, --CONFIRMED
            [17313] =  88, --CONFIRMED
            [17312] =  72, --CONFIRMED
            [17311] =  56, --CONFIRMED
            [15407] =  40, --CONFIRMED
        },
        threatMod = prototype.shadowAffinity,
        type = "DEBUFF",
    },

    ["Psychic Scream"] = {
        ranks = {
            [10890] = 112, --CONFIRMED
            [10888] =  84, --CONFIRMED
             [8124] =  56, --CONFIRMED
             [8122] =  28, --CONFIRMED
        },
        threatMod = prototype.shadowAffinity,
        type = "CC",
    },

    ["Shadow Protection"] = {
        ranks = {
            [10958] = 56, --CONFIRMED
            [10957] = 42, --CONFIRMED
              [976] = 30, --CONFIRMED
        },
        threatMod = prototype.shadowAffinity,
        type = "BUFF",
    },

    --MULTIPLY BY NUMBER OF BUFFED PLAYERS
    ["Prayer of Shadow Protection"] = {
        ranks = {
            [27683] = 56,
        },
        threatMod = prototype.shadowAffinity,
        type = "BUFF",
    },

    ["Shadow Word: Pain"] = {
        ranks = {
            10894,
            10893,
            10892,
             2767,
              992,
              970,
              594,
              589,
        },
        threatMod = prototype.shadowAffinity,
    },

    ["Vampiric Embrace"] = {
        ranks = {
            [15286] = 2, --CONFIRMED (TODO: generates 2 threat every proc)
        },
        threatMod = prototype.shadowAffinity,
        type = "DEBUFF",
    },

    ["Mind Control"] = {
        ranks = {
            10912,
            10911,
            605,
        },
        handler = ATM.MindControl,
    },


    --[[ Season of Discovery ]]--
    ["Void Plague"] = {
        ranks = {
            [425204] = 2, --CONFIRMED
        },
        threatMod = prototype.shadowAffinity,
        type = "DEBUFF",
    },

    ["Homunculi"] = {
        ranks = {
            [402799] = 6, --CONFIRMED
        },
        threatMod = prototype.shadowAffinity,
        type = "CAST",
    },
}