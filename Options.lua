-- QuickStack - Entry in the game options, key binding
local ADDON, ns = ...
local L = ns.L
local NewButton = ns.NewButton
local NewCheck = ns.NewCheck
local NewText = ns.NewText
local UpdateMinimapVisibility = ns.UpdateMinimapVisibility

-- Entry in the game's options window (Esc > Options > AddOns) ------------
local optionsPanel, optionsCategory

local function CreateOptionsPanel()
    local panel = CreateFrame("Frame")
    panel.name = "QuickStack"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("QuickStack")

    local desc = NewText(panel, "GameFontHighlight")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    desc:SetWidth(560)
    desc:SetWordWrap(true)
    desc:SetText(L.OPTIONS_DESC)

    local open = NewButton(panel, L.OPEN_MENU, 220, 26)
    open:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -14)
    open:SetScript("OnClick", function()
        if SettingsPanel and SettingsPanel:IsShown() and HideUIPanel then pcall(HideUIPanel, SettingsPanel) end
        if InterfaceOptionsFrame and InterfaceOptionsFrame:IsShown() and HideUIPanel then
            pcall(HideUIPanel, InterfaceOptionsFrame)
        end
        if not (ns.menu and ns.menu:IsShown()) then ns.ToggleMenu() end
    end)

    local checks = {
        NewCheck(panel, L.AUTO_ADD, function() return ns.DB.autoAdd end, function(v) ns.DB.autoAdd = v end),
        NewCheck(panel, L.SHOW_PANEL, function() return ns.DB.showPanel end,
            function(v) ns.DB.showPanel = v; ns.RefreshPanel() end),
        NewCheck(panel, L.SHOW_TOOLTIP, function() return ns.DB.showTooltip end, function(v) ns.DB.showTooltip = v end),
        NewCheck(panel, L.SHOW_MINIMAP, function() return ns.DB.showMinimap end,
            function(v) ns.DB.showMinimap = v; UpdateMinimapVisibility() end),
        NewCheck(panel, L.NOTIFY_UPDATE, function() return ns.DB.notifyUpdate end, function(v) ns.DB.notifyUpdate = v end),
    }
    for i, c in ipairs(checks) do
        c:SetPoint("TOPLEFT", open, "BOTTOMLEFT", 0, -16 - (i - 1) * 30)
    end
    panel:SetScript("OnShow", function()
        for _, c in ipairs(checks) do c:Refresh() end
    end)
    for _, c in ipairs(checks) do c:Refresh() end

    optionsPanel = panel
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        optionsCategory = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(optionsCategory)
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end
end

local function OpenOptions()
    if not optionsPanel then return false end
    if Settings and Settings.OpenToCategory and optionsCategory then
        local id = optionsCategory.GetID and optionsCategory:GetID() or optionsCategory.ID
        Settings.OpenToCategory(id)
        return true
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(optionsPanel)
        InterfaceOptionsFrame_OpenToCategory(optionsPanel) -- called twice: known client quirk
        return true
    end
    return false
end

-- key binding support (Bindings.xml)
BINDING_HEADER_QUICKSTACK = "QuickStack"
BINDING_NAME_QUICKSTACK_TOGGLE = L.BINDING
function QuickStack_Toggle()
    if ns.DB then ns.ToggleMenu() end
end

ns.CreateOptionsPanel = CreateOptionsPanel
ns.OpenOptions = OpenOptions
