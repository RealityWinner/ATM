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

    if not rawget(self.threatMods, "Stance") then
        self.threatMods["Stance"] = {[127] = 0.8}
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
        self.threatMods["Stance"] = nil
        self.threatMods["Stance"] = {[127] = 0.8}
        return
    elseif 71 == spellID then --Defensive Stance
        ATM:print("[+]", self.name, "STANCE Defensive")
        self.threatMods["Stance"] = nil
        self.threatMods["Stance"] = {[127] = 1.3 * self.defianceMod}
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
s[20615]  = {isCC=true,threatMod=2.0}
s[20614]  = {isCC=true,threatMod=2.0}
s[20253]  = {isCC=true,threatMod=2.0}

--Intimidating Shout
s[5246]  = {isCC=true} --, onDebuff=true, threat=?

--Battle Shout
s[25289] = {onBuff=true,threat=60}
s[11551] = {onBuff=true,threat=52}
s[11550] = {onBuff=true,threat=42}
s[11549] = {onBuff=true,threat=32}
s[6192]  = {onBuff=true,threat=22}
s[5242]  = {onBuff=true,threat=12}
s[6673]  = {onBuff=true,threat=1}

--Demoralizing Shout
s[11556] = {onDebuff=true,threat=0.8*54}
s[11555] = {onDebuff=true,threat=0.8*44}
s[11554] = {onDebuff=true,threat=0.8*34}
s[6190]  = {onDebuff=true,threat=0.8*24}
s[1160]  = {onDebuff=true,threat=0.8*14}

--Thunder Clap
s[11581] = {onDamage=true,threatMod=prototype.thunderClap}
s[11580] = {onDamage=true,threatMod=prototype.thunderClap}
s[8205]  = {onDamage=true,threatMod=prototype.thunderClap}
s[8204]  = {onDamage=true,threatMod=prototype.thunderClap}
s[8198]  = {onDamage=true,threatMod=prototype.thunderClap}
s[6343]  = {onDamage=true,threatMod=prototype.thunderClap}

--Hamstring
s[7373] = {onDamage=true,threat=2.5*54,threatMod=1.25}
s[7372] = {onDamage=true,threat=2.5*32,threatMod=1.25}
s[1715] = {onDamage=true,threat=2.5*8,threatMod=1.25}

--Shield Slam
s[23925] = {onDamage=true,threat=254}
s[23924] = {onDamage=true,threat=229}
s[23923] = {onDamage=true,threat=203}
s[23922] = {onDamage=true,threat=178}

--Pummel
s[6554]  = {onDamage=true,threat=2*58}
s[6552]  = {onDamage=true,threat=2*38}

--Overpower
s[11585] = {threatMod=0.75}
s[11584] = {threatMod=0.75}
s[7887]  = {threatMod=0.75}
s[7384]  = {threatMod=0.75}

--Sunder Armor
s[11597] = {onCast=true,threatMod=prototype.eightSetMight,threat=4.5 * 58}
s[11596] = {onCast=true,threatMod=prototype.eightSetMight,threat=4.5 * 46}
s[8380]  = {onCast=true,threatMod=prototype.eightSetMight,threat=4.5 * 34}
s[7405]  = {onCast=true,threatMod=prototype.eightSetMight,threat=4.5 * 22}
s[7386]  = {onCast=true,threatMod=prototype.eightSetMight,threat=4.5 * 10}

--Heroic Strike
s[25286] = {onDamage=true,threat=175}
s[11567] = {onDamage=true,threat=145}
s[11566] = {onDamage=true,threat=118}
s[11565] = {onDamage=true,threat=87}
s[11564] = {onDamage=true,threat=65}
s[1608]  = {onDamage=true,threat=60}
s[285]   = {onDamage=true,threat=42}
s[284]   = {onDamage=true,threat=28}
s[78]    = {onDamage=true,threat=16}

--Cleave
s[20569] = {onDamage=true,threat=1.5*60}
s[11609] = {onDamage=true,threat=1.5*50}
s[11608] = {onDamage=true,threat=1.5*40}
s[7369]  = {onDamage=true,threat=1.5*30}
s[845]   = {onDamage=true,threat=1.5*20}

--Shield Bash
s[1672]  = {onDamage=true,threat=3*52,threatMod=1.5}
s[1671]  = {onDamage=true,threat=3*31,threatMod=1.5}
s[72]    = {onDamage=true,threat=3*12,threatMod=1.5}

--Revenge
s[25288] = {onDamage=true,threat=4.5*60,threatMod=2.25}
s[11601] = {onDamage=true,threat=4.5*54,threatMod=2.25}
s[11600] = {onDamage=true,threat=4.5*44,threatMod=2.25}
s[7379]  = {onDamage=true,threat=4.5*34,threatMod=2.25}
s[6574]  = {onDamage=true,threat=4.5*24,threatMod=2.25}
s[6572]  = {onDamage=true,threat=4.5*14,threatMod=2.25}

--Revenge Stun
s[12798] = {isCC=true,onDebuff=true,threat=25}

--Execute
s[26651]  = {threatMod=1.25}

--Mocking Blow
s[20560]  = {isTaunt=true,onDamage=true,threat=2*56}
s[20559]  = {isTaunt=true,onDamage=true,threat=2*46}
s[7402]   = {isTaunt=true,onDamage=true,threat=2*36}
s[7400]   = {isTaunt=true,onDamage=true,threat=2*26}
s[694]    = {isTaunt=true,onDamage=true,threat=2*16}

--Taunt
s[355]    = {isTaunt=true,handler=ATM.Taunt}



    --[[ Season of Discovery ]]--
--Enrage (Consumed by Rage)
s[425415] = {onBuff=true,threat=1}
