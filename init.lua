-----------------------------
--	Init
-----------------------------
local parent, ns = ...
ns[1] = {} -- ATM, Functions
ns[2] = {} -- C, Config
ns[3] = {} -- L, Localization

-----------------------------
-- AddOn Info
-----------------------------
ATM = ns[1]
ATM.addonName	= parent
ATM.version	= C_AddOns.GetAddOnMetadata(parent, "Version")
ATM.locale	= GetLocale()



-- Helpers
local band = bit.band
function ATM.band(value, mask)
	return band(value, mask) == mask
end

function ATM.starts_with(str, start)
	return str:sub(1, #start) == start
end
function ATM.ends_with(str, ending)
	return str:sub(-#ending, -1) == ending
end

function ATM.insert(list, ...)
	for _,v in ipairs({...}) do
	  list[#list+1] = v
	end
  end
function ATM.toTrue(tbl)
	local out = {}
	for _,v in pairs(tbl) do
		out[v] = true
	end
	return out
end


local function SpellIDPredicate(auraIDToFind, _, _, ...)
	return auraIDToFind == select(10, ...);
end
function ATM.FindAuraByID(spellID, unit, filter)
	return AuraUtil.FindAura(SpellIDPredicate, unit, filter, spellID)
end

local function SpellIDsPredicate(auraIDToFind, _, _, ...)
	return auraIDsToFind[select(10, ...)]
end
function ATM.FindAuraByIDs(spellIDs, unit, filter)
	return AuraUtil.FindAura(SpellIDsPredicate, unit, filter, ATM.toTrue(spellIDs))
end