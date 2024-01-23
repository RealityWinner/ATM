if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))
local s = ATM.spells

local prototype = {
    class = "WARRIOR",

    defianceMod = 1.0,
    mightCount = 0,
}
prototype.color = "|c"..RAID_CLASS_COLORS[prototype.class].colorStr
ATM.playerMixins[prototype.class] = prototype

function prototype:scanTalents()
    -- ATM:print("WARRIOR:scanTalents")
    local newDefiance = 1 + (0.03 * self:GetTalent(3, 9))
    if newDefiance ~= self.defianceMod then self.talentsTime = GetServerTime(); ATM:TransmitSelf() end
    self.defianceMod = newDefiance

    if not rawget(self.threatBuffs, "Stance") then
        self.threatBuffs["Stance"] = {[127] = 0.8}
    end
end

function prototype:scanEquipment()
    ATM.Player.scanEquipment(self) --call original handler

    self.mightCount = 0
    for slotID,data in pairs(self._equipment) do
        local setID = select(16, GetItemInfo(unpack(data)))
        self.mightCount = self.mightCount + (setID and setID == 209 and 1 or 0)
    end
end

function prototype:SPELL_AURA_APPLIED(...)
    local spellID, spellName = select(12, ...)
    if 2457 == spellID or 2458 == spellID or 23397 == spellID then --Battle/Berserker Stance
        ATM:print("[+]", self.name, "STANCE Battle/Berserk")
        self.threatBuffs["Stance"] = {[127] = 0.8}
        return
    elseif 71 == spellID then --Defensive Stance
        ATM:print("[+]", self.name, "STANCE Defensive")
        self.threatBuffs["Stance"] = {[127] = 1.3 * self.defianceMod}
        return
    end
    
    ATM.Player.SPELL_AURA_APPLIED(self, ...) --call original handler
end

function prototype:eightSetMight()
    return self.mightCount >= 8 and 1.15 or 1
end

function prototype:thunderClap()
    return self._equipment[5] and self._equipment[5][3] == 6801 and 3.75 or 2.5
end


--Charge
s[11578] = {ignored=true}
s[6178]  = {ignored=true}
s[100]   = {ignored=true}

--Charge Stun
s[7922]  = {isCC=true,ignored=true}

--Intercept
s[20617]  = {ignored=true}
s[20616]  = {ignored=true}
s[20252]  = {ignored=true}

--Intercept Stun
s[20615]  = {isCC=true, threatMod=2.0}
s[20614]  = {isCC=true, threatMod=2.0}
s[20253]  = {isCC=true, threatMod=2.0}

--Battle Shout
s[25289] = {threat=60}
s[11551] = {threat=52}
s[11550] = {threat=42}
s[11549] = {threat=32}
s[6192]  = {threat=22}
s[5242]  = {threat=12}
s[6673]  = {threat=1}

--Demoralizing Shout
s[11556] = {threat=0.8*54}
s[11555] = {threat=0.8*44}
s[11554] = {threat=0.8*34}
s[6190]  = {threat=0.8*24}
s[1160]  = {threat=0.8*14}

--Thunder Clap
s[11581] = {threatMod=prototype.thunderClap}
s[11580] = {threatMod=prototype.thunderClap}
s[8205]  = {threatMod=prototype.thunderClap}
s[8204]  = {threatMod=prototype.thunderClap}
s[8198]  = {threatMod=prototype.thunderClap}
s[6343]  = {threatMod=prototype.thunderClap}

--Hamstring
s[7373] = {threat=2.5*54,threatMod=1.25}
s[7372] = {threat=2.5*32,threatMod=1.25}
s[1715] = {threat=2.5*8,threatMod=1.25}

--Shield Slam


prototype.spells = {
    ["Shield Slam"] = {
        ranks = {
            [23925] = 254,
            [23924] = 229,
            [23923] = 203,
            [23922] = 178,
        },
    },
    ["Pummel"] = {
        ranks = {
            [6554] = 120 * (58/60), --CONFIRMED 116
            [6552] = 120 * (38/60), --CONFIRMED  76
        },
    },
    ["Overpower"] = {
        ranks = {
            11585,
            11584,
            7887,
            7384,
        },
        threatMod = 0.75,
    },
    ["Sunder Armor"] = {
        ranks = {
            [11597] = 4.5 * 58, --CONFIRMED 261
            [11596] = 4.5 * 46,
             [8380] = 4.5 * 34,
             [7405] = 4.5 * 22,
             [7386] = 4.5 * 10, --CONFIRMED 45
        },
        threatMod = prototype.eightSetMight,
        type = "CAST",
    },
    ["Heroic Strike"] = {
        ranks = {
            [25286] = 175, --AQ 157 dmg
            [11567] = 145, --CONFIRMED 138 dmg
            [11566] = 118,
            [11565] =  87,
            [11564] =  65,
             [1608] =  60, --CONFIRMED 44 dmg 24 lvl
              [285] =  42, --          32 dmg 16 lvl
              [284] =  28, --CONFIRMED 21 dmg 8 lvl
               [78] =  16, --CONFIRMED 11 dmg 1 lvl
        },
    },
    ["Cleave"] = {
        ranks = { --TODO test
            [20569] = 1.5 * 60, -- 50 dmg
            [11609] = 1.5 * 50, -- 32 dmg
            [11608] = 1.5 * 40, -- 18 dmg
             [7369] = 1.5 * 30, -- 10 dmg
              [845] = 1.5 * 20, -- CONFIRMED  5 dmg
        },
    },

    ["Shield Bash"] = {
        ranks = {
            [1672] = 3 * 52,
            [1671] = 3 * 31, --CONFIRMED 93 (TODO: this should be 96?)
              [72] = 3 * 12, --CONFIRMED 36
        },
        threatMod = 1.5,
    },
    ["Revenge"] = {
        ranks = {
            [25288] = 4.5 * 60,
            [11601] = 4.5 * 54, --CONFIRMED 243
            [11600] = 4.5 * 44,
             [7379] = 4.5 * 34,
             [6574] = 4.5 * 24,
             [6572] = 4.5 * 14, --CONFIRMED 63
        },
        threatMod = 2.25,
    },
    ["Revenge Stun"] = {
        ranks = {
            [12798] = 25,
        },
        type = "DEBUFF",
    },

    ["Execute"] = {
        ranks = {
            26651
        },
        threatMod = 1.25,
    },

    ["Mocking Blow"] = {
        ranks = {
            [20560] = 2 * 56,
            [20559] = 2 * 46,
             [7402] = 2 * 36,
             [7400] = 2 * 26,
              [694] = 2 * 16,
        },
        type = "DEBUFF",
    },

    ["Taunt"] = {
        ranks = {
            355
        },
        handler = ATM.Taunt,
    },

    
    --[[ Season of Discovery ]]--
    ["Enrage"] = {
        ranks = {
            [425415] = 1, --Consumed by Rage
        }
    },
}
