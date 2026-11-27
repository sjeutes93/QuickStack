-- QuickStack - Core: constants, helpers, profiles
local ADDON, ns = ...

local MAX_SLIDER = 20           -- slider range 1..20
local MAX_AMOUNT = 1000         -- upper limit when typing an amount
local MAX_VENDORS_PER_ITEM = 8  -- price history kept per item
local BUG_URL = "https://github.com/sjeutes93/QuickStack/issues"
local DOWNLOAD_URL = "https://www.curseforge.com/wow/addons/quickstack" -- shown in the update message
local PREFIX = "QuickStack"     -- addon message prefix for version checks

-- Localization: texts live in Locales/*.lua (English is the fallback)
ns.locales.esMX = ns.locales.esMX or ns.locales.esES
local lang = ns.locales[GetLocale and GetLocale() or "enUS"]
local en = ns.en
local L = setmetatable({}, { __index = function(_, k) return (lang and lang[k]) or en[k] or k end })

----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------
ns.atMerchant = false

local defaults = {
    modifier = "alt",
    autoAdd = true,
    showMinimap = true,
    showPanel = true,
    showTooltip = true,
    pricesMine = true,
    confirmGold = 0,
    notifyUpdate = true,
    debug = false,
    errors = {},
    minimapAngle = 215,
    profiles = {},
    chars = {},
    prices = {},
}

local MODIFIERS = {
    alt   = IsAltKeyDown,
    ctrl  = IsControlKeyDown,
    shift = IsShiftKeyDown,
}

local QUESTION = "Interface\\Icons\\INV_Misc_QuestionMark"
local GetMeta = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
local CoinString = GetCoinTextureString or (C_CurrencyInfo and C_CurrencyInfo.GetCoinTextureString)
local CountFn = (C_Item and C_Item.GetItemCount) or GetItemCount

local function Print(msg)
    print("|cff33ff99" .. ADDON .. "|r: " .. msg)
end

local function Coins(copper)
    copper = math.max(1, math.floor((copper or 0) + 0.5))
    if CoinString then return CoinString(copper) end
    return copper .. "c"
end

local function CountItem(id)
    if CountFn then return CountFn(id) or 0 end
    return 0
end

local function GetIcon(id)
    if C_Item and C_Item.GetItemIconByID then return C_Item.GetItemIconByID(id) end
    if GetItemIcon then return GetItemIcon(id) end
end

local function GetName(id, link)
    local name = link and link:match("%[(.-)%]")
    if name then return name end
    local getInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
    if getInfo then name = getInfo(id) end
    return name or ("Item " .. id)
end

local function Age(t)
    local d = math.max(0, time() - (t or 0))
    if d >= 86400 then return string.format(L.AGE_D, math.floor(d / 86400)) end
    if d >= 3600 then return string.format(L.AGE_H, math.floor(d / 3600)) end
    return L.AGE_NOW
end

-- Profiles ------------------------------------------------------------
local function CharKey()
    return (UnitName("player") or "?") .. "-" .. ((GetRealmName and GetRealmName()) or "?")
end

local function ProfileName()
    local n = ns.DB.chars[CharKey()]
    if not n or not ns.DB.profiles[n] then
        n = "Default"
        if not ns.DB.profiles[n] then ns.DB.profiles[n] = { items = {} } end
    end
    return n
end

local function Items()
    return ns.DB.profiles[ProfileName()].items
end

local function SortedProfileNames()
    local list = {}
    for name in pairs(ns.DB.profiles) do list[#list + 1] = name end
    table.sort(list)
    return list
end

local function RefreshAll()
    if ns.RefreshItems and ns.menu then ns.RefreshItems() end
    if ns.RefreshPrices and ns.menu then ns.RefreshPrices() end
    if ns.RefreshProfiles and ns.menu then ns.RefreshProfiles() end
    if ns.RefreshPanel then ns.RefreshPanel() end
end

local function AddItem(id, link, amount, mode)
    local items = Items()
    if items[id] then return items[id], false end
    local entry = {
        name = GetName(id, link), icon = GetIcon(id),
        amount = amount or MAX_SLIDER, mode = mode or "click",
    }
    items[id] = entry
    if ns.RefreshItems and ns.menu and ns.menu:IsShown() then ns.RefreshItems() end
    if ns.RefreshPanel and ns.atMerchant then ns.RefreshPanel() end
    return entry, true
end

-- Amount to buy right now for a listed item (and how many are in the bags)
local function Need(entry, id)
    if entry.mode == "target" then
        local have = CountItem(id)
        return math.max(0, (entry.amount or 0) - have), have
    end
    return entry.amount or 0, nil
end

ns.AddItem = AddItem
-- Debug log and error capture ----------------------------------------
local debugLog = {} -- last lines, kept in memory only and added to bug reports
local MAX_LOG = 40

local function Debug(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[i] = tostring((select(i, ...))) end
    local line = table.concat(parts, " ")
    debugLog[#debugLog + 1] = date("%H:%M:%S", time()) .. " " .. line
    while #debugLog > MAX_LOG do table.remove(debugLog, 1) end
    if ns.DB and ns.DB.debug then
        print("|cff888888QuickStack debug:|r " .. line)
    end
end

-- stores an error text (the last 10 are kept) so it can go into a bug report
local function LogError(text)
    if not ns.DB then return end
    local list = ns.DB.errors
    list[#list + 1] = { t = time(), msg = tostring(text):sub(1, 600) }
    while #list > 10 do table.remove(list, 1) end
end

-- Wraps the game's error handler. Only errors that mention QuickStack are stored;
-- every error is still passed on to the previous handler (BugSack, default frame, ...).
local function InstallErrorCapture()
    if ns.errorHooked or not (seterrorhandler and geterrorhandler) then return end
    ns.errorHooked = true
    local previous = geterrorhandler()
    seterrorhandler(function(msg)
        if tostring(msg):find(ADDON, 1, true) then LogError(msg) end
        if previous then return previous(msg) end
    end)
end

ns.Age = Age
ns.BUG_URL = BUG_URL
ns.CharKey = CharKey
ns.Coins = Coins
ns.CountItem = CountItem
ns.DOWNLOAD_URL = DOWNLOAD_URL
ns.GetIcon = GetIcon
ns.GetMeta = GetMeta
ns.GetName = GetName
ns.Items = Items
ns.L = L
ns.MAX_AMOUNT = MAX_AMOUNT
ns.MAX_SLIDER = MAX_SLIDER
ns.MAX_VENDORS_PER_ITEM = MAX_VENDORS_PER_ITEM
ns.MODIFIERS = MODIFIERS
ns.Need = Need
ns.PREFIX = PREFIX
ns.Print = Print
ns.ProfileName = ProfileName
ns.QUESTION = QUESTION
ns.RefreshAll = RefreshAll
ns.SortedProfileNames = SortedProfileNames
ns.defaults = defaults
ns.Debug = Debug
ns.LogError = LogError
ns.InstallErrorCapture = InstallErrorCapture
ns.debugLog = debugLog
