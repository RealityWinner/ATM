if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))
local s = ATM.spells

local prototype = {
    class = "MAGE",
}
prototype.color = "|c"..RAID_CLASS_COLORS[prototype.class].colorStr
ATM.playerMixins[prototype.class] = prototype

function prototype:scanTalents()
    -- ATM:print("MAGE:scanTalent")

    --Arcane Subtlety
    self.threatBuffs["Arcane Subtlety"] = {[64] = 1 - 0.2 * self:GetTalent(1, 1)}
    --Frost Channeling
    self.threatBuffs["Frost Channeling"] = {[16] = 1 - 0.1 * self:GetTalent(3, 12)}
    --Burning Soul
    self.threatBuffs["Burning Soul"] = {[4]  = 1 - 0.15 * self:GetTalent(2, 9)}
end

--Clearcasting
s[12536] = {onBuff=true,threat=10}

--Amplify Magic
s[10170] = {onBuff=true,threat=54}
s[10169] = {onBuff=true,threat=42}
s[8455]  = {onBuff=true,threat=30}
s[1008]  = {onBuff=true,threat=18}

--Arcane Brilliance
s[23028] = {onBuff=true,threat=56}

--Arcane Intellect
s[10157] = {onBuff=true,threat=56}
s[10156] = {onBuff=true,threat=42}
s[1461]  = {onBuff=true,threat=28}
s[1460]  = {onBuff=true,threat=14}
s[1459]  = {onBuff=true,threat=1}

--Blink
s[1953]  = {onBuff=true,threat=20}

--Counterspell
s[1953]  = {onCast=true,threat=300}

--Dampen Magic
s[10174] = {onBuff=true,threat=60}
s[10173] = {onBuff=true,threat=48}
s[8451]  = {onBuff=true,threat=36}
s[8450]  = {onBuff=true,threat=24}
s[604]   = {onBuff=true,threat=12}

--Evocation
s[12051] = {onBuff=true,threat=20}

--Mage Armor
s[22783] = {onBuff=true,threat=58}
s[22782] = {onBuff=true,threat=46}
s[6117]  = {onBuff=true,threat=34}

--Mana Shield
s[10193] = {onBuff=true,threat=60}
s[10192] = {onBuff=true,threat=52}
s[10191] = {onBuff=true,threat=44}
s[8495]  = {onBuff=true,threat=36}
s[8494]  = {onBuff=true,threat=28}
s[1463]  = {onBuff=true,threat=20}

--Polymorph
s[28271] = {isCC=true,onDebuff=true,threat=120}
s[28272] = {isCC=true,onDebuff=true,threat=120}
s[12826] = {isCC=true,onDebuff=true,threat=120}
s[12825] = {isCC=true,onDebuff=true,threat=80}
s[12824] = {isCC=true,onDebuff=true,threat=40}
s[118]   = {isCC=true,onDebuff=true,threat=16}

--Remove Lesser Curse
s[475]   = {threat=18,handler=ATM.Dispel}

--Slow Fall
s[130]  = {onBuff=true,threat=12}

--Impact
s[12355] = {isCC=true,onDebuff=true,threat=20}

--Fire Ward
s[10225] = {onBuff=true,threat=60}
s[10223] = {onBuff=true,threat=50}
s[8458]  = {onBuff=true,threat=40}
s[8457]  = {onBuff=true,threat=30}
s[543]   = {onBuff=true,threat=20}

--Frostbite
s[12497]  = {onDebuff=true,threat=20}
s[12496]  = {onDebuff=true,threat=20}
s[11071]  = {onDebuff=true,threat=20}

--Frost Armor
s[7301]  = {onBuff=true,threat=20}
s[7300]  = {onBuff=true,threat=20}
s[168]   = {onBuff=true,threat=1}

--Frost Nova
s[10230] = {onDebuff=true,threat=50}
s[6131]  = {onDebuff=true,threat=50}
s[865]   = {onDebuff=true,threat=30}
s[122]   = {onDebuff=true,threat=20}

--Frost Ward
s[28609] = {onBuff=true,threat=60}
s[10177] = {onBuff=true,threat=52}
s[8462]  = {onBuff=true,threat=42}
s[8461]  = {onBuff=true,threat=32}
s[6143]  = {onBuff=true,threat=22}

--Ice Armor
s[10220] = {onBuff=true,threat=60}
s[10219] = {onBuff=true,threat=50}
s[7320]  = {onBuff=true,threat=40}
s[7302]  = {onBuff=true,threat=30}

--Ice Barrier
s[13033] = {onBuff=true,threat=53.5}
s[13032] = {onBuff=true,threat=53.5}
s[13031] = {onBuff=true,threat=53.5}
s[11426] = {onBuff=true,threat=53.5}
