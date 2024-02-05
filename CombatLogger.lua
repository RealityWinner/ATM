if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))


---------------------------------------------------------------------------------------------------------------
-- Blizzard Combat Log constants, in case your addon loads before Blizzard_CombatLog or it's disabled by the user
---------------------------------------------------------------------------------------------------------------

local COMBATLOG_OBJECT_AFFILIATION_MINE		= COMBATLOG_OBJECT_AFFILIATION_MINE		or 0x00000001
local COMBATLOG_OBJECT_AFFILIATION_PARTY	= COMBATLOG_OBJECT_AFFILIATION_PARTY	or 0x00000002
local COMBATLOG_OBJECT_AFFILIATION_RAID		= COMBATLOG_OBJECT_AFFILIATION_RAID		or 0x00000004
local COMBATLOG_OBJECT_AFFILIATION_OUTSIDER	= COMBATLOG_OBJECT_AFFILIATION_OUTSIDER	or 0x00000008
-- Reaction
local COMBATLOG_OBJECT_REACTION_FRIENDLY	= COMBATLOG_OBJECT_REACTION_FRIENDLY	or 0x00000010
local COMBATLOG_OBJECT_REACTION_NEUTRAL		= COMBATLOG_OBJECT_REACTION_NEUTRAL		or 0x00000020
local COMBATLOG_OBJECT_REACTION_HOSTILE		= COMBATLOG_OBJECT_REACTION_HOSTILE		or 0x00000040
-- Ownership
local COMBATLOG_OBJECT_CONTROL_PLAYER		= COMBATLOG_OBJECT_CONTROL_PLAYER		or 0x00000100
local COMBATLOG_OBJECT_CONTROL_NPC			= COMBATLOG_OBJECT_CONTROL_NPC			or 0x00000200
-- Unit type
local COMBATLOG_OBJECT_TYPE_PLAYER			= COMBATLOG_OBJECT_TYPE_PLAYER			or 0x00000400
local COMBATLOG_OBJECT_TYPE_NPC				= COMBATLOG_OBJECT_TYPE_NPC				or 0x00000800
local COMBATLOG_OBJECT_TYPE_PET				= COMBATLOG_OBJECT_TYPE_PET				or 0x00001000
local COMBATLOG_OBJECT_TYPE_GUARDIAN		= COMBATLOG_OBJECT_TYPE_GUARDIAN		or 0x00002000
local COMBATLOG_OBJECT_TYPE_OBJECT			= COMBATLOG_OBJECT_TYPE_OBJECT			or 0x00004000


-- Object type constants
local bor = bit.bor
local COMBATLOG_FILTER_ME = bor(
						COMBATLOG_OBJECT_AFFILIATION_MINE,
						COMBATLOG_OBJECT_REACTION_FRIENDLY,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_TYPE_PLAYER
						)

local COMBATLOG_FILTER_MINE = bor(
						COMBATLOG_OBJECT_AFFILIATION_MINE,
						COMBATLOG_OBJECT_REACTION_FRIENDLY,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_TYPE_PLAYER,
						COMBATLOG_OBJECT_TYPE_OBJECT
						)

local COMBATLOG_FILTER_MY_PET = bor(
						COMBATLOG_OBJECT_AFFILIATION_MINE,
						COMBATLOG_OBJECT_REACTION_FRIENDLY,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_TYPE_GUARDIAN,
						COMBATLOG_OBJECT_TYPE_PET
						)

local COMBATLOG_FILTER_FRIENDLY_UNITS = bor(
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

local COMBATLOG_FILTER_HOSTILE_UNITS = bor(
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

local COMBATLOG_FILTER_NEUTRAL_UNITS = bor(
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
function CombatLogger:UNIT_AURA(unit)
	local unit = ATM:GetUnit(UnitGUID(unit))
	if unit and unit.UNIT_AURA then
		unit:UNIT_AURA()
	end

	--TODO rewrite this to be better and track all players

	-- if unitTarget == "player" then
	-- 	--Only track Tranq Air on local player
	-- 	for i=1,32 do
	-- 		local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID = UnitBuff("player", i)
	-- 		if not spellID then break end
	-- 		if spellID == 25909 then
	-- 			--TODO apply the shaman talented threat reduction (20% -> 21.5% -> 23%)
	-- 			ATM:player().threatMods["Tranq Air"] = {[127] = 0.8}
	-- 			return
	-- 		end
	-- 	end

	-- 	--Not found, nil out
	--  ATM:player().threatMods["Tranq Air"] = nil
	-- end
end


function CombatLogger:COMBAT_LOG_EVENT_UNFILTERED(...)
	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, _, spellName, spellID = ...
	if C.debug and type(spellName) ~= 'string' then
		spellName = "Melee"
	end

	-- Ignored events
	if subevent == "PARTY_KILL" then return end

	-- Wipe player threat if they died.
	-- Technically threat is not wiped when a player dies but this solves a lot of problems and the threat API will save us if they are battle rez'd :)
	if subevent == "UNIT_DIED" then
		local unit = ATM:GetUnit(destGUID, true)
		if unit then
			unit:MarkDead()
		end
		return
	end

	-- Ignore hostile player targets
	-- This will miss global threat edge cases like Dispel/Purge MC'd friendlies but API will save us :)
	if ATM.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE + COMBATLOG_OBJECT_CONTROL_PLAYER) then return end

	
	if ATM.band(sourceFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY + COMBATLOG_OBJECT_CONTROL_PLAYER) then
		local spellData = ATM.spells[spellID]
		if spellData then
			if spellData.handler then
				return spellData.handler(player, ...)
			end
			if spellData.ignored then return end
		end

		local unit = ATM:GetUnit(sourceGUID)
		if not unit then return end --Should never happen...

		if C.debug then
			unit.currentEvent = {"[", unit.color, unit.name, "|r] ", tostring(spellName)}
		end

		local f = unit[subevent]
		if f then
			return f(unit, ...)
		end
	end


	if (subevent == "SPELL_ENERGIZE" or subevent == "SPELL_PERIODIC_ENERGIZE") then
		local unit = ATM:GetUnit(destGUID)
		if not unit then return end
		if C.debug then
			unit.currentEvent = {"[", unit.color, unit.name, "|r] ", tostring(spellName)}
		end

		local spellData = ATM.spells[spellID]
		if spellData and spellData.ignored then
			return
		end

		local f = unit[subevent]
		if f then
			return f(unit, ...)
		end
	end


	if ATM.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE + COMBATLOG_OBJECT_CONTROL_NPC) then
		local unit = ATM:GetUnit(sourceGUID)
		if not unit then return end

		-- Any actions towards a player will be considered hostile (AMERICCAAAAAAA)
		if ATM.band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) then
			unit:setCombat(true)
		end
		
		local f = unit[subevent]
		if f then
			return f(unit, ...)
		end
	end
end


ATM.CombatLogger = CombatLogger