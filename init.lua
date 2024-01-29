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