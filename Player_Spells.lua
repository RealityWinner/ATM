if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))
local s = ATM.spells
--[[
    The spell ID is the key
    [spellID] = {
        threat:
            The static threat value
        threatMod:
            Either a number or function that returns the threat modifier to be used for the ability
        ignored:
            For spells that have side effects but generate no threat
        handler:
            Custom handler function for handling complex threat abilities
                (Taunt)
                (MindControl)
                (Dispel)
        
        --PLAYER
        isDamage:
            Ignore +threat in AURA_THREAT
        isLeech:
            Ignores healing (leech effects generate no threat on heal)
        isCC:
            DEBUFF, Marking target as cc'd, ignoring global threat
            For players saving their threat to preserve on the threat table for display (TODO)
        onCast:
            Apply +threat on CAST_SUCCESS -threat on MISS

        --CREATURE
        onDamage:
            Run handler only on hit or absorb
        onDebuff:
            Run handler even on resist
        onCast:
            Run handler on cast
    }
]]

--[[ Zero threat ]]--
--Mana Tide
s[17360]  = {ignored=true}
s[17355]  = {ignored=true}
s[16191]  = {ignored=true}

--Mana Spring
s[24853]  = {ignored=true}
s[10494]  = {ignored=true}
s[10493]  = {ignored=true}
s[10491]  = {ignored=true}
s[5677]   = {ignored=true}


-- Fetish of the Sand Reaver (26400 Arcane Shroud -70%)
s[26400]  = {handler = ATM.BuffThreatMod({[127] = 0.3})}

-- Fungal Bloom - Loatheb (29232 0%)
s[29232]  = {handler = ATM.BuffThreatMod({[127] = 0})}

-- Burning Adrenaline -75%; Don't believe this is real, is not hidden from combat log and doesn't show up in combat log
-- s[24701]  = {handler = ATM.BuffThreatMod({[127] = 0.25})}

-- Frostfire Regalia (Mage T3) 8 set bonus (28762 Not There 0%)
s[28762]  = {handler = ATM.BuffThreatMod({[127] = 0})}

-- Eye of Diminution (28862 -35%)
s[28862]  = {handler = ATM.BuffThreatMod({[127] = 0.65})}

--Paladin Salvation
s[25895]  = {handler = ATM.BuffThreatMod({[127] = 0.7})} --Blessing of Salvation
s[1038]   = {handler = ATM.BuffThreatMod({[127] = 0.7})} --Greater Blessing of Salvation


--[[ Season of Discovery ]]--

--Void Madness (Void-Touched leather gloves)
s[429868] = {handler = ATM.BuffThreatMod({[127] = 1.21})}
s[429867] = {handler = ATM.BuffThreatMod({[127] = 1.21})}

--Planar Shift (Void-Touched cloth boots)
s[428489] = {
    threat = -1000,
    handler = ATM.TemporaryThreat
}

--Curse of Vulnerability (Void-Touched mail chest)
s[427143] = {onDebuff=true, threat=5}

-- Corrupted Salv
-- s[444444] = {handler = ATM.BuffThreatMod({[127] = 1.425})}
