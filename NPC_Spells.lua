if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))
local s = ATM.spells


--[[ Generic ]]--

--Knock Away
s[18945] = {onDamage=true, threat=ATM.NPC.HalfThreatDrop}
s[18670] = {onDamage=true, threat=ATM.NPC.HalfThreatDrop}
s[11130] = {onDamage=true, threat=ATM.NPC.HalfThreatDrop}




--[[ Dungeons ]]--

--Ramstein - Knockout
s[17307] = {onCast=true, threat=ATM.NPC.HalfThreatDrop}
--Electrified Net
s[11820] = {onCast=true, threat=ATM.NPC.HalfThreatDrop}



--[[ World Bosses ]]--

--Azuregoes - Arcane Vacuum
s[21147] = {onCast=true, threat=ATM.NPC.GlobalThreatWipe}
--^ This is wrong but there is no way to check if other players are in range. Threat API will save us.


--[[ Molten Core ]]--
--Lava Annihilator --TODO
ATM.NPCs[11665] = {SWING_DAMAGE = ATM.NPC.FullThreatDrop}

--Shazzrah - Gate of Shazzrah
s[23138] = {onCast=true, threat=ATM.NPC.GlobalThreatWipe}

--Ragnaros - Wrath of Ragnaros
s[20566] = {onCast=true, threat=ATM.NPC.GlobalThreatWipe}
ATM.NPCs[11502] = {meleeOnly=true}


--[[ BWL ]]--

--Razorgore - Mind Exhaustion
local function MindExhaustion(...)
	local _, subevent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _ = ...
    if subevent == "SPELL_AURA_APPLIED" then
        ATM:wipeThreat(sourceGUID)
        ATM:GetPlayer(destGUID):setThreat(449700, sourceGUID)
    end
end
s[23958] = {handler=MindExhaustion}

--Wing Buffet
s[23339] = {threat=ATM.NPC.HalfThreatDrop}

-- Ignore healing done by Shadow of Ebonroc
s[23394] = {ignored=true}

-- Brood Power: Green
s[22289] = {threat=ATM.NPC.HalfThreatDrop}

-- Chromaggus - Time Lapse
s[23311] = {threat=ATM.NPC.QuarterThreatDrop}




--[[ AQ40 ]]--

-- Ouro - Sand Blast
s[26102] = {handler=ATM.NPC.FullThreatDrop}


-- When done casting whirlwind is a global threat wipe
local function whirlwindBuff(self, ...)
    local _, subevent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _ = ...
    if subevent == "SPELL_AURA_REMOVED" then
        self:GlobalThreatWipe() --Pretty sure
    end
end

-- Sartura - Whirlwind
s[26038] = {handler=whirlwindBuff} --Whirlwind buff ends
s[26084] = {onDamage=true, threat=ATM.NPC.FullThreatDrop} --Whirlwind spell damage



--[[ Naxx ]]--

-- Noth - Blink
s[29211] = {onCast=true, threat=ATM.NPC.GlobalThreatWipe}

-- Chains of Kel'Thuzad
s[28410] = {onCast=true, threat=ATM.NPC.GlobalThreatWipe}



--[[ Onyxia ]]--

--Knock Away
s[19633] = {onCast=true, threat=ATM.NPC.QuarterThreatDrop}

--Fireball
s[18392] = {onCast=true, threat=ATM.NPC.FullThreatDrop}



--[[ ZG ]]--
--Hakkar - Aspect of Arlokk
s[24690] = {onCast=true, threat=ATM.NPC.FullThreatDrop}
--Hakkar - Cause Insanity
s[24327] = {isCC=true}


--[[ Season of Discovery ]]--

--Ghamoo'ra - Aqua Shell
s[414370] = {onCast=true, threat=ATM.NPC.FullThreatDrop}

--Kelris - Sleep
s[423135] = {handler=function(self, ...)
    local _, subevent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _ = ...
    local player = ATM:GetPlayer(destGUID)
    if player then
        player:wipeThreat()
    end
end}
