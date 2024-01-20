if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))


function ATM:NewUnit(unitGUID)
    if not unitGUID then return end
    unitGUID = UnitGUID(unitGUID) or unitGUID
    
    
    local unitType = strsplit("-", unitGUID)
    if unitType == "Player" then
        return ATM:getPlayer(unitGUID)
    end
    if unitType == "Creature" then
        return ATM:getEnemy(unitGUID)
    end
end

ATM._units = {}
local function UnitsIndex(table, key)
    local unit = ATM:NewUnit(key);
    rawset(table, key, unit)
    return unit
end
setmetatable(ATM._units, {
    __index = UnitsIndex,
    __mode = "k", --weak
});


local Unit = {
    type = "", --"Player" or "Creature"
}
ATM.Unit = Unit