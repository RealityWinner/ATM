if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))


local Ouro = {
    spells = {
        ["Sand Blast"] = {
            id = 26102,
            type = "DEBUFF",
            handler = ATM.NPC.FullThreatDrop
        },
    },
}
ATM.NPCs[15517] = Ouro



-- When whirlwind is a global threat wipe
-- Satura's Whirlwind removes all threat from current tank (when hit?)
local function whirlwind(self, ...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _ = ...
    local spellID, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
    ATM:print("ATM:NPC:AQ40:sartura:whirlwind", subevent, sourceGUID, spellName, spellID)

    if subevent == "SPELL_AURA_REMOVED" then
        self:GlobalThreatWipe() --Pretty sure
    elseif self:getID() == 15516 and subevent == "SPELL_DAMAGE" and amount and amount > 0 then
        local playerTarget = ATM:PlayerGUIDToTarget(destGUID)
        local enemyTarget = ATM:EnemyGUIDToTarget(sourceGUID)
        if enemyTarget and playerTarget then
            local isTanking = UnitDetailedThreatSituation(playerTarget, enemyTarget)
            if isTanking then
                self:FullThreatDrop(...)
            end
        end
    end
end

local Sartura = {
    spells = {
        ["Whirlwind"] = {
            -- cast/buff 26083
            -- proc 26084
            ids = {
                26083
            },
            handler = whirlwind
        },
    },
}
ATM.NPCs[15516] = Sartura

local SarturaGuard = {
    spells = {
        ["Whirlwind"] = {
            -- cast/buff 26038
            -- dmg 26686
            ids = {
                26038
            },
            handler = whirlwind
        },
        -- ["Knockback"] = {
        --     ids = {
        --         26027
        --     },
        --     type = "DAMAGE",
        --     handler = ATM.NPC.ZeroThreatDrop
        --     -- The knockback does not appear to have any threat drop mechanic
        -- },
    },
}
ATM.NPCs[15516] = SarturaGuard