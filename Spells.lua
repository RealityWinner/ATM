if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))

ATM.spells = {
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
    [17360] = {ignored=true},
    [17355] = {ignored=true},
    [16191] = {ignored=true},

    --Mana Spring
    [24853] = {ignored=true},
    [10494] = {ignored=true},
    [10493] = {ignored=true},
    [10491] = {ignored=true},
     [5677] = {ignored=true},


    -- Fetish of the Sand Reaver (26400 Arcane Shroud -70%)
    [26400] = {handler = ATM.BuffThreatMod({[127] = 0.3})},

    -- Fungal Bloom - Loatheb (29232 0%)
    [29232] = {handler = ATM.BuffThreatMod({[127] = 0})},

    -- Burning Adrenaline -75%; Don't believe this is real, is not hidden from combat log and doesn't show up in combat log
    -- [24701] = {handler = ATM.BuffThreatMod({[127] = 0.25})},

    -- Frostfire Regalia (Mage T3) 8 set bonus (28762 Not There 0%)
    [28762] = {handler = ATM.BuffThreatMod({[127] = 0})},
    
    -- Eye of Diminution (28862 -35%)
    [28862] = {handler = ATM.BuffThreatMod({[127] = 0.65})},

    --Paladin Salvation
    [25895] = {handler = ATM.BuffThreatMod({[127] = 0.7})}, --Blessing of Salvation
     [1038] = {handler = ATM.BuffThreatMod({[127] = 0.7})}, --Greater Blessing of Salvation


    --[[ Season of Discovery ]]--

    --Void Madness (Void-Touched leather gloves)
    [429868] = {handler = ATM.BuffThreatMod({[127] = 1.21})},
    [429867] = {handler = ATM.BuffThreatMod({[127] = 1.21})},

    --Planar Shift (Void-Touched cloth boots)
    [428489] = {
        threat = -1000,
        handler = ATM.TemporaryThreat
    },

    -- Corrupted Salv
    -- [444444] = {handler = ATM.BuffThreatMod({[127] = 1.425})},
}







-- [[ NPCs ]]--


-- Ouro - Sand Blast
ATM.spells[26102] = {
    onDebuff = true,
    handler = ATM.NPC.FullThreatDrop
}


-- When casting whirlwind is a global threat wipe
-- Satura's Whirlwind removes all threat from current tank (when hit?)
local function whirlwind(self, ...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _ = ...
    local spellID, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
    ATM:print("ATM:NPC:AQ40:sartura:whirlwind", subevent, sourceGUID, spellName, spellID)

    if subevent == "SPELL_AURA_REMOVED" then
        self:GlobalThreatWipe() --Pretty sure
    elseif self:getID() == 15516 and subevent == "SPELL_DAMAGE" and destGUID == self.tankGUID then
        self:FullThreatDrop(...)
    end
end

-- Sartura (Guard) - Whirlwind
ATM.spells[26083] = {
    onDamage = true,
    handler = whirlwind
}
ATM.spells[26084] = {
    onDamage = true,
    handler = whirlwind
}
