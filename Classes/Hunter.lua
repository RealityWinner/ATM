if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))


local prototype = {
    class = "HUNTER",
}
prototype.color = "|c"..RAID_CLASS_COLORS[prototype.class].colorStr
ATM.playerMixins[prototype.class] = prototype

function prototype:scanTalents()
    -- ATM:print("HUNTER:scanTalents")
end

function prototype:classThreatModifier()
    return 1.0
end

prototype.spells = {
    ["Distracting Shot"] = {
        ranks = {
            [15632] = 600,
            [15631] = 465,
            [15630] = 350,
            [15629] = 250,
            [14274] = 160,
            [20736] = 110,
        },
        type = "CAST",
    },
}