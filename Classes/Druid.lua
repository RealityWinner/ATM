if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))
local s = ATM.spells

local prototype = {
    class = "DRUID",

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
end

function prototype:SPELL_AURA_APPLIED(...)
    local spellID, spellName = select(12, ...)
    if 5487 == spellID or 9634 == spellID then --Bear Forms
        ATM:print("[+]", self.name, "STANCE Bear")
        self.threatMods["Form"] = {[127] = 1.3 + self.feralinstinctMod}
        return
    elseif 768 == spellID or 23398 == spellID then --Cat Form
        ATM:print("[+]", self.name, "STANCE Cat")
        self.threatMods["Form"] = {[127] = 0.71}
        return
    end
    
    ATM.Player.SPELL_AURA_APPLIED(self, ...) --call original handler
end

function prototype:SPELL_AURA_REMOVED(...)
    local spellID, spellName = select(12, ...)
    if 5487 == spellID or 9634 == spellID or 768 == spellID or 23398 == spellID then --Bear and Cat forms
        ATM:print("[+]", self.name, "STANCE Human")
        self.threatMods["Form"] = nil
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


--Tranquility
s[740] = {threatMod = prototype.getTranqMod}
s[8918] = {threatMod = prototype.getTranqMod}
s[9862] = {threatMod = prototype.getTranqMod}
s[9863] = {threatMod = prototype.getTranqMod}

--Rejuvenation
s[25299] = {threatMod = prototype.getSubtletyMod}
s[9841] = {threatMod = prototype.getSubtletyMod}
s[9840] = {threatMod = prototype.getSubtletyMod}
s[9839] = {threatMod = prototype.getSubtletyMod}
s[8910] = {threatMod = prototype.getSubtletyMod}
s[3627] = {threatMod = prototype.getSubtletyMod}
s[2091] = {threatMod = prototype.getSubtletyMod}
s[2090] = {threatMod = prototype.getSubtletyMod}
s[1430] = {threatMod = prototype.getSubtletyMod}
s[1058] = {threatMod = prototype.getSubtletyMod}
s[774] = {threatMod = prototype.getSubtletyMod}

--Healing Touch
s[25297] = {threatMod = prototype.getSubtletyMod}
s[9889] = {threatMod = prototype.getSubtletyMod}
s[9888] = {threatMod = prototype.getSubtletyMod}
s[9758] = {threatMod = prototype.getSubtletyMod}
s[8903] = {threatMod = prototype.getSubtletyMod}
s[6778] = {threatMod = prototype.getSubtletyMod}
s[5189] = {threatMod = prototype.getSubtletyMod}
s[5188] = {threatMod = prototype.getSubtletyMod}
s[5187] = {threatMod = prototype.getSubtletyMod}
s[5186] = {threatMod = prototype.getSubtletyMod}
s[5185] = {threatMod = prototype.getSubtletyMod}

--Regrowth
s[9858] = {threatMod = prototype.getSubtletyMod}
s[9857] = {threatMod = prototype.getSubtletyMod}
s[9856] = {threatMod = prototype.getSubtletyMod}
s[9750] = {threatMod = prototype.getSubtletyMod}
s[8941] = {threatMod = prototype.getSubtletyMod}
s[8940] = {threatMod = prototype.getSubtletyMod}
s[8939] = {threatMod = prototype.getSubtletyMod}
s[8938] = {threatMod = prototype.getSubtletyMod}
s[8936] = {threatMod = prototype.getSubtletyMod}


--Gift of the Wild
s[21850] = {onBuff=true,threat=60}
s[21849] = {onBuff=true,threat=50}

--Mark of the Wild
s[9885] = {onBuff=true,threat=60}
s[9884] = {onBuff=true,threat=50}
s[8907] = {onBuff=true,threat=40}
s[5234] = {onBuff=true,threat=30}
s[6756] = {onBuff=true,threat=20}
s[5232] = {onBuff=true,threat=10}
s[1126] = {onBuff=true,threat=1}

--Faerie Fire
s[9907] = {onDebuff=true,threat=108}
s[9749] = {onDebuff=true,threat=84}
s[778]  = {onDebuff=true,threat=60}
s[770]  = {onDebuff=true,threat=36}

--Faerie Fire (Feral)
s[17392] = {onDebuff=true,threat=108}
s[17391] = {onDebuff=true,threat=84}
s[17390] = {onDebuff=true,threat=60}
s[16857] = {onDebuff=true,threat=36}

--Cower
s[9892]   = {onCast=true,threat=-600}
s[9000]   = {onCast=true,threat=-390}
s[8998]   = {onCast=true,threat=-240}

--Swipe
s[9908]   = {threatMod = 1.75}
s[9754]   = {threatMod = 1.75}
s[769]    = {threatMod = 1.75}
s[780]    = {threatMod = 1.75}
s[779]    = {threatMod = 1.75}

--Maul
s[9881]   = {threatMod = 1.75}
s[9880]   = {threatMod = 1.75}
s[9745]   = {threatMod = 1.75}
s[8972]   = {threatMod = 1.75}
s[6809]   = {threatMod = 1.75}
s[6808]   = {threatMod = 1.75}
s[6807]   = {threatMod = 1.75}

--Demoralizing Roar
s[9898]   = {onDebuff=true, threat=39}
s[9747]   = {onDebuff=true, threat=30}
s[9490]   = {onDebuff=true, threat=20}
s[1735]   = {onDebuff=true, threat=15}
s[99]     = {onDebuff=true, threat=9}

--Growl
s[6795]   = {handler = ATM.Taunt}