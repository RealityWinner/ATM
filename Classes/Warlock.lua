if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))
local s = ATM.spells

local prototype = CreateFromMixins(ATM.Player, {
    class = "WARLOCK",
})
prototype.color = "|c"..RAID_CLASS_COLORS[prototype.class].colorStr
ATM.playerMixins[prototype.class] = prototype

function prototype:init()
    -- ATM:print("Warlock:init")
    ATM.Player.init(self)

    if self.unit then --Metamorphosis
        local spellName = ATM.FindAuraByID(403789, self.unit, "HELPFUL")
        if spellName then
            self.threatMods[spellName] = {[127] = 1.5}
        end
    end
end

function prototype:scanTalents()
    -- ATM:print("WARLOCK:scanTalents")
end


--Searing Pain
s[5676]  = {threatMod=2.0}
s[17919] = {threatMod=2.0}
s[17920] = {threatMod=2.0}
s[17921] = {threatMod=2.0}
s[17922] = {threatMod=2.0}
s[17923] = {threatMod=2.0}

--Banish
s[710]   = {isCC=true,onDebuff=true,threat=56}
s[18647] = {isCC=true,onDebuff=true,threat=96}

--Curse of Doom
s[603]   = {onDebuff=true,threat=120}

--Curse of Recklessness
s[704]   = {onDebuff=true,threat=28}
s[7658]  = {onDebuff=true,threat=56}
s[7659]  = {onDebuff=true,threat=84}
s[11717] = {onDebuff=true,threat=112}

--Curse of Shadow
s[17862] = {onDebuff=true,threat=88}
s[17937] = {onDebuff=true,threat=112}

--Curse of Tongues
s[1714]  = {onDebuff=true,threat=52}
s[11719] = {onDebuff=true,threat=100}

--Curse of Weakness
s[702]   = {onDebuff=true,threat=8}
s[1108]  = {onDebuff=true,threat=24}
s[6205]  = {onDebuff=true,threat=44}
s[7646]  = {onDebuff=true,threat=64}
s[11707] = {onDebuff=true,threat=84}
s[11708] = {onDebuff=true,threat=104}

--Curse of the Elements
s[1490]  = {onDebuff=true,threat=64}
s[11721] = {onDebuff=true,threat=92}
s[11722] = {onDebuff=true,threat=120}

--Fear
s[5782]  = {isCC=true,onDebuff=true,threat=16}
s[6213]  = {isCC=true,onDebuff=true,threat=64}
s[6215]  = {isCC=true,onDebuff=true,threat=112}

--Pyroclasm
s[18073] = {isCC=true,onDebuff=true,threat=70}
s[18096] = {isCC=true,onDebuff=true,threat=70}

--Howl of Terror
s[5484]  = {isCC=true,onDebuff=true,threat=80}
s[17928] = {isCC=true,onDebuff=true,threat=108}

--Siphon Life
s[18265] = {isLeech=true,onDebuff=true,threat=60}
s[18879] = {isLeech=true,onDebuff=true,threat=76}
s[18880] = {isLeech=true,onDebuff=true,threat=96}
s[18881] = {isLeech=true,onDebuff=true,threat=116}

--Drain Life
s[689]    = {isLeech=true,onDebuff=true}
s[699]    = {isLeech=true,onDebuff=true}
s[709]    = {isLeech=true,onDebuff=true}
s[7651]   = {isLeech=true,onDebuff=true}
s[11699]  = {isLeech=true,onDebuff=true}
s[11700]  = {isLeech=true,onDebuff=true}

s[403677] = {isLeech=true,onDebuff=true}
s[403685] = {isLeech=true,onDebuff=true}
s[403686] = {isLeech=true,onDebuff=true}
s[403687] = {isLeech=true,onDebuff=true}
s[403688] = {isLeech=true,onDebuff=true}
s[403689] = {isLeech=true,onDebuff=true}

--Drain Mana
s[11704] = {ignored=true}
s[11703] = {ignored=true}
s[6226]  = {ignored=true}
s[5138]  = {ignored=true}


--Demon Skin
s[687]   = {onBuff=true,threat=1}
s[696]   = {onBuff=true,threat=10}

--Demon Armor
s[706]   = {onBuff=true,threat=20}
s[1086]  = {onBuff=true,threat=30}
s[11733] = {onBuff=true,threat=40}
s[11734] = {onBuff=true,threat=50}
s[11735] = {onBuff=true,threat=60}

--Conflagrate
s[17962] = {onDamage=true,threat=80}
s[18930] = {onDamage=true,threat=96}
s[18931] = {onDamage=true,threat=108}
s[18932] = {onDamage=true,threat=120}

--Create Firestone (Lesser)
s[6366]  = {onCast=true,threat=28}

--Create Firestone
s[17951] = {onCast=true,threat=36}

--Create Firestone (Greater)
s[17952] = {onCast=true,threat=46}

--Create Firestone (Major)
s[17953] = {onCast=true,threat=56}

--Create Spellstone
s[2362]  = {onCast=true,threat=36}

--Create Spellstone (Greater)
s[17727] = {onCast=true,threat=48}

--Create Spellstone (Major)
s[17728] = {onCast=true,threat=60}

--Detect Lesser Invisibility
s[132]   = {onBuff=true,threat=26}

--Detect Invisibility
s[2970]  = {onBuff=true,threat=38}

--Detect Greater Invisibility
s[11743] = {onBuff=true,threat=50}

--Eye of Kilrogg
s[126]   = {onBuff=true,threat=22}

--Shadow Ward
s[6229]  = {onBuff=true,threat=32}
s[11739] = {onBuff=true,threat=42}
s[11740] = {onBuff=true,threat=52}
s[28610] = {onBuff=true,threat=60}

--Life Tap
s[31818]  = {ignored=true} --The actual energize
s[1454]   = {ignored=true}
s[1455]   = {ignored=true}
s[1456]   = {ignored=true}
s[11687]  = {ignored=true}
s[11688]  = {ignored=true}
s[11689]  = {ignored=true}




    --[[ Season of Discovery ]]--
--Metamorphosis
s[403789] = {onBuff=true,threat=1,handler=ATM:BuffThreatMod({[127] = 1.5})}

--Shadow Cleave
s[403835] = {threatMod=2.0}
s[403839] = {threatMod=2.0}
s[403840] = {threatMod=2.0}
s[403841] = {threatMod=2.0}
s[403842] = {threatMod=2.0}
s[403843] = {threatMod=2.0}
s[403844] = {threatMod=2.0}
s[403848] = {threatMod=2.0}
s[403851] = {threatMod=2.0}
s[403852] = {threatMod=2.0}