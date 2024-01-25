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
    ccDebuffs = {},
    unit = nil,
    name = nil,
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

function NPC:getCC()
    return self.isCC
end
function NPC:setCC(spellName, isCC)
    self.ccDebuffs[spellName] = isCC

    local len = 0
    for name,active in pairs(self.ccDebuffs) do
        len = len + (active and 1 or 0)
    end

    ATM:print("NPC:setCC", spellName, isCC, len)

    if C.debug then
        if isCC and not self.isCC then
            ATM:print("+cc", self.guid)
        end
        if not isCC and self.isCC and len == 0 then
            ATM:print("-cc", self.guid)
        end
    end

    self.isCC = len > 0
end

function NPC:GlobalThreatWipe()
    ATM:print("ATM:NPC:GlobalThreatWipe", self.name or "", self.guid)
    ATM:wipeThreat(self.guid)
end
function NPC:FullThreatDrop(...)
    local destGUID = select(8, ...)
    self:ReduceThreat(destGUID, 1.00)
end
function NPC:HalfThreatDrop(...)
    local destGUID = select(8, ...)
    self:ReduceThreat(destGUID, 0.50)
end
function NPC:QuarterThreatDrop(...)
    local destGUID = select(8, ...)
    self:ReduceThreat(destGUID, 0.25)
end
function NPC:ZeroThreatDrop(...)
end
function NPC:ReduceThreat(destGUID, amountPct)
    local player = ATM:getPlayer(destGUID)
    if not player then return end

    player:_addThreat(player:getThreat(self.guid) * -amountPct, self.guid)
end

NPC.spells = {
    --[[
        The spell name is the key and gets replaced by a localized version of the spell name retrieved by GetSpellInfo(ranks[1])
        ["Spell name"] = {
            ids:
                The spell IDs of the ability
            type:
                CAST: Call handler on initial cast event
                DAMAGE: Call handler on damage events (including absorb)
                DEBUFF: Call handler only on aura event (applied, refresh, +dose), this includes resists/immunes
            handler:
                The function used for handling the spell cast, built in handlers are:
                    ATM.NPC.GlobalThreatWipe - wipes threat for the entire raid
                    ATM.NPC.FullThreatDrop - reduces targets threat by 100%
                    ATM.NPC.HalfThreatDrop - reduces targets threat by 50%
                    ATM.NPC.QuarterThreatDrop - reduces targets threat by 25%
                    ATM.NPC.ZeroThreatDrop - do nothing
        }
    ]]--

    --Generic Knock Away
    ["Knock Away"] = {
        id = {10101},
        type = "DAMAGE",
        handler = NPC.HalfThreatDrop
    },
    ["Net"] = {
        id = {6533},
        type = "CAST", --CONFIRMED even w/ Net Guard
        handler = NPC.HalfThreatDrop,
    },
}
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



ATM._enemies = {}
local function NPCIndex(table, key)
    local enemy = ATM:newEnemy(key);
    table[key] = enemy
    return enemy
end
setmetatable(ATM._enemies, {
    __index = NPCIndex,
    __mode = "k", --weak
});

function ATM:getEnemy(enemyGUID, skipCreate)
    local enemy = rawget(self._enemies, enemyGUID)
    if enemy then enemy.lastAccess = self:GetTime() end
    if enemy or skipCreate then return enemy end
    return self._enemies[enemyGUID]
end

function ATM:newEnemy(enemyGUID)
    local tag, _, _, _, _, npcID, spawn_uid = strsplit('-', enemyGUID)
    if tag ~= "Creature" then
        return nil
    end

    -- self:print("[+enemy]", enemyGUID, npcID, spawn_uid)
    local enemy = CreateFromMixins(ATM.NPC, self.NPCs[tonumber(npcID)] or {})
    enemy:setID(npcID)
    enemy:setGUID(enemyGUID)
    enemy:setSubGUID(spawn_uid)
    return enemy
end

function ATM:enemies()
    return self._enemies
end


-- -- TESTING --
-- local Earthborer = {
--     spells = {
--         ["Earthborer Acid"] = {
--             id = 18070,
--             type = "CAST",
--             handler = ATM.NPC.QuarterThreatDrop
--         }
--     }
-- }
-- ATM.NPCs[11320] = Earthborer