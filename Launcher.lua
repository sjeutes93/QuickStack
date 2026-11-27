-- QuickStack - Minimap button / LibDataBroker launcher
local ADDON, ns = ...
local L = ns.L
local defaults = ns.defaults

----------------------------------------------------------------------
-- Minimap button (draggable along the minimap edge; round and square minimaps)
----------------------------------------------------------------------
local mmButton
local atan2 = math.atan2 or math.atan
local SHAPES = {
    ["ROUND"] = { true, true, true, true },
    ["SQUARE"] = { false, false, false, false },
    ["CORNER-TOPLEFT"] = { false, false, false, true },
    ["CORNER-TOPRIGHT"] = { false, false, true, false },
    ["CORNER-BOTTOMLEFT"] = { false, true, false, false },
    ["CORNER-BOTTOMRIGHT"] = { true, false, false, false },
    ["SIDE-LEFT"] = { false, true, false, true },
    ["SIDE-RIGHT"] = { true, false, true, false },
    ["SIDE-TOP"] = { false, false, true, true },
    ["SIDE-BOTTOM"] = { true, true, false, false },
    ["TRICORNER-TOPLEFT"] = { false, true, true, true },
    ["TRICORNER-TOPRIGHT"] = { true, false, true, true },
    ["TRICORNER-BOTTOMLEFT"] = { true, true, false, true },
    ["TRICORNER-BOTTOMRIGHT"] = { true, true, true, false },
}

local function UpdateMinimapPosition()
    if not mmButton then return end
    local angle = math.rad(ns.DB.minimapAngle or 215)
    local x, y = math.cos(angle), math.sin(angle)
    local q = 1
    if x < 0 then q = q + 1 end
    if y > 0 then q = q + 2 end
    local shape = (GetMinimapShape and GetMinimapShape()) or "ROUND"
    local quad = SHAPES[shape] or SHAPES.ROUND
    local w = (Minimap:GetWidth() / 2) + 5
    local h = (Minimap:GetHeight() / 2) + 5
    if quad[q] then
        x, y = x * w, y * h
    else
        local dw = math.sqrt(2 * w * w) - 10
        local dh = math.sqrt(2 * h * h) - 10
        x = math.max(-w, math.min(x * dw, w))
        y = math.max(-h, math.min(y * dh, h))
    end
    mmButton:ClearAllPoints()
    mmButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local ldbIcon -- LibDBIcon-1.0, if available

local function UpdateMinimapVisibility()
    if ldbIcon then
        ns.DB.minimap.hide = not ns.DB.showMinimap
        if ns.DB.showMinimap then ldbIcon:Show(ADDON) else ldbIcon:Hide(ADDON) end
        return
    end
    if not mmButton then return end
    if ns.DB.showMinimap then mmButton:Show() else mmButton:Hide() end
end

local function ResetMinimapPosition()
    ns.DB.minimapAngle = defaults.minimapAngle
    if ldbIcon then
        ns.DB.minimap.minimapPos = defaults.minimapAngle
        ldbIcon:Refresh(ADDON, ns.DB.minimap)
    else
        UpdateMinimapPosition()
    end
end


local function CreateMinimapButton()
    local b = CreateFrame("Button", "QuickStackMinimapButton", Minimap)
    b:SetSize(32, 32)
    b:SetFrameStrata("MEDIUM")
    b:SetFrameLevel(8)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:RegisterForDrag("LeftButton")
    b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local bg = b:CreateTexture(nil, "BACKGROUND")
    bg:SetSize(20, 20)
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetPoint("TOPLEFT", 7, -5)
    local icon = b:CreateTexture(nil, "ARTWORK")
    icon:SetSize(19, 19)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    icon:SetPoint("TOPLEFT", 6, -5)
    local border = b:CreateTexture(nil, "OVERLAY")
    border:SetSize(54, 54)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetPoint("TOPLEFT")

    local function OnUpdate()
        local mx, my = Minimap:GetCenter()
        local scale = Minimap:GetEffectiveScale()
        local cx, cy = GetCursorPosition()
        cx, cy = cx / scale, cy / scale
        ns.DB.minimapAngle = math.deg(atan2(cy - my, cx - mx))
        UpdateMinimapPosition()
    end
    b:SetScript("OnDragStart", function(self)
        GameTooltip:Hide()
        self:SetScript("OnUpdate", OnUpdate)
    end)
    b:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
    b:SetScript("OnClick", function() ns.ToggleMenu() end)
    b:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("QuickStack", 1, 0.82, 0)
        GameTooltip:AddLine(L.MM_LEFT, 1, 1, 1)
        GameTooltip:AddLine(L.MM_DRAG, 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)

    mmButton = b
    UpdateMinimapPosition()
    UpdateMinimapVisibility()
end

-- Uses LibDataBroker / LibDBIcon when another addon provides them (then the button
-- also shows up in minimap button bags and broker displays); otherwise own button.
local function SetupLauncher()
    local stub = LibStub
    local ldb = stub and stub("LibDataBroker-1.1", true)
    if not ldb then
        CreateMinimapButton()
        return
    end
    local obj = ldb:GetDataObjectByName(ADDON) or ldb:NewDataObject(ADDON, {
        type = "launcher",
        text = "QuickStack",
        icon = "Interface\\Icons\\INV_Misc_Coin_01",
        OnClick = function() ns.ToggleMenu() end,
        OnTooltipShow = function(tt)
            tt:AddLine("QuickStack", 1, 0.82, 0)
            tt:AddLine(L.MM_LEFT, 1, 1, 1)
            tt:AddLine(L.MM_DRAG, 0.7, 0.7, 0.7)
        end,
    })
    local icon = stub("LibDBIcon-1.0", true)
    if not (obj and icon) then
        if not mmButton then CreateMinimapButton() end
        return
    end
    ns.DB.minimap = ns.DB.minimap or {}
    ns.DB.minimap.minimapPos = ns.DB.minimap.minimapPos or ns.DB.minimapAngle
    ns.DB.minimap.hide = not ns.DB.showMinimap
    ldbIcon = icon
    if not icon:IsRegistered(ADDON) then icon:Register(ADDON, obj, ns.DB.minimap) end
    UpdateMinimapVisibility()
end

ns.ResetMinimapPosition = ResetMinimapPosition
ns.SetupLauncher = SetupLauncher
ns.UpdateMinimapVisibility = UpdateMinimapVisibility
