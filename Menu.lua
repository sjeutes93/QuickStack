-- QuickStack - Main menu window and tabs
local ADDON, ns = ...
local DIALOG_BACKDROP = ns.DIALOG_BACKDROP
local GetMeta = ns.GetMeta
local L = ns.L
local NewButton = ns.NewButton
local NewFrame = ns.NewFrame
local SetSelected = ns.SetSelected

local pages, tabs = {}, {}
local PAGE_W = 512

local function ShowTab(key)
    for k, page in pairs(pages) do
        if k == key then page:Show() else page:Hide() end
    end
    for k, tab in pairs(tabs) do SetSelected(tab, k == key) end
    ns.menu.currentTab = key
    if key == "items" and ns.RefreshItems then ns.RefreshItems() end
    if key == "prices" and ns.RefreshPrices then ns.RefreshPrices() end
    if key == "profiles" and ns.RefreshProfiles then ns.RefreshProfiles() end
    if key == "settings" and ns.RefreshSettings then ns.RefreshSettings() end
end


local function BuildMenu()
    if ns.menu then return end
    ns.menu = NewFrame(UIParent, "QuickStackMenu")
    ns.menu:SetSize(560, 540)
    ns.menu:SetPoint("CENTER")
    ns.menu:SetFrameStrata("DIALOG")
    ns.menu:SetMovable(true)
    ns.menu:EnableMouse(true)
    ns.menu:SetClampedToScreen(true)
    ns.menu:RegisterForDrag("LeftButton")
    ns.menu:SetScript("OnDragStart", ns.menu.StartMoving)
    ns.menu:SetScript("OnDragStop", ns.menu.StopMovingOrSizing)
    ns.menu:SetBackdrop(DIALOG_BACKDROP)
    tinsert(UISpecialFrames, "QuickStackMenu")
    ns.menu:Hide()

    local header = ns.menu:CreateTexture(nil, "ARTWORK")
    header:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    header:SetSize(300, 64)
    header:SetPoint("TOP", 0, 12)
    local title = ns.menu:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", header, "TOP", 0, -14)
    title:SetText("QuickStack")

    local ver = ns.menu:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    ver:SetPoint("BOTTOMLEFT", 26, 14)
    ver:SetText("v" .. ((GetMeta and GetMeta(ADDON, "Version")) or ""))

    ns.menu.update = ns.menu:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ns.menu.update:SetPoint("BOTTOMRIGHT", -26, 14)
    ns.menu.update:SetJustifyH("RIGHT")

    -- close button: hides the menu explicitly and sits above everything else
    local close = CreateFrame("Button", nil, ns.menu, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
    close:SetFrameLevel(ns.menu:GetFrameLevel() + 20)
    close:SetScript("OnClick", function() ns.menu:Hide() end)

    local tabDefs = {
        { key = "items", label = L.ITEMS },
        { key = "prices", label = L.PRICES },
        { key = "profiles", label = L.PROFILES },
        { key = "settings", label = L.SETTINGS },
        { key = "bug", label = L.BUGREPORT },
    }
    for i, def in ipairs(tabDefs) do
        local t = NewButton(ns.menu, def.label, 98, 24)
        t:SetPoint("TOPLEFT", 24 + (i - 1) * 102, -56)
        t:SetScript("OnClick", function() ShowTab(def.key) end)
        tabs[def.key] = t

        local page = CreateFrame("Frame", nil, ns.menu)
        page:SetPoint("TOPLEFT", 24, -92)
        page:SetPoint("BOTTOMRIGHT", -24, 28)
        page:Hide()
        pages[def.key] = page
    end

    ns.BuildItemsPage(pages.items)
    ns.BuildPricesPage(pages.prices)
    ns.BuildProfilesPage(pages.profiles)
    ns.BuildSettingsPage(pages.settings)
    ns.BuildBugPage(pages.bug)
    if ns.UpdateBanner then ns.UpdateBanner() end
end

ns.ToggleMenu = function()
    BuildMenu()
    if ns.menu:IsShown() then
        ns.menu:Hide()
    else
        ns.menu:Show()
        ShowTab(ns.menu.currentTab or "items")
    end
end

ns.PAGE_W = PAGE_W
