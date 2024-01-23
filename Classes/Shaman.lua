if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))
local s = ATM.spells

local prototype = {
    class = "SHAMAN",
    
    enhancingTotems = 1.0,
    rockbiter = 0,
}
prototype.color = "|c"..RAID_CLASS_COLORS[prototype.class].colorStr
ATM.playerMixins[prototype.class] = prototype

function prototype:scanTalents()
    -- ATM:print("SHAMAN:scanTalents")

    self.enhancingTotems = 1.0 + ({0, 0.8, 0.15})[self:GetTalent(2, 7)+1]
end

--[[ Rockbiter handlers ]]
local rbThreat = {
    6,
    10,
    16,
    27,
    41,
    55,
    72,
}

local speedCache = {}
local function getSpeed(itemLink)
    if type(itemLink) == "number" then
        itemLink = ({GetItemInfo(itemLink)})[2]
    end

    local speed = speedCache[itemLink]
    if not speed then
        ATMTooltip:SetOwner(UIParent, "ANCHOR_NONE")
        ATMTooltip:ClearLines()
        ATMTooltip:SetHyperlink(itemLink)

        for i = 1, ATMTooltip:NumLines() do
            local text = _G["ATMTooltipTextRight"..i]:GetText()
            if text then
                speed = tonumber(text:match(SPEED.." (.+)"))
                if speed then break end
            end
        end

        speedCache[itemLink] = speed
    end
    return speed
end

function prototype:scanEquipment()
    ATM.Player.scanEquipment(self) --call original handler

    --Rockbiter
    if self._isLocal then
        local newRockbiter = 0
        local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantID = GetWeaponEnchantInfo()
        if hasMainHandEnchant then
            local speed = getSpeed(GetInventoryItemLink("player", 16))
            local rank = ({
                  [29] = 1,
                   [6] = 2,
                   [1] = 3,
                 [503] = 4,
                [1663] = 5,
                 [683] = 6,
                [1664] = 7,
            })[mainHandEnchantID]
            local threat = rbThreat[rank] * speed
            newRockbiter = math.floor(threat)
        end
        if newRockbiter ~= self.rockbiter then
            self.rockbiter = newRockbiter
            ATM:TransmitSelf(true) --always sends custom no need to update any timestamps
            ATM:print("New rockbiter threat!", self.rockbiter)
        end
    end
end

function prototype:ENCHANT_APPLIED(...)
    local spellName, itemID, itemName = select(12, ...)
    local rank = tonumber(spellName:match("Rockbiter (%d+)"))
    if rank then
        local speed = getSpeed(itemID)
        local threat = rbThreat[rank] * speed
        self.rockbiter = math.floor(threat)
        ATM:print("New rockbiter threat!", self.rockbiter)
    end
end
function prototype:ENCHANT_REMOVED(...)
    local spellName, itemID, itemName = select(12, ...)
    local rank = tonumber(spellName:match("Rockbiter (%d+)"))
    if rank then
        self.rockbiter = 0
        ATM:print("New rockbiter threat!", self.rockbiter)
    end
end

function prototype:SWING_DAMAGE(...)
    ATM.Player.SWING_DAMAGE(self, ...) --call original handler
    
    local amount = select(12, ...)
    if not amount or amount < 1 then return end

    local bonusThreat = self.rockbiter
    if bonusThreat and bonusThreat > 0 then
        self.currentEvent = "["..self.color..self.name.."|r] ".."Rockbiter"

        local destGUID = select(8, ...)
        self:addThreat(bonusThreat, destGUID)
    end
end
--TODO localize Rockbiter enchant match (BOOST2_SHAMANENHANCE_REMIND_ROCKBITER?)


prototype.classFields = ATM.toTrue({
    'rockbiter',
})

--Earth Shock
s[10414] = {threatMod=2.0}
s[10413] = {threatMod=2.0}
s[10412] = {threatMod=2.0}
s[8046]  = {threatMod=2.0}
s[8045]  = {threatMod=2.0}
s[8044]  = {threatMod=2.0}
s[8042]  = {threatMod=2.0}


--[[ Season of Discovery ]]--
--Way of Earth
s[408680] = {handler = ATM.BuffThreatMod({[127] = 1.5})}
