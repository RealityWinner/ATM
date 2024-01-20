if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))


local prototype = {
    class = "MAGE",
}
prototype.color = "|c"..RAID_CLASS_COLORS[prototype.class].colorStr
ATM.playerMixins[prototype.class] = prototype

function prototype:scanTalents()
    -- ATM:print("MAGE:scanTalent")
    
    --TODO update

    --Arcane Subtlety
    self.threatBuffs[64] = 1 - 0.2 * self:GetTalent(1, 1)
    --Frost Channeling
    self.threatBuffs[16] = 1 - 0.1 * self:GetTalent(3, 12)
    --Burning Soul
    self.threatBuffs[4]  = 1 - 0.15 * self:GetTalent(2, 9)
end

function prototype:classThreatModifier()
    return 1.0
end

prototype.spells = {
    
    --ARCANE SPELLS
    ["Clearcasting"] = {
        ranks = {
            [12536] = 10,
        },
        type = "BUFF",
    },

    ["Amplify Magic"] = {
        ranks = {
            [10170] = 54, --CONFIRMED
            [10169] = 42, --CONFIRMED
             [8455] = 30, --CONFIRMED
             [1008] = 18, --CONFIRMED  
        },
        type = "BUFF",
    },

    ["Arcane Brilliance"] = {
        ranks = {
            [23028] = 56, --MULTIPLY BY NUMBER OF BUFFED PLAYERS
        },
        type = "BUFF",
    },

    ["Arcane Intellect"] = {
        ranks = {
            [10157] = 56, --CONFIRMED
            [10156] = 42, --CONFIRMED
             [1461] = 28, --CONFIRMED
             [1460] = 14, --CONFIRMED
             [1459] =  1, --CONFIRMED
        },
        type = "BUFF",
    },

    ["Blink"] = {
        ranks = {
            [1953] = 20, --CONFIRMED
        },
        type = "BUFF",
    },

    ["Counterspell"] = {
        ranks = {
            [2139] = 300, --CONFIRMED
        },
        type = "CAST",
    },

    ["Dampen Magic"] = {
        ranks = {
            [10174] = 60, --CONFIRMED
            [10173] = 48, --CONFIRMED
             [8451] = 36, --CONFIRMED
             [8450] = 24, --CONFIRMED
              [604] = 12, --CONFIRMED   
        },
        type = "BUFF",
    },

    ["Evocation"] = {
        ranks = {
            [12051] = 20, --CONFIRMED
        },
        type = "BUFF",
    },

    ["Mage Armor"] = {
        ranks = {
            [22783] =  58,
            [22782] =  46,
            [6117] =  34,
        },
        type = "BUFF",
    },

    ["Mana Shield"] = {
        ranks = {
            [10193] =  60, --CONFIRMED
            [10192] =  52, --CONFIRMED
            [10191] =  44, --CONFIRMED
             [8495] =  36, --CONFIRMED
             [8494] =  28, --CONFIRMED
             [1463] =  20, --CONFIRMED
        },
        type = "BUFF",
    },

    ["Polymorph"] = {
        ranks = {
            [118] = 16, --CONFIRMED
            [12824] = 40, --CONFIRMED
            [12825] = 80, --CONFIRMED
            [12826] = 120, --CONFIRMED
            [28272] = 120, --CONFIRMED
            [28271] = 120, --TODO
        },
        type = "CC",
    },

    ["Remove Lesser Curse"] = {
        ranks = {
            [475] = 18, --CONFIRMED
        },
        type = "CAST",
    },

    ["Slow Fall"] = {
        ranks = {
            [130] = 12, --CONFIRMED
        },
        type = "BUFF",
    },

    --FIRE SPELLS
    ["Impact"] = {
        ranks = {
            [12355] = 20, --CONFIRMED
        },
        type ="CC",
    },

    ["Fire Ward"] = {
        ranks = {
            [10225] = 60, 
            [10223] = 50, --CONFIRMED
             [8458] = 40, --CONFIRMED
             [8457] = 30, --CONFIRMED
              [543] = 20, --CONFIRMED  
        },
        type = "BUFF",
    },

    --FROST SPELLS
    ["Frostbite"] = {
        ranks = {
            [12497] = 20, --CONFIRMED
            [12496] = 20, 
            [11071] = 20, 
        },
        type ="DEBUFF",
    },

    ["Frost Armor"] = {
        ranks = {
            [168] =  1, --CONFIRMED
            [7300] =  10, --CONFIRMED
            [7301] =  20, --CONFIRMED
        },
        type = "BUFF",
    },

    ["Frost Nova"] = {
        ranks = {
            [10230] =  50, --CONFIRMED
             [6131] =  50, --CONFIRMED
              [865] =  30, --CONFIRMED
              [122] =  20, --CONFIRMED
        },
        type = "DEBUFF",
    },

    ["Frost Ward"] = {
        ranks = {
            [6143] =  22, --CONFIRMED
            [8461] =  32, --CONFIRMED
            [8462] =  42, --CONFIRMED
            [10177] =  52, --CONFIRMED
            [28609] =  60, 
        },
        type = "BUFF",
    },

    ["Ice Armor"] = {
        ranks = {
            [7302] =  30, --CONFIRMED
            [7320] =  40, --CONFIRMED
            [10219] =  50, --CONFIRMED
            [10220] =  60, --CONFIRMED
        },
        type = "BUFF",
    },

    ["Ice Barrier"] = {
        ranks = {
            [11426] =  53.5, --CONFIRMED
            [13031] =  53.5, --CONFIRMED
            [13032] =  53.5, --CONFIRMED
            [13033] =  53.5, --CONFIRMED
        },
        type = "BUFF",
    },
}