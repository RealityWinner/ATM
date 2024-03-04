if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))
local s = ATM.spells

local prototype = CreateFromMixins(ATM.Player, {
    class = "PRIEST",

    shadowMod = 1,
})
prototype.color = "|c"..RAID_CLASS_COLORS[prototype.class].colorStr
ATM.playerMixins[prototype.class] = prototype

function prototype:scanTalents()
    -- ATM:print("PRIEST:scanTalents")
    
    --Silent Resolve (98)
    local silentResolve = 1 - 0.4 * self:GetTalent(1, 3)
    if silentResolve < 1 then
        self.threatMods["Silent Resolve"] = { [98] = silentResolve } --Holy, Shadow, Arcane
    else
        self.threatMods["Silent Resolve"] = nil
    end

    --Shadow Affinity
    self.shadowMod = 1 - ({0.00, 0.08, 0.16, 0.25})[self:GetTalent(3, 3) + 1]
end

function prototype:shadowAffinity()
    return self.shadowMod
end


--Dispel Magic
s[527] = {threat=18,handler=ATM.Dispel}
s[988] = {threat=36,handler=ATM.Dispel}

--Divine Spirit
s[27841] = {onBuff=true,threat=60}
s[14819] = {onBuff=true,threat=50}
s[14818] = {onBuff=true,threat=40}
s[14752] = {onBuff=true,threat=30}

--Prayer of Spirit
s[27681] = {onBuff=true,threat=60}

--Inner Fire
s[10952] = {onBuff=true,threat=60}
s[10951] = {onBuff=true,threat=50}
s[1006]  = {onBuff=true,threat=40}
s[602]   = {onBuff=true,threat=30}
s[7128]  = {onBuff=true,threat=20}
s[588]   = {onBuff=true,threat=10}

--Levitate
s[1706]  = {onBuff=true,threat=34}

--Power Infusion
s[10060] = {onBuff=true,threat=40}

--Power Word: Fortitude
s[10938] = {onBuff=true,threat=60}
s[10937] = {onBuff=true,threat=48}
s[2791]  = {onBuff=true,threat=36}
s[1245]  = {onBuff=true,threat=24}
s[1244]  = {onBuff=true,threat=12}
s[1243]  = {onBuff=true,threat=1}

--Power Word: Shield
s[10901] = {onBuff=true,threat=99}
s[10900] = {onBuff=true,threat=99}
s[10899] = {onBuff=true,threat=99}
s[10898] = {onBuff=true,threat=99}
s[6066]  = {onBuff=true,threat=99}
s[6065]  = {onBuff=true,threat=76}
s[3747]  = {onBuff=true,threat=53.5}
s[600]   = {onBuff=true,threat=35}
s[592]   = {onBuff=true,threat=20.5}
s[17]    = {onBuff=true,threat=11}

--Prayer of Fortitude
s[21564] = {onBuff=true,threat=60}
s[21562] = {onBuff=true,threat=48}

--Shackle Undead
s[10955] = {isCC=true,onDebuff=true,threat=120}
s[9485]  = {isCC=true,onDebuff=true,threat=80}
s[9484]  = {isCC=true,onDebuff=true,threat=40}

--Abolish Disease
s[552]   = {onBuff=true,threat=32}

--Cure Disease
s[528]   = {threat=14,handler=ATM.Dispel}

--Fear Ward
s[6346]  = {onBuff=true,threat=20}

--Holy Nova
s[27801] = {ignored=true}
s[27800] = {ignored=true}
s[27799] = {ignored=true}
s[15431] = {ignored=true}
s[15430] = {ignored=true}
s[15237] = {ignored=true}

--Lightwell Renew
s[27874] = {ignored=true}
s[27873] = {ignored=true}
s[7001]  = {ignored=true}

--Mind Soothe
s[10953] = {ignored=true}
s[8192]  = {ignored=true}
s[453]   = {ignored=true}

--Mind Vision
s[10909] = {ignored=true}
s[2096]  = {ignored=true}

--Fade
s[10942] = {threat=ATM.Player.levelBasedThreat(-820, -3, 60, 70),handler=ATM.TemporaryThreat}
s[10941] = {threat=ATM.Player.levelBasedThreat(-620, -3, 50, 60),handler=ATM.TemporaryThreat}
s[9592]  = {threat=ATM.Player.levelBasedThreat(-440, -3, 40, 50),handler=ATM.TemporaryThreat}
s[9579]  = {threat=ATM.Player.levelBasedThreat(-285, -3, 30, 40),handler=ATM.TemporaryThreat}
s[9578]  = {threat=ATM.Player.levelBasedThreat(-155, -3, 20, 30),handler=ATM.TemporaryThreat}
s[586]   = {threat=ATM.Player.levelBasedThreat( -55, -3,  8, 18),handler=ATM.TemporaryThreat}

--Mind Blast
s[10947] = {onDamage=true,threat=540,threatMod=prototype.shadowAffinity}
s[10946] = {onDamage=true,threat=460,threatMod=prototype.shadowAffinity}
s[10945] = {onDamage=true,threat=380,threatMod=prototype.shadowAffinity}
s[8106]  = {onDamage=true,threat=303,threatMod=prototype.shadowAffinity}
s[8105]  = {onDamage=true,threat=236,threatMod=prototype.shadowAffinity}
s[8104]  = {onDamage=true,threat=180,threatMod=prototype.shadowAffinity}
s[8103]  = {onDamage=true,threat=121,threatMod=prototype.shadowAffinity}
s[8102]  = {onDamage=true,threat=77,threatMod=prototype.shadowAffinity}
s[8092]  = {onDamage=true,threat=40,threatMod=prototype.shadowAffinity}

--Mind Flay
s[18807] = {onDebuff=true,threat=120,threatMod=prototype.shadowAffinity}
s[17314] = {onDebuff=true,threat=104,threatMod=prototype.shadowAffinity}
s[17313] = {onDebuff=true,threat=88,threatMod=prototype.shadowAffinity}
s[17312] = {onDebuff=true,threat=72,threatMod=prototype.shadowAffinity}
s[17311] = {onDebuff=true,threat=56,threatMod=prototype.shadowAffinity}
s[15407] = {onDebuff=true,threat=40,threatMod=prototype.shadowAffinity}

--Psychic Scream
s[10890] = {isCC=true,onDebuff=true,threat=112}
s[10888] = {isCC=true,onDebuff=true,threat=84}
s[8124]  = {isCC=true,onDebuff=true,threat=56}
s[8122]  = {isCC=true,onDebuff=true,threat=28}

--Shadow Protection
s[10958] = {onBuff=true,threat=56,threatMod=prototype.shadowAffinity}
s[10957] = {onBuff=true,threat=42,threatMod=prototype.shadowAffinity}
s[976]   = {onBuff=true,threat=30,threatMod=prototype.shadowAffinity}

--Prayer of Shadow Protection
s[27683] = {onBuff=true,threat=56,threatMod=prototype.shadowAffinity}

--Shadow Word: Pain
s[10894] = {onDebuff=true,threatMod=prototype.shadowAffinity}
s[10893] = {onDebuff=true,threatMod=prototype.shadowAffinity}
s[10892] = {onDebuff=true,threatMod=prototype.shadowAffinity}
s[2767]  = {onDebuff=true,threatMod=prototype.shadowAffinity}
s[992]   = {onDebuff=true,threatMod=prototype.shadowAffinity}
s[970]   = {onDebuff=true,threatMod=prototype.shadowAffinity}
s[594]   = {onDebuff=true,threatMod=prototype.shadowAffinity}
s[589]   = {onDebuff=true,threatMod=prototype.shadowAffinity}

--Vampiric Embrace
s[15286] = {isLeech=true,onDebuff=true,onDamage=true,threat=2,threatMod=prototype.shadowAffinity}

--Mind Control
s[10912] = {handler=ATM.MindControl}
s[10911] = {handler=ATM.MindControl}
s[605]   = {handler=ATM.MindControl}


    --[[ Season of Discovery ]]--
--Void Plague
s[425204] = {onDebuff=true,threat=2,threatMod=prototype.shadowAffinity}

--Homunculi
s[402799] = {onCast=true,threat=6,threatMod=prototype.shadowAffinity}
