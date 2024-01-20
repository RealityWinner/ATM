if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))


local prototype = {
    class = "WARLOCK",
}
prototype.color = "|c"..RAID_CLASS_COLORS[prototype.class].colorStr
ATM.playerMixins[prototype.class] = prototype

function prototype:scanTalents()
    -- ATM:print("WARLOCK:scanTalents")
end

function prototype:classThreatModifier()
    return 1.0
end

prototype.spells = {
    ["Searing Pain"] = {
        ranks = {
             5676,
            17919,
            17920,
            17921,
            17922,
            17923,
        },
        threatMod = 2.0,
    },

    ["Banish"] = {
        ranks = {
            [710] = 56, --CONFIRMED
            [18647] = 96, --CONFIRMED    
        },
        type = "CC",
    },

    ["Curse of Doom"] = {
        ranks = {
            [603] = 120, --CONFIRMED   
        },
        type = "DEBUFF",
    },

    ["Curse of Recklessness"] = {
        ranks = {
            [704] = 28, --CONFIRMED
            [7658] = 56, --CONFIRMED
            [7659] = 84, --CONFIRMED
            [11717] = 112, --CONFIRMED      
        },
        type = "DEBUFF",
    },

    ["Curse of Shadow"] = {
        ranks = {
            [17862] = 88, --CONFIRMED
            [17937] = 112, --CONFIRMED    
        },
        type = "DEBUFF",
    },

    ["Curse of Tongues"] = {
        ranks = {
            [1714] = 52, --CONFIRMED
            [11719] = 100, --CONFIRMED    
        },
        type = "DEBUFF",
    },

    ["Curse of Weakness"] = {
        ranks = {
            [702] = 8, --CONFIRMED
            [1108] = 24, --CONFIRMED
            [6205] = 44, --CONFIRMED
            [7646] = 64, --CONFIRMED   
            [11707] = 84, --CONFIRMED
            [11708] = 104, --CONFIRMED       
        },
        type = "DEBUFF",
    },

    ["Curse of the Elements"] = {
        ranks = {
            [1490] = 64, --CONFIRMED
            [11721] = 92, --CONFIRMED 
            [11722] = 120, --CONFIRMED
        },
        type = "DEBUFF",
    },

    ["Fear"] = {
        ranks = {
            [5782] = 16, --CONFIRMED
            [6213] = 64, --CONFIRMED   
            [6215] = 112, --CONFIRMED   
        },
        type = "CC",
    },

    ["Pyroclasm"] = {
        ranks = {
            [18073] = 70, --CONFIRMED
            [18096] = 70,   
        },
        type = "CC",
    },

    ["Howl of Terror"] = {
        ranks = {
            [5484] = 80, --CONFIRMED
            [17928] = 108, --CONFIRMED    
        },
        type = "CC",
    },

    -- only apply on debuff
    ["Siphon Life"] = {
        ranks = {
            [18265] = 60, --CONFIRMED
            [18879] = 76, --CONFIRMED  
            [18880] = 96, --CONFIRMED
            [18881] = 116, --CONFIRMED  
        },
        type = "LEECH",
    },

    -- No threat
    ["Drain Mana"] = {
        ranks = {
            11704,
            11703,
            6226,
            5138,
        },
        ignore = true,
    },

    ["Demon Skin"] = {
        ranks = {
            [687] = 1, --CONFIRMED
            [696] = 10, --CONFIRMED   
        },
        type = "BUFF",
    },

    ["Demon Armor"] = {
        ranks = {
            [11735] = 60, --CONFIRMED
            [11734] = 50, --CONFIRMED   
            [11733] = 40, --CONFIRMED
             [1086] = 30, --CONFIRMED   
              [706] = 20, --CONFIRMED  
        },
        type = "BUFF",
    },

    ["Conflagrate"] = {
        ranks = {
            [18932] = 120, 
            [18931] = 108, 
            [18930] =  96, 
            [17962] =  80, --CONFIRMED
        },
        type = "DMG",
    },

    ["Create Firestone (Lesser)"] = {
        ranks = {
            [6366] = 28, --CONFIRMED
        },
        type = "CAST",
    },
    ["Create Firestone"] = {
        ranks = {
            [17951] = 36, --CONFIRMED
        },
        type = "CAST",
    },
    ["Create Firestone (Greater)"] = {
        ranks = {
            [17952] = 46, --CONFIRMED
        },
        type = "CAST",
    },
    ["Create Firestone (Major)"] = {
        ranks = {
            [17953] = 56, --CONFIRMED
        },
        type = "CAST",
    },
    ["Create Spellstone"] = {
        ranks = {
            [2362] = 36, --CONFIRMED
        },
        type = "CAST",
    },
    ["Create Spellstone (Greater)"] = {
        ranks = {
            [17727] = 48, --CONFIRMED
        },
        type = "CAST",
    },
    ["Create Spellstone (Major)"] = {
        ranks = {
            [17728] = 60, --CONFIRMED
        },
        type = "CAST",
    },

    ["Detect Lesser Invisibility"] = {
        ranks = {
            [132] = 26, --CONFIRMED
        },
        type = "BUFF",
    },
    ["Detect Invisibility"] = {
        ranks = {
            [2970] = 38, --CONFIRMED
        },
        type = "BUFF",
    },
    ["Detect Greater Invisibility"] = {
        ranks = {
            [11743] = 50, --CONFIRMED
        },
        type = "BUFF",
    },

    ["Eye of Kilrogg"] = {
        ranks = {
            [126] = 22, --CONFIRMED
        },
        type = "BUFF",
    },

    ["Shadow Ward"] = {
        ranks = {
            [6229] = 32, --CONFIRMED
            [11739] = 42, --CONFIRMED
            [11740] = 52, --CONFIRMED
            [28610] = 60, 
        },
        type = "BUFF",
    },

    --SPELLS TO TEST: Whatever comes from talents, Shadowburn, Soul Fire, Inferno and pet abilities besides Torment and Suffering.

    -- PET ABILITIES
    -- ["Torment"] = {
    --     ranks = {
    --         [3716] = 45, --CONFIRMED
    --         [7809] = 75, --CONFIRMED
    --         [7810] = 125, --CONFIRMED
    --         [7811] = 215, --CONFIRMED
    --         [11774] = 300, --CONFIRMED
    --         [11775] = 395, --CONFIRMED 
    --     },
    -- },

    -- ["Suffering"] = {
    --     ranks = {
    --         [17735] = 150, --CONFIRMED
    --         [17750] = 300, --CONFIRMED
    --         [17751] = 450, --CONFIRMED
    --         [17752] = 600, --CONFIRMED 
    --     },
    -- },


    
    --[[ Season of Discovery ]]--
    ["Metamorphosis"] = {
        ranks = { 403789 },
        handler = ATM.BuffThreatMod({[127] = 1.5}),
    },
}