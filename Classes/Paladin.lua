if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))


local prototype = {
    class = "PALADIN",

    impRighteousFury = 1
}
prototype.color = "|c"..RAID_CLASS_COLORS[prototype.class].colorStr
ATM.playerMixins[prototype.class] = prototype

function prototype:scanTalents()
    -- ATM:print("PALADIN:scanTalents")
    
    --Righteous Fury
    self.impRighteousFury = 1 + ({0, 0.16, 0.33, 0.5})[self:GetTalent(2, 7)+1]
end

function prototype:SPELL_AURA_APPLIED(...)
    local spellID, spellName = select(12, ...)

    if 25780 == spellID then --Vanilla
        ATM:print("[+]", self.name, "++ Righteous Fury")
        self.threatBuffs[spellName] = {[2] = 1.6 * self.impRighteousFury}
        return
    end
    if 407627 == spellID then --Season of Discovery
        ATM:print("[+]", self.name, "++ Righteous Fury")
        self.threatBuffs[spellName] = {[2] = 2.23 * self.impRighteousFury, [125] = 1.50}
        return
    end
    
    ATM.Player.SPELL_AURA_APPLIED(self, ...) --call original handler
end

function prototype:SPELL_AURA_REMOVED(...)
    local spellID, spellName = select(12, ...)

    if 25780 == spellID or 407627 == spellID then --Righteous Fury
        ATM:print("[+]", self.name, "-- Righteous Fury")
        self.threatBuffs[spellName] = nil
        return
    end
    
    ATM.Player.SPELL_AURA_REMOVED(self, ...) --call original handler
end

prototype.spells = {
    ["Blessing of Freedom"] = {
        ranks = {
            [1044] = 18,
        },
    },
    ["Blessing of Kings"] = {
        ranks = {
            [20217] = 20,
        },
    },
    
    ["Seal of Righteousness"] = {
        ranks = {
            [20154] = 1,
        },
    },

    ["Retribution Aura"] = {
        ranks = {
            54043,
        },
        threatMod = 2.0,
    },

    ["Flash of Light"] = {
        ranks = {
            19750,
        },
        threatMod = 0.5,
    },
    ["Holy Light"] = {
        ranks = {
            48782,
            48781,
            27136,
            27135,
            25292,
            10329,
            10328,
            3472,
            1042,
            1026,
            647,
            639,
            635,
        },
        threatMod = 0.5,
    },
}