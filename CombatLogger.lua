if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))


---------------------------------------------------------------------------------------------------------------
-- Blizzard Combat Log constants, in case your addon loads before Blizzard_CombatLog or it's disabled by the user
---------------------------------------------------------------------------------------------------------------

local COMBATLOG_OBJECT_AFFILIATION_MINE		= COMBATLOG_OBJECT_AFFILIATION_MINE		or 0x00000001
local COMBATLOG_OBJECT_AFFILIATION_PARTY	= COMBATLOG_OBJECT_AFFILIATION_PARTY	or 0x00000002
local COMBATLOG_OBJECT_AFFILIATION_RAID		= COMBATLOG_OBJECT_AFFILIATION_RAID		or 0x00000004
local COMBATLOG_OBJECT_AFFILIATION_OUTSIDER	= COMBATLOG_OBJECT_AFFILIATION_OUTSIDER	or 0x00000008
local COMBATLOG_OBJECT_AFFILIATION_MASK		= COMBATLOG_OBJECT_AFFILIATION_MASK		or 0x0000000F
-- Reaction
local COMBATLOG_OBJECT_REACTION_FRIENDLY	= COMBATLOG_OBJECT_REACTION_FRIENDLY	or 0x00000010
local COMBATLOG_OBJECT_REACTION_NEUTRAL		= COMBATLOG_OBJECT_REACTION_NEUTRAL		or 0x00000020
local COMBATLOG_OBJECT_REACTION_HOSTILE		= COMBATLOG_OBJECT_REACTION_HOSTILE		or 0x00000040
local COMBATLOG_OBJECT_REACTION_MASK		= COMBATLOG_OBJECT_REACTION_MASK		or 0x000000F0
-- Ownership
local COMBATLOG_OBJECT_CONTROL_PLAYER		= COMBATLOG_OBJECT_CONTROL_PLAYER		or 0x00000100
local COMBATLOG_OBJECT_CONTROL_NPC			= COMBATLOG_OBJECT_CONTROL_NPC			or 0x00000200
local COMBATLOG_OBJECT_CONTROL_MASK			= COMBATLOG_OBJECT_CONTROL_MASK			or 0x00000300
-- Unit type
local COMBATLOG_OBJECT_TYPE_PLAYER			= COMBATLOG_OBJECT_TYPE_PLAYER			or 0x00000400
local COMBATLOG_OBJECT_TYPE_NPC				= COMBATLOG_OBJECT_TYPE_NPC				or 0x00000800
local COMBATLOG_OBJECT_TYPE_PET				= COMBATLOG_OBJECT_TYPE_PET				or 0x00001000
local COMBATLOG_OBJECT_TYPE_GUARDIAN		= COMBATLOG_OBJECT_TYPE_GUARDIAN		or 0x00002000
local COMBATLOG_OBJECT_TYPE_OBJECT			= COMBATLOG_OBJECT_TYPE_OBJECT			or 0x00004000
local COMBATLOG_OBJECT_TYPE_MASK			= COMBATLOG_OBJECT_TYPE_MASK			or 0x0000FC00

-- Special cases (non-exclusive)
local COMBATLOG_OBJECT_TARGET				= COMBATLOG_OBJECT_TARGET				or 0x00010000
local COMBATLOG_OBJECT_FOCUS				= COMBATLOG_OBJECT_FOCUS				or 0x00020000
local COMBATLOG_OBJECT_MAINTANK				= COMBATLOG_OBJECT_MAINTANK				or 0x00040000
local COMBATLOG_OBJECT_MAINASSIST			= COMBATLOG_OBJECT_MAINASSIST			or 0x00080000
local COMBATLOG_OBJECT_RAIDTARGET1			= COMBATLOG_OBJECT_RAIDTARGET1			or 0x00100000
local COMBATLOG_OBJECT_RAIDTARGET2			= COMBATLOG_OBJECT_RAIDTARGET2			or 0x00200000
local COMBATLOG_OBJECT_RAIDTARGET3			= COMBATLOG_OBJECT_RAIDTARGET3			or 0x00400000
local COMBATLOG_OBJECT_RAIDTARGET4			= COMBATLOG_OBJECT_RAIDTARGET4			or 0x00800000
local COMBATLOG_OBJECT_RAIDTARGET5			= COMBATLOG_OBJECT_RAIDTARGET5			or 0x01000000
local COMBATLOG_OBJECT_RAIDTARGET6			= COMBATLOG_OBJECT_RAIDTARGET6			or 0x02000000
local COMBATLOG_OBJECT_RAIDTARGET7			= COMBATLOG_OBJECT_RAIDTARGET7			or 0x04000000
local COMBATLOG_OBJECT_RAIDTARGET8			= COMBATLOG_OBJECT_RAIDTARGET8			or 0x08000000
local COMBATLOG_OBJECT_NONE					= COMBATLOG_OBJECT_NONE					or 0x80000000
local COMBATLOG_OBJECT_SPECIAL_MASK			= COMBATLOG_OBJECT_SPECIAL_MASK			or 0xFFFF0000

-- Object type constants
local COMBATLOG_FILTER_ME = bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_MINE,
						COMBATLOG_OBJECT_REACTION_FRIENDLY,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_TYPE_PLAYER
						)

local COMBATLOG_FILTER_MINE = bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_MINE,
						COMBATLOG_OBJECT_REACTION_FRIENDLY,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_TYPE_PLAYER,
						COMBATLOG_OBJECT_TYPE_OBJECT
						)

local COMBATLOG_FILTER_MY_PET = bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_MINE,
						COMBATLOG_OBJECT_REACTION_FRIENDLY,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_TYPE_GUARDIAN,
						COMBATLOG_OBJECT_TYPE_PET
						)

local COMBATLOG_FILTER_FRIENDLY_UNITS = bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_PARTY,
						COMBATLOG_OBJECT_AFFILIATION_RAID,
						COMBATLOG_OBJECT_AFFILIATION_OUTSIDER,
						COMBATLOG_OBJECT_REACTION_FRIENDLY,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_CONTROL_NPC,
						COMBATLOG_OBJECT_TYPE_PLAYER,
						COMBATLOG_OBJECT_TYPE_NPC,
						COMBATLOG_OBJECT_TYPE_PET,
						COMBATLOG_OBJECT_TYPE_GUARDIAN,
						COMBATLOG_OBJECT_TYPE_OBJECT
						)

local COMBATLOG_FILTER_HOSTILE_UNITS = bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_PARTY,
						COMBATLOG_OBJECT_AFFILIATION_RAID,
						COMBATLOG_OBJECT_AFFILIATION_OUTSIDER,
						COMBATLOG_OBJECT_REACTION_NEUTRAL,
						COMBATLOG_OBJECT_REACTION_HOSTILE,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_CONTROL_NPC,
						COMBATLOG_OBJECT_TYPE_PLAYER,
						COMBATLOG_OBJECT_TYPE_NPC,
						COMBATLOG_OBJECT_TYPE_PET,
						COMBATLOG_OBJECT_TYPE_GUARDIAN,
						COMBATLOG_OBJECT_TYPE_OBJECT
						)

local COMBATLOG_FILTER_NEUTRAL_UNITS = bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_PARTY,
						COMBATLOG_OBJECT_AFFILIATION_RAID,
						COMBATLOG_OBJECT_AFFILIATION_OUTSIDER,
						COMBATLOG_OBJECT_REACTION_NEUTRAL,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_CONTROL_NPC,
						COMBATLOG_OBJECT_TYPE_PLAYER,
						COMBATLOG_OBJECT_TYPE_NPC,
						COMBATLOG_OBJECT_TYPE_PET,
						COMBATLOG_OBJECT_TYPE_GUARDIAN,
						COMBATLOG_OBJECT_TYPE_OBJECT
						)

local COMBATLOG_FILTER_EVERYTHING =	COMBATLOG_FILTER_EVERYTHING or 0xFFFFFFFF

---------------------------------------------------------------------------------------------------------------
-- End Combat Log constants
---------------------------------------------------------------------------------------------------------------

local CombatLogger = {}
function CombatLogger:OnInitialize()
    -- print('CombatLogger OnInitialize')
	CombatLogger.frame = CreateFrame("Frame")
	CombatLogger.frame:SetScript("OnEvent", function(self, event, ...)
		if event == "COMBAT_LOG_EVENT_UNFILTERED" then
			return CombatLogger[event](CombatLogger, CombatLogGetCurrentEventInfo())
		else
			return CombatLogger[event] and CombatLogger[event](CombatLogger, ...)
		end
	end)
end


function CombatLogger:Enable()
	-- print('CombatLogger:Enable')

	self.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	if UnitFactionGroup("player") == "Horde" then
		self.frame:RegisterEvent("UNIT_AURA")
	end
end

function CombatLogger:Disable()
	-- print('CombatLogger:Disable')

	self.frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self.frame:UnregisterEvent("UNIT_AURA")
end


-- UNIT_AURA triggers for self, party/raid members, targets, nameplate targets
function CombatLogger:UNIT_AURA(unitTarget)
	--TODO rewrite this to be better and track all players

	-- if unitTarget == "player" then
	-- 	--Only track Tranq Air on local player
	-- 	for i=1,32 do
	-- 		local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID = UnitBuff("player", i)
	-- 		if not spellID then break end
	-- 		if spellID == 25909 then
	-- 			--TODO apply the shaman talented threat reduction (20% -> 21.5% -> 23%)
	-- 			ATM:player().threatBuffs["Tranq Air"] = {[127] = 0.8}
	-- 			return
	-- 		end
	-- 	end

	-- 	--Not found, nil out
	--  ATM:player().threatBuffs["Tranq Air"] = nil
	-- end
end


function CombatLogger:COMBAT_LOG_EVENT_UNFILTERED(...)
	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, _, spellName, spellID = ...
	-- print(timestamp, subevent, sourceName, destName, spellName)
	if C.debug and type(spellName) ~= 'string' then
		spellName = "Melee"
	end

	-- Ignored events
	if subevent == "PARTY_KILL" then
		return
	end

	if bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
		-- Ignore self and PVP damage
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 and ATM.ends_with(subevent, "_DAMAGE") then
			return
		end

		local player = ATM:getPlayer(sourceGUID)
		if not player then return end
		if C.debug then
			player.currentEvent = "["..player.color..player.name.."|r] "..tostring(spellName)
		end

		local spellData = ATM.spells[spellID]
		if spellData then
			if spellData.handler then
				return spellData.handler(player, ...)
			end
			if spellData.ignored then
				return
			end
		end

		local p = player[subevent]
		if p then
			return p(player, ...)
		end
	end

	if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 and (ATM.ends_with(subevent, "_ENERGIZE") or ATM.starts_with(subevent, "ENCHANT_")) then
		local player = ATM:getPlayer(destGUID)
		if not player then return end
		if C.debug then
			player.currentEvent = "["..player.color..player.name.."|r] "..tostring(spellName)
		end

		local spellData = player.spells[spellName]
		if spellData and spellData.ignored then
			return
		end

		local p = player[subevent]
		if p then
			return p(player, ...)
		end
	end


	if bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_NPC) > 0 then
		local enemy = ATM:getEnemy(sourceGUID)
		if not enemy then return end

		-- Any actions towards a player will be considered hostile (AMERICCAAAAAAA)
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 and not ATM.starts_with(subevent, "SPELL_AURA_") then
			enemy:setCombat(true)
		end
		
		local e = enemy[subevent]
		if e then
			return e(enemy, ...)
		end
	end


	if subevent == "UNIT_DIED" then
		-- Wipe player threat if they died
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
			local player = ATM:getPlayer(destGUID)
			if player then
				player:setCombat(false)
			end
			return
		end
		
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_NPC) > 0 then
			-- when a mob dies mark as dead for future GC when OOC
			ATM:MarkDead(timestamp, destGUID)
			return
		end
	end
end


ATM.CombatLogger = CombatLogger