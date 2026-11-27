-- QuickStack - Buying logic and vendor click handling
local ADDON, ns = ...
local AddItem = ns.AddItem
local Coins = ns.Coins
local Debug = ns.Debug
local Items = ns.Items
local L = ns.L
local MAX_SLIDER = ns.MAX_SLIDER
local MODIFIERS = ns.MODIFIERS
local Need = ns.Need
local Print = ns.Print

----------------------------------------------------------------------
-- Buying
----------------------------------------------------------------------
local function GetItemData(index)
    if C_MerchantFrame and C_MerchantFrame.GetItemInfo then
        local info = C_MerchantFrame.GetItemInfo(index)
        if not info then return end
        return info.name, info.price, info.stackCount, info.numAvailable, info.hasExtendedCost
    end
    local name, _, price, quantity, numAvailable, _, extendedCost = GetMerchantItemInfo(index)
    return name, price, quantity, numAvailable, extendedCost
end

-- buys in chunks of at most one stack per purchase
local function DoBuy(index, amount, maxStack)
    maxStack = math.max(1, maxStack or 1)
    while amount > 0 do
        local q = math.min(amount, maxStack)
        BuyMerchantItem(index, q)
        amount = amount - q
    end
end

local pending
if StaticPopupDialogs then
    StaticPopupDialogs["QUICKSTACK_CONFIRM"] = {
        text = "%s",
        button1 = YES,
        button2 = NO,
        OnAccept = function()
            if pending and ns.atMerchant then DoBuy(pending.index, pending.amount, pending.maxStack) end
            pending = nil
        end,
        OnCancel = function() pending = nil end,
        timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
    }
end

local function BuyStack(index)
    local name, price, bundleSize, numAvailable, hasExtendedCost = GetItemData(index)
    if not name then return end

    local link = GetMerchantItemLink(index)
    local id = link and tonumber(link:match("item:(%d+)"))
    local maxStack = GetMerchantItemMaxStack(index) or 1
    bundleSize = (bundleSize and bundleSize > 0) and bundleSize or 1

    local items = Items()
    local entry = id and items[id]
    if not entry and id and ns.DB.autoAdd then
        entry = AddItem(id, link, math.min(maxStack, MAX_SLIDER), "click")
    end

    local amount
    if entry then
        local have
        amount, have = Need(entry, id)
        if amount < 1 then
            Print(string.format(L.HAVE_ENOUGH, have or 0, name))
            return
        end
    else
        amount = math.min(maxStack, MAX_SLIDER)
    end

    -- Limit by vendor stock (-1 = unlimited)
    if numAvailable and numAvailable >= 0 then
        amount = math.min(amount, numAvailable * bundleSize)
    end
    -- Limit by gold (only computable for pure gold prices)
    if not hasExtendedCost and price and price > 0 then
        amount = math.min(amount, math.floor(GetMoney() / price) * bundleSize)
    end

    if amount < 1 then
        Debug("not enough gold or stock", name, "stock", numAvailable, "price", price)
        Print(string.format(L.NOT_ENOUGH, name))
        return
    end

    Debug("buy", name, "id", id, "amount", amount, "maxStack", maxStack, "stock", numAvailable, "price", price)

    -- Ask before expensive purchases
    local cost = (not hasExtendedCost and price) and (price * amount / bundleSize) or 0
    if (ns.DB.confirmGold or 0) > 0 and cost >= ns.DB.confirmGold * 10000 and StaticPopup_Show then
        pending = { index = index, amount = amount, maxStack = maxStack }
        StaticPopup_Show("QUICKSTACK_CONFIRM", string.format(L.CONFIRM, amount, name, Coins(cost)))
        return
    end
    DoBuy(index, amount, maxStack)
end

local function OnItemClick(self, button)
    if button ~= "LeftButton" then return end
    local check = MODIFIERS[ns.DB.modifier]
    if not (check and check()) then return end
    local index = self:GetID()
    if index and index > 0 then BuyStack(index) end
end

local function HookButtons()
    for i = 1, (MERCHANT_ITEMS_PER_PAGE or 10) do
        local btn = _G["MerchantItem" .. i .. "ItemButton"]
        if btn and not btn.quickStackHooked then
            btn:HookScript("OnClick", OnItemClick)
            btn.quickStackHooked = true
        end
    end
end

ns.GetItemData = GetItemData
ns.HookButtons = HookButtons
