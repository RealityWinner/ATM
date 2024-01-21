if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))


local prototype = {
    class = "WARRIOR",

    -- Stances
    defianceMod = 1.0
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

prototype.classFields = ATM.toTrue({
})


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
    --TODO this
    return 1.0
end

prototype.spells = {
    ["Charge"] = {
        ranks = {
            11578,
            6178,
            100,
        },
        ignored = true, --charge generates no combat or threat, tested and confirmed
    },
    ["Charge Stun"] = {
        ranks = {
            7922,
        },
        type = "CC",
        ignored = true, --stun generates no combat or threat, tested and confirmed
    },
    --Intercept charge generates no threat, damage is part of stun
    -- ["Intercept"] = {
    --     ranks = {
    --         20617,
    --         20616,
    --         20252,
    --     },
    --     -- ignored = true, 
    -- },
    ["Intercept Stun"] = {
        ranks = {
            20615,
            20614,
            20253,
        },
        threatMod = 2.0,
    },

    ["Battle Shout"] = {
        ranks = {
            [25289] = 60, --AQ40
            [11551] = 52,
            [11550] = 42,
            [11549] = 32,
            [6192] = 22,
            [5242] = 12,
            [6673] = 1,
        },
    },
    ["Demoralizing Shout"] = {
        ranks = {
            [11556] = 48 * 54 / 60, --CONFIRMED
            [11555] = 48 * 44 / 60,
            [11554] = 48 * 34 / 60,
             [6190] = 48 * 24 / 60,
             [1160] = 48 * 14 / 60, --CONFIRMED
        },
    },
    ["Thunder Clap"] = {
        ranks = {
            11581,
            11580,
            8205,
            8204,
            8198,
            6343,
        },
        type = "DAMAGE",
        threatMod = 2.5,
    },
    
    ["Hamstring"] = {
        ranks = {
            [7373] = 135,
            [7372] = 135 * (32/54),
            [1715] = 135 * (8/54), --CONFIRMED 20
        },
        type = "DAMAGE",
        threatMod = 1.25,
    },
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
