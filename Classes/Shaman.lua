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
local rbRanks = ({
    [29] = 1,
     [6] = 2,
     [1] = 3,
   [503] = 4,
  [1663] = 5,
   [683] = 6,
  [1664] = 7,
})

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
        local wepSpeed = getSpeed(GetInventoryItemLink("player", 16))
        local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantID = GetWeaponEnchantInfo()
        if hasMainHandEnchant then
            local rank = rbRanks[mainHandEnchantID]
            if rank then
                newRockbiter = newRockbiter + math.floor(rbThreat[rank] * wepSpeed)
            end
        end
        if hasOffHandEnchant then
            local rank = rbRanks[offHandEnchantID]
            if rank then
                newRockbiter = newRockbiter + math.floor(rbThreat[rank] * wepSpeed)
            end
        end
        if self.rockbiter ~= newRockbiter then
            self.rockbiter = newRockbiter
            ATM:TransmitSelf(true) --always sends custom no need to update any timestamps
            ATM:print("New rockbiter threat!", self.rockbiter)
        end
    end
end

function prototype:SWING_DAMAGE(...)
    ATM.Player.SWING_DAMAGE(self, ...) --call original handler
    
    local amount = select(12, ...)
    local isOffHand = select(21, ...)
    if not amount or amount < 1 then return end

    local bonusThreat = self.rockbiter
    if bonusThreat and bonusThreat > 0 then
        if C.debug then
            self.currentEvent = {"[", self.color, self.name, "|r] ", "Rockbiter ", isOffHand and "OH" or "MH"}
        end
        local destGUID = select(8, ...)
        self:addThreat(bonusThreat * self.threatBuffs[1], destGUID)
    end
end

function prototype:UNIT_AURA()
    for i=1,999 do
        local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID = UnitBuff("player", i)
        if not spellID then break end
        if spellID == 408680 then
            self.threatBuffs["Way of Earth"] = {[127] = 1.5}
            return
        end
    end
    self.threatBuffs["Way of Earth"] = nil
end

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

--Tranquil Air
s[25909] = {handler = ATM.BuffThreatMod({[127] = 0.8})}


    --[[ Season of Discovery ]]--
--Way of Earth
s[408680] = {handler = ATM.BuffThreatMod({[127] = 1.5})}
--Earth Shock (Taunt)
s[408681] = {threatMod=2.0,isTaunt=true,handler=ATM.Taunt}
s[408683] = {threatMod=2.0,isTaunt=true,handler=ATM.Taunt}
s[408685] = {threatMod=2.0,isTaunt=true,handler=ATM.Taunt}
s[408687] = {threatMod=2.0,isTaunt=true,handler=ATM.Taunt}
s[408688] = {threatMod=2.0,isTaunt=true,handler=ATM.Taunt}
s[408689] = {threatMod=2.0,isTaunt=true,handler=ATM.Taunt}
s[408690] = {threatMod=2.0,isTaunt=true,handler=ATM.Taunt}

--Water Shield
s[408510] = {ignored=true}