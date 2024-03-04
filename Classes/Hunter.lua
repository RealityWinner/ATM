if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))
local s = ATM.spells

local prototype = CreateFromMixins(ATM.Player, {
    class = "HUNTER",
})
prototype.color = "|c"..RAID_CLASS_COLORS[prototype.class].colorStr
ATM.playerMixins[prototype.class] = prototype

function prototype:scanTalents()
    -- ATM:print("HUNTER:scanTalents")
end

--Distracting Shot
s[15632] = {onCast=true,threat=600}
s[15631] = {onCast=true,threat=465}
s[15630] = {onCast=true,threat=350}
s[15629] = {onCast=true,threat=250}
s[14274] = {onCast=true,threat=160}
s[20736] = {onCast=true,threat=110}
