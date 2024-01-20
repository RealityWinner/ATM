if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))


local prototype = {
    class = "DRUID",

    --Stances (forms)
    stanceMod = 1.0,

    --Talents
    feralinstinctMod = 0.0,
    subtletyMod = 1.0,
    tranqMod = 1.0,
}
prototype.color = "|c"..RAID_CLASS_COLORS[prototype.class].colorStr
ATM.playerMixins[prototype.class] = prototype

function prototype:scanTalents()
    -- ATM:print("DRUID:scanTalents")

    local newFeralInstinctMod = 0.03 * self:GetTalent(2, 3)
    if newFeralInstinctMod ~= self.feralInstinctMod then self.talentsTime = GetServerTime(); ATM:TransmitSelf() end
    self.feralInstinctMod = newFeralInstinctMod

    local newSubtletyMod = 0.04 * self:GetTalent(3, 8)
    if newSubtletyMod ~= self.subtletyMod then self.talentsTime = GetServerTime(); ATM:TransmitSelf() end
    self.subtletyMod = newSubtletyMod

    local newTranqMod = 0.5 * self:GetTalent(3, 13)
    if newTranqMod ~= self.tranqMod then self.talentsTime = GetServerTime(); ATM:TransmitSelf() end
    self.tranqMod = newTranqMod


    --Update our stanceMod as it can change based on talents
    if self._isLocal then
        local newStanceMod = 1.0
        local idx = GetShapeshiftForm()
        if idx ~= 0 then
            local _, _, _, spellID = GetShapeshiftFormInfo(idx)
            if spellID == 5487 or spellID == 9634 then --Bear Forms
                newStanceMod = 1.3 + self.feralinstinctMod
            elseif spellID == 768 then -- Cat form
                newStanceMod = 0.71
            end
        end

        if newStanceMod ~= self.stanceMod then self.classTime = GetServerTime(); ATM:TransmitSelf() end
        self.stanceMod = newStanceMod
    end
end

function prototype:SPELL_AURA_APPLIED(...)
    local spellID, spellName = select(12, ...)
    if 5487 == spellID or 9634 == spellID then --Bear Forms
        ATM:print("[+]", self.name, "STANCE Bear")
        self.stanceMod = 1.3 + self.feralinstinctMod
        return
    elseif 768 == spellID or 23398 == spellID then --Cat Form
        ATM:print("[+]", self.name, "STANCE Cat")
        self.stanceMod = 0.71
        return
    end
    
    ATM.Player.SPELL_AURA_APPLIED(self, ...) --call original handler
end

function prototype:SPELL_AURA_REMOVED(...)
    local spellID, spellName = select(12, ...)
    if 5487 == spellID or 9634 == spellID or 768 == spellID or 23398 == spellID then --Bear and Cat forms
        ATM:print("[+]", self.name, "STANCE Human")
        self.stanceMod = 1.0
        return
    end
    
    ATM.Player.SPELL_AURA_REMOVED(self, ...) --call original handler
end


function prototype:getTranqMod()
    return self.tranqMod * self.subtletyMod
end

function prototype:getSubtletyMod()
    return self.subtletyMod
end

function prototype:classThreatModifier()
    return 1.0 * self.stanceMod
end

prototype.classFields = ATM.toTrue({
    'stanceMod'
})

prototype.spells = {
    ["Tranquility"] = {
        ranks = {
            9863,
            9862,
            8918,
             740,
        },
        threatMod = prototype.getTranqMod,
    },
    ["Rejuvenation"] = {
        ranks = {
            25299,
            9841,
            9840,
            9839,
            8910,
            3627,
            2091,
            2090,
            1430,
            1058,
            774,
        },
        threatMod = prototype.getSubtletyMod,
    },
    ["Healing Touch"] = {
        ranks = {
            25297,
            9889,
            9888,
            9758,
            8903,
            6778,
            5189,
            5188,
            5187,
            5186,
            5185,
        },
        threatMod = prototype.getSubtletyMod,
    },
    ["Regrowth"] = {
        ranks = {
            9858,
            9857,
            9856,
            9750,
            8941,
            8940,
            8939,
            8938,
            8936,
        },
        threatMod = prototype.getSubtletyMod,
    },

    
    ["Gift of the Wild"] = {
        ranks = {
            [21850] = 60, --TODO
            [21849] = 50, --TODO
        },
        type = "BUFF",
    },

    ["Mark of the Wild"] = {
        ranks = {
            [9885] =  60, --TODO
            [9884] =  50, --TODO
            [8907] =  40, --TODO
            [5234] =  30, --TODO
            [6756] =  20, --CONFIRMED
            [5232] =  10, --CONFIRMED
            [1126] =   1, --CONFIRMED
        },
        type = "BUFF",
    },


    
    ["Faerie Fire"] = {
        ranks = {
            [9907] = 108,
            [9749] =  84,
            [778]  =  60,
            [770]  =  36,
        },
        type = "DEBUFF",
    },
    ["Faerie Fire (Feral)"] = {
        ranks = {
            [17392] = 108,
            [17391] =  84,
            [17390] =  60,
            [16857] =  36,
        },
        type = "DEBUFF",
    },

    
    ["Cower"] = {
        ranks = {
            [9892] = -600,
            [9000] = -390,
            [8998] = -240,
        },
        type = "CAST", --TODO test
    },
    
    ["Swipe"] = {
        ranks = {
            9908,
            9754,
            769,
            780,
            779,
        },
        threatMod = 1.75,
    },
    ["Maul"] = {
        ranks = {
            9881,
            9880,
            9745,
            8972,
            6809,
            6808,
            6807,
        },
        threatMod = 1.75,
    },
    
    ["Demoralizing Roar"] = {
        ranks = {
            [9898] = 39,
            [9747] = 30,
            [9490] = 20,
            [1735] = 15,
              [99] =  9,
        },
        type = "DEBUFF",
    },

    ["Growl"] = {
        ranks = {
            6795
        },
        handler = ATM.Taunt,
    },
}