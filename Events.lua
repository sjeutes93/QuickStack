-- QuickStack - Events and slash command
local ADDON, ns = ...
local InstallErrorCapture = ns.InstallErrorCapture
local BroadcastVersion = ns.BroadcastVersion
local CompareVersions = ns.CompareVersions
local CreateOptionsPanel = ns.CreateOptionsPanel
local HookButtons = ns.HookButtons
local HookTooltips = ns.HookTooltips
local L = ns.L
local MODIFIERS = ns.MODIFIERS
local NotifyUpdate = ns.NotifyUpdate
local OnMerchantClosed = ns.OnMerchantClosed
local OnRemoteVersion = ns.OnRemoteVersion
local OpenOptions = ns.OpenOptions
local OwnVersion = ns.OwnVersion
local PREFIX = ns.PREFIX
local ParseVersion = ns.ParseVersion
local Print = ns.Print
local ScanMerchant = ns.ScanMerchant
local SetupLauncher = ns.SetupLauncher
local defaults = ns.defaults

----------------------------------------------------------------------
-- Events & slash command
----------------------------------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_UPDATE")
frame:RegisterEvent("MERCHANT_CLOSED")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(_, event, arg1, arg2, arg3, arg4)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        QuickStackDB = QuickStackDB or {}
        ns.DB = QuickStackDB
        -- migrate the item list of versions before 1.3 into the "Default" profile
        if ns.DB.items and not ns.DB.profiles then
            ns.DB.profiles = { Default = { items = ns.DB.items } }
        end
        ns.DB.items = nil
        for k, v in pairs(defaults) do
            if ns.DB[k] == nil then
                if type(v) == "table" then ns.DB[k] = {} else ns.DB[k] = v end
            end
        end
        if not ns.DB.profiles.Default then ns.DB.profiles.Default = { items = {} } end
        if not MODIFIERS[ns.DB.modifier] then ns.DB.modifier = "alt" end
        HookTooltips()
        if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
            C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
        elseif RegisterAddonMessagePrefix then
            RegisterAddonMessagePrefix(PREFIX)
        end
        -- forget an old update hint once the addon has been updated
        local own, seen = ParseVersion(OwnVersion()), ParseVersion(ns.DB.newestSeen)
        if own and seen and CompareVersions(seen, own) <= 0 then
            ns.DB.newestSeen, ns.DB.notifiedVersion = nil, nil
        end
    elseif event == "PLAYER_LOGIN" then
        if ns.DB then
            SetupLauncher()
            InstallErrorCapture()
            CreateOptionsPanel()
        end
    elseif event == "MERCHANT_SHOW" then
        ns.atMerchant = true
        HookButtons()
        ScanMerchant()
        ns.RefreshPanel()
        if ns.menu and ns.menu:IsShown() and ns.menu.currentTab == "prices" then ns.RefreshPrices() end
    elseif event == "MERCHANT_UPDATE" then
        if ns.atMerchant then
            ScanMerchant()
            ns.RefreshPanel()
        end
    elseif event == "MERCHANT_CLOSED" then
        ns.atMerchant = false
        OnMerchantClosed()
        if ns.menu and ns.menu:IsShown() and ns.menu.currentTab == "prices" then ns.RefreshPrices() end
    elseif event == "PLAYER_ENTERING_WORLD" then
        if ns.DB then
            NotifyUpdate()
            if C_Timer and C_Timer.After then C_Timer.After(8, BroadcastVersion) else BroadcastVersion() end
        end
    elseif event == "GROUP_ROSTER_UPDATE" then
        if ns.DB then BroadcastVersion() end
    elseif event == "CHAT_MSG_ADDON" then
        if arg1 == PREFIX and ns.DB then OnRemoteVersion(arg2, arg3, arg4) end
    elseif event == "BAG_UPDATE_DELAYED" then
        if not ns.DB then return end
        if ns.menu and ns.menu:IsShown() and ns.menu.currentTab == "items" and ns.RefreshItems then ns.RefreshItems() end
        if ns.atMerchant then ns.RefreshPanel() end
    end
end)

-- /qs opens the menu; /qs alt | ctrl | shift sets the modifier directly
SLASH_QUICKSTACK1 = "/qs"
SLASH_QUICKSTACK2 = "/quickstack"
SlashCmdList["QUICKSTACK"] = function(msg)
    msg = (msg or ""):lower():gsub("%s+", "")
    if MODIFIERS[msg] then
        ns.DB.modifier = msg
        if ns.RefreshSettings then ns.RefreshSettings() end
        Print(string.format(L.MOD_SET, msg:upper()))
    elseif msg == "options" or msg == "config" then
        OpenOptions()
    else
        ns.ToggleMenu()
    end
end
