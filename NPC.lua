if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))


ATM.NPCs = {}

local NPC = CreateFromMixins(ATM.Unit, {
    ID = 0,
    GUID = "",
    subGUID = "",
    isCombat = false,
    isCC = false,
    seenAPI = false,
    unit = nil,
    name = nil,
    isNPC = true,
})

function NPC:getID()
    return self.ID
end
function NPC:setID(id)
    self.ID = id
end

function NPC:getGUID()
    return self.guid
end
function NPC:setGUID(guid)
    self.guid = guid
end

function NPC:getSubGUID()
    return self.subGUID
end
function NPC:setSubGUID(subGUID)
    self.subGUID = subGUID
end

function NPC:getName()
    return self.name
end
function NPC:setName(id)
    self.name = id
end

function NPC:getCombat()
    return self.isCombat
end
function NPC:setCombat(isCombat, skipUpdate)
    if self.isCombat and not isCombat then
        C_Timer.After(C.npcCombatDropTime, function()
            if not self.isCombat then
                self:GlobalThreatWipe()
            end
        end)
        if C.debug then
            ATM:print("-combat", self.guid)
        end
    end
    if not self.isCombat and isCombat then
        if not skipUpdate then
            self.lastUpdate = ATM:GetTime()
        end
        if C.debug then
            ATM:print("+combat", self.guid)
        end
    end
    self.isCombat = isCombat
end

ATM.NPC = NPC


-- DEBUFF handlers, threat drops like Brood Power: Green where you can resist or get debuffed
function NPC:SPELL_AURA(...)
    local spellID, spellName = select(12, ...)
    --Checking if we care about the spell
    local spellData = ATM.spells[spellID]
	if not spellData or spellData.type ~= "DEBUFF" then
		return
    end
    ATM:print("NPC SPELL_AURA", spellName)

    spellData.handler(self, ...)
end
NPC.SPELL_AURA_APPLIED = NPC.SPELL_AURA
NPC.SPELL_AURA_REFRESH = NPC.SPELL_AURA
NPC.SPELL_AURA_APPLIED_DOSE = NPC.SPELL_AURA


-- DAMAGE handlers, used for targetted damage threat drops like knock away
function NPC:SPELL_DAMAGE(...)    
    local spellID, spellName = select(12, ...)
    --Checking if we care about the spell
    local spellData = ATM.spells[spellID]
	if not spellData or spellData.type ~= "DAMAGE" then
		return
    end
    ATM:print("NPC SPELL_DAMAGE", spellName)

    spellData.handler(self, ...)
end

-- CAST handlers, used for targetted casted threat drops like Onyxia's Fireballs or global wipes or Nets w/ Net Guard active
function NPC:SPELL_CAST_SUCCESS(...)
    local spellID, spellName = select(12, ...)
    --Checking if we care about the spell
    local spellData = ATM.spells[spellID]
	if not spellData or spellData.type ~= "CAST" then
		return
    end
    ATM:print("NPC SPELL_CAST_SUCCESS", spellName)

    spellData.handler(self, ...)
end

-- DEBUFF types can resist yet still cause threat drops. DAMAGE types can be absorbed yet still drop but not miss/dodge/parry.
function NPC:SPELL_MISSED(...)
    local spellID, spellName = select(12, ...)
    --Checking if we care about the spell
    local spellData = ATM.spells[spellID]
	if not spellData then
		return
    end
    ATM:print("NPC SPELL_MISSED", spellName)

    if spellData.type == "DEBUFF" then
        return spellData.handler(self, ...)
    end
    if spellData.type == "DAMAGE" then
        local missType = select(15, ...)
        if missType == "ABSORB" then
            return spellData.handler(self, ...)
        end
    end
end

--[[ TESTING ]]--
--Earthborer
-- s[18070] = {onCast=true,handler=ATM.NPC.QuarterThreatDrop}