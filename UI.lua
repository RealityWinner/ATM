if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))

-- Disable UI --
-- if true then return end



--[[
Ordered table iterator, allow to iterate on the natural order of the keys of a
table.

Example:
]]

local function __genOrderedIndex(t, tg)
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert(orderedIndex, key)
    end
    table.sort(orderedIndex, function(a,b)
        -- local at = t[a]:getThreat(tg)
        -- local bt = t[b]:getThreat(tg)
        -- if at==bt then
        --     return t[a]:getName() > t[b]:getName()
        -- else
            return t[a]:getThreat(tg, true) > t[b]:getThreat(tg, true)
        -- end
    end)
    return orderedIndex
end


local function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key, orderedIndex = unpack(state)
    -- print("orderedNext:", t, key, orderedIndex)

    if not orderedIndex then
        -- the first time, generate the index
        orderedIndex = __genOrderedIndex(t, key)
        key = orderedIndex[1]
    else
        -- fetch the next value
        for i = 1,table.getn(orderedIndex) do
            if orderedIndex[i] == key then
                key = orderedIndex[i+1]
                break
            end
        end
    end
    state = {key, orderedIndex}

    if key then
        return state, t[key]
    end

    -- no more value to return, cleanup
    return
end

local function orderedPairs(table, targetGUID)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, table, {targetGUID, nil}
end





local frame = CreateFrame("Frame", "ATMUI", UIParent, "BackdropTemplate")
frame.threatBars = {}
frame:SetMovable(true)
frame:SetResizable(true)
frame:EnableMouse(true)
frame:SetClampedToScreen(true)



frame:SetPoint("CENTER");
frame:SetWidth(200);
frame:SetHeight(200);
frame:SetResizeBounds(100,100);
frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
                    edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
                    tile = true, tileSize = 16, edgeSize = 16, 
                    insets = { left = 4, right = 4, top = 4, bottom = 4 }
                });
frame:SetBackdropColor(0,0,0,1);


local resizeButton = CreateFrame("Button", nil, frame)
resizeButton:SetSize(16, 16)
resizeButton:SetPoint("BOTTOMRIGHT")
resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
resizeButton:SetScript("OnMouseDown", function(self, button)
    frame:StartSizing("BOTTOMRIGHT")
    frame:SetUserPlaced(true)
end)
resizeButton:SetScript("OnMouseUp", function(self, button)
    frame:StopMovingOrSizing()
end)


local height = 15
local limit = 10
for i=0,(limit-1) do
    local statusbar = CreateFrame("StatusBar", nil, frame)
    statusbar:SetPoint("TOPLEFT", 4, -height*i-20)
    statusbar:SetPoint("TOPRIGHT", -4, -height*i-20)
    statusbar:SetHeight(height);
    statusbar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill")
    statusbar:GetStatusBarTexture():SetHorizTile(false)
    statusbar:GetStatusBarTexture():SetVertTile(false)
    statusbar:SetMinMaxValues(0, 100)
    statusbar:SetValue(i*10)
    statusbar:SetStatusBarColor(0, 0.65, 0)

    -- statusbar.bg = statusbar:CreateTexture(nil, "BACKGROUND")
    -- statusbar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    -- statusbar.bg:SetAllPoints(true)
    -- statusbar.bg:SetVertexColor(0, 0, 0)


    statusbar.name = statusbar:CreateFontString(nil, "OVERLAY")
    statusbar.name:SetPoint("LEFT", statusbar, "LEFT", 0, 0)
    statusbar.name:SetFont("Interface\\Addons\\ATM\\Fonts\\FreeSansBold.TTF", 14, "OUTLINE")
    statusbar.name:SetJustifyH("LEFT")
    statusbar.name:SetShadowOffset(1, -1)
    statusbar.name:SetTextColor(0, 1, 0)
    statusbar.name:SetText("Nuzzles")

    statusbar.value = statusbar:CreateFontString(nil, "OVERLAY")
    statusbar.value:SetPoint("CENTER", statusbar, "CENTER", 20, 0)
    statusbar.value:SetFont("Interface\\Addons\\ATM\\Fonts\\FreeSansBold.TTF", 14, "OUTLINE")
    statusbar.value:SetJustifyH("CENTER")
    statusbar.value:SetShadowOffset(1, -1)
    statusbar.value:SetTextColor(0, 1, 0)
    statusbar.value:SetText("100%")
    
    statusbar.threat = statusbar:CreateFontString(nil, "OVERLAY")
    statusbar.threat:SetPoint("RIGHT", statusbar, "RIGHT", 0, 0)
    statusbar.threat:SetFont("Interface\\Addons\\ATM\\Fonts\\FreeSansBold.ttf", 12, "OUTLINE")
    statusbar.threat:SetJustifyH("RIGHT")
    statusbar.threat:SetShadowOffset(1, -1)
    statusbar.threat:SetTextColor(0, 1, 0)
    statusbar.threat:SetText(string.format("%.2f", i*1000))

    table.insert(frame.threatBars, statusbar)
end

frame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and not self.isMoving then
        self:StartMoving();
        self.isMoving = true;
    end
end)
frame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" and self.isMoving then
        self:StopMovingOrSizing();
        self.isMoving = false;
    end
end)
frame:SetScript("OnHide", function(self)
    if ( self.isMoving ) then
        self:StopMovingOrSizing();
        self.isMoving = false;
    end
end)

frame:SetScript("OnSizeChanged", function(self)
    local numBars = floor((self:GetHeight()-23) / height) - 1
    
    for i=1, numBars do
        self.threatBars[i]:Show()
    end
    for i=numBars+1, limit do
        self.threatBars[i]:Hide()
    end
end)
-- frame:GetScript("OnSizeChanged")()


frame.title = frame:CreateFontString(nil,"ARTWORK") 
frame.title:SetFont("Fonts\\FRIZQT__.ttf", 12, "OUTLINE")
frame.title:SetPoint("TOPLEFT", 5, -6)
frame.title:SetPoint("TOPRIGHT", -6, 5)
frame.title:SetHeight(12)
frame.title:SetJustifyV("TOP");
frame.title:SetJustifyH("LEFT");
frame.title:SetText("ATM "..C.DISPLAY)

ATM.UI = frame

local function shortenThreat(threat)
    if C.debug then
        return string.format("%.2f", threat)
	else
		if threat > 10000 then
			return string.format("%.1fk", threat/1000)
        elseif threat > 1000 then
            return string.format("%.2fk", threat/1000)
		else
			return string.format("%.0f", threat)
		end
	end
end

frame.TimeSinceLastUpdate = 0
frame.isTanking = false
frame:SetScript("OnUpdate", function(self, elapsed)
    self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
    while (self.TimeSinceLastUpdate > C.UIInterval) do
        self.TimeSinceLastUpdate = self.TimeSinceLastUpdate - C.UIInterval;


        local unit = "target"
        if not UnitCanAttack("player", unit) then
            unit = "targettarget"
        end


        ATM.UI.title:SetText("ATM "..C.DISPLAY)
        if UnitCanAttack("player", unit) then
            ATM.UI.title:SetText("ATM "..C.DISPLAY..": "..UnitName(unit))
            local enemyGUID = UnitGUID(unit)


            local idx=1
            for _,player in orderedPairs(ATM._players, enemyGUID) do
                local bar = self.threatBars[idx]
                if not bar then break end

                local playerUnit = ATM:PlayerGUIDToUnit(player.guid)
                if playerUnit then
                    local isTanking, status, threatpct, rawthreatpct, threatvalue = ATM:UnitDetailedThreatSituation(playerUnit, unit)
                    if not threatvalue then break end

                    bar:SetStatusBarColor(0, 0.65, 0)
                    if player._isLocal then
                        bar:SetStatusBarColor(0.65, 0, 0)
                        if isTanking then
                            bar:SetStatusBarColor(0.65, 0, 0.65)
                        end
                    else
                        if isTanking then
                            bar:SetStatusBarColor(0, 0, 0.65)
                        end
                    end

                    bar.name:SetText(player.color..player:getName())
                    bar.threat:SetText(shortenThreat(threatvalue))

                    bar.value:SetText(string.format("%.0f%%", (threatpct or 0)*100))
                    bar:SetValue((threatpct or 0)*100)
                    
                    idx = idx+1
                end
            end

            for i=idx,limit do
                local bar = self.threatBars[i]
                if not bar:IsVisible() then return end
                bar.name:SetText("")
                bar.value:SetText("")
                bar.threat:SetText("")
                bar:SetValue(0)
            end
        else--if not C.debug then
            for i=1,limit do
                local bar = self.threatBars[i]
                if not bar:IsVisible() then return end
                bar.name:SetText("")
                bar.value:SetText("")
                bar.threat:SetText("")
                bar:SetValue(0)
            end
        end
    end
end)
