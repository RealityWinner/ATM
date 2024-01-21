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
ns[1].addonName	= parent
ns[1].version	= C_AddOns.GetAddOnMetadata(parent, "Version")
ns[1].locale	= GetLocale()


-- Add to Global namespace
ATM = ns[1]


-- Helpers
function ATM.starts_with(str, start)
	return str:sub(1, #start) == start
end
function ATM.ends_with(str, ending)
	return str:sub(-#ending, -1) == ending
end
function ATM.toTrue(tbl)
	local out = {}
	for _,v in pairs(tbl) do
		out[v] = true
	end
	return out
end