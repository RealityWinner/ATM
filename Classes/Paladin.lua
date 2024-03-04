if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))
local s = ATM.spells

local prototype = CreateFromMixins(ATM.Player, {
    class = "PALADIN",

    impRighteousFury = 1
})
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
        self.threatMods[spellName] = {[2] = 1.6 * self.impRighteousFury}
        return
    end
    if 407627 == spellID then --Season of Discovery
        ATM:print("[+]", self.name, "++ Righteous Fury")
        self.threatMods[spellName] = {[2] = 2.23 * self.impRighteousFury, [125] = 1.50}
        return
    end
    
    ATM.Player.SPELL_AURA_APPLIED(self, ...) --call original handler
end

function prototype:SPELL_AURA_REMOVED(...)
    local spellID, spellName = select(12, ...)

    if 25780 == spellID or 407627 == spellID then --Righteous Fury
        ATM:print("[+]", self.name, "-- Righteous Fury")
        self.threatMods[spellName] = nil
        return
    end
    
    ATM.Player.SPELL_AURA_REMOVED(self, ...) --call original handler
end

--Blessing of Freedom
s[1044]  = {onBuff=true,threat=18}

--Blessing of Kings
s[20217] = {onBuff=true,threat=20}

--Seal of Righteousness
s[20154] = {onBuff=true,threat=1}

--Retribution Aura
s[54043] = {threatMod=2.0}

--Flash of Light
s[19750] = {threatMod=0.5}

--Holy Light
s[48782] = {threatMod=0.5}
s[48781] = {threatMod=0.5}
s[27136] = {threatMod=0.5}
s[27135] = {threatMod=0.5}
s[25292] = {threatMod=0.5}
s[10329] = {threatMod=0.5}
s[10328] = {threatMod=0.5}
s[3472]  = {threatMod=0.5}
s[1042]  = {threatMod=0.5}
s[1026]  = {threatMod=0.5}
s[647]   = {threatMod=0.5}
s[639]   = {threatMod=0.5}
s[635]   = {threatMod=0.5}
