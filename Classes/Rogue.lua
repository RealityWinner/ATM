if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))
local s = ATM.spells

local prototype = {
    class = "ROGUE",
}
prototype.color = "|c"..RAID_CLASS_COLORS[prototype.class].colorStr
ATM.playerMixins[prototype.class] = prototype

function prototype:scanTalents()
    -- ATM:print("ROGUE:scanTalents")
    
    self.threatMods["Rogue"] = {[127] = 0.71}
end


--Feint
s[25302] = {handler=ATM.Player.levelBasedThreat(-800, -1, 60, 60)} --maxLevel is technically 70
s[11303] = {handler=ATM.Player.levelBasedThreat(-600, -1, 52, 60)} --maxLevel is technically 62
s[8637]  = {handler=ATM.Player.levelBasedThreat(-390, -1, 40, 50)}
s[6768]  = {handler=ATM.Player.levelBasedThreat(-240, -1, 28, 38)}
s[1966]  = {handler=ATM.Player.levelBasedThreat(-150, -1, 16, 26)}

--Vanish
s[1857] = {handler=ATM.Player.wipeThreat}
s[1856] = {handler=ATM.Player.wipeThreat}

--Cheap Shot
s[1833] = {isCC=true}

--Kidney Shot
s[8643] = {isCC=true,onDebuff=true,threat=100}
s[408]  = {isCC=true,onDebuff=true,threat=50}

--Gouge
s[11286] = {isCC=true}
s[11285] = {isCC=true}
s[8629]  = {isCC=true}
s[1777]  = {isCC=true}
s[1776]  = {isCC=true}

--Blind
s[2094] = {isCC=true,onDebuff=true,threat=68}


    --[[ Season of Discovery ]]--
--Tease
s[410412] = {handler=ATM.Taunt}
