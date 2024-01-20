local ATM, C, L, _ = unpack(select(2, ...))

local function LocalizeIndex(table, key)
    local spellName = GetSpellInfo(key)
    table[key] = spellName
    return spellName
end
setmetatable(L, {
    __index = LocalizeIndex,
    __mode = "k", --weak
});