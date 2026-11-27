-- QuickStack - Price tracking, price table and tooltip prices
local ADDON, ns = ...
local Age = ns.Age
local Coins = ns.Coins
local LogError = ns.LogError
local DIALOG_BACKDROP = ns.DIALOG_BACKDROP
local GetItemData = ns.GetItemData
local Items = ns.Items
local L = ns.L
local MAX_VENDORS_PER_ITEM = ns.MAX_VENDORS_PER_ITEM
local Need = ns.Need
local NewFrame = ns.NewFrame
local NewIcon = ns.NewIcon
local NewText = ns.NewText
local QUESTION = ns.QUESTION

----------------------------------------------------------------------
-- Price tracking (recorded whenever a vendor window opens)
----------------------------------------------------------------------
local currentVendor
local currentItems = {} -- itemID -> price per single item at the open vendor

local function GetVendorInfo()
    local name = UnitName("npc") or UnitName("target") or "?"
    local guid = UnitGUID("npc")
    local npcID
    if guid and strsplit then npcID = select(6, strsplit("-", guid)) end
    local zone = (GetZoneText and GetZoneText()) or ""
    local key = (npcID and npcID ~= "") and npcID or (name .. "@" .. zone)
    return { key = key, name = name, zone = zone }
end

local function RecordPrice(id, vendor, unitPrice, itemName)
    local t = ns.DB.prices[id]
    if not t then t = {}; ns.DB.prices[id] = t end
    t[vendor.key] = { p = unitPrice, v = vendor.name, z = vendor.zone, t = time(), n = itemName }
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    while count > MAX_VENDORS_PER_ITEM do
        local oldestKey, oldest
        for key, e in pairs(t) do
            if key ~= vendor.key and (not oldest or e.t < oldest) then oldestKey, oldest = key, e.t end
        end
        if not oldestKey then break end
        t[oldestKey] = nil
        count = count - 1
    end
end

local function ScanMerchant()
    if not ns.atMerchant or not ns.DB then return end
    local vendor = GetVendorInfo()
    currentVendor = vendor
    wipe(currentItems)
    for i = 1, (GetMerchantNumItems() or 0) do
        local name, price, bundle, _, hasExtendedCost = GetItemData(i)
        local link = GetMerchantItemLink(i)
        local id = link and tonumber(link:match("item:(%d+)"))
        if id and name and price and price > 0 and not hasExtendedCost then
            local unit = price / ((bundle and bundle > 0) and bundle or 1)
            currentItems[id] = unit
            RecordPrice(id, vendor, unit, name)
        end
    end
end

local function BestElsewhere(id, hereKey)
    local best
    for key, e in pairs(ns.DB.prices[id] or {}) do
        if key ~= hereKey and (not best or e.p < best.p) then best = e end
    end
    return best
end

local function Where(e)
    return (e.z and e.z ~= "") and e.z or e.v or "?"
end

local function CompareText(id, unit, hereKey, need)
    local best = BestElsewhere(id, hereKey)
    if not best then return L.NO_OTHER end
    local diff = (unit - best.p) / best.p * 100
    if diff >= 1 then
        local saved = (unit - best.p) * math.max(1, need or 1)
        return string.format(L.CHEAPER, math.floor(diff + 0.5), Where(best),
            Coins(best.p), Age(best.t), Coins(saved))
    elseif diff <= -1 then
        return string.format(L.BEST, math.floor(-diff + 0.5), Where(best))
    end
    return L.SAME
end

-- Price table next to the vendor window ------------------------------
local panel
local panelRows = {}
local PANEL_W = 350
local PANEL_ROW_H = 48
local MAX_PANEL_ROWS = 10

local function BuildPanel()
    panel = NewFrame(MerchantFrame, "QuickStackPricePanel")
    panel:SetWidth(PANEL_W)
    panel:SetPoint("TOPLEFT", MerchantFrame, "TOPRIGHT", 0, -22)
    panel:SetBackdrop(DIALOG_BACKDROP)
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 22, -20)
    title:SetText(L.PANEL_TITLE)
    panel.title = title
end

local function GetPanelRow(i)
    local row = panelRows[i]
    if row then return row end
    row = CreateFrame("Frame", nil, panel)
    row:SetSize(PANEL_W - 40, PANEL_ROW_H - 4)
    row:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -(44 + (i - 1) * PANEL_ROW_H))
    row.icon = NewIcon(row, 24)
    row.icon:SetPoint("TOPLEFT", 6, -4)
    row.name = NewText(row, "GameFontNormal")
    row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 10, 1)
    row.name:SetWidth(170)
    row.name:SetWordWrap(false)
    row.price = NewText(row, "GameFontHighlight")
    row.price:SetPoint("TOPRIGHT", 0, -2)
    row.price:SetJustifyH("RIGHT")
    row.info = NewText(row, "GameFontHighlightSmall")
    row.info:SetPoint("TOPLEFT", row, "TOPLEFT", 44, -18)
    row.info:SetWidth(PANEL_W - 40 - 48)
    row.info:SetHeight(26)
    row.info:SetJustifyV("TOP")
    row.info:SetWordWrap(true)
    panelRows[i] = row
    return row
end

ns.RefreshPanel = function()
    if not ns.DB then return end
    if not (ns.atMerchant and ns.DB.showPanel and MerchantFrame) then
        if panel then panel:Hide() end
        return
    end
    local list = {}
    for id, e in pairs(Items()) do
        local unit = currentItems[id]
        if unit then
            local need = Need(e, id)
            list[#list + 1] = { id = id, e = e, unit = unit, need = need }
        end
    end
    table.sort(list, function(a, b) return (a.e.name or "") < (b.e.name or "") end)
    if #list == 0 then
        if panel then panel:Hide() end
        return
    end
    if not panel then BuildPanel() end
    local shown = math.min(#list, MAX_PANEL_ROWS)
    for i = 1, shown do
        local it = list[i]
        local row = GetPanelRow(i)
        row.icon:SetTexture(it.e.icon or QUESTION)
        row.name:SetText(it.e.name or ("Item " .. it.id))
        if it.need > 0 then
            row.price:SetText(string.format("x%d  %s", it.need, Coins(it.unit * it.need)))
        else
            row.price:SetText("|cff40ff40" .. L.OK .. "|r")
        end
        row.info:SetText(CompareText(it.id, it.unit, currentVendor and currentVendor.key, it.need))
        row:Show()
    end
    for i = shown + 1, #panelRows do panelRows[i]:Hide() end
    panel:SetHeight(44 + shown * PANEL_ROW_H + 16)
    panel:Show()
end

-- Price lines in item tooltips ---------------------------------------
local function AddPriceLines(tooltip, id)
    if not (ns.DB and ns.DB.showTooltip and id) then return end
    local t = ns.DB.prices[id]
    if not t then return end
    local list = {}
    for _, e in pairs(t) do list[#list + 1] = e end
    if #list == 0 then return end
    table.sort(list, function(a, b) return a.p < b.p end)
    tooltip:AddLine(" ")
    tooltip:AddLine(L.TT_TITLE, 1, 0.82, 0)
    for i = 1, math.min(4, #list) do
        local e = list[i]
        local left = e.v or "?"
        if e.z and e.z ~= "" then left = left .. " (" .. e.z .. ")" end
        left = left .. "  |cff888888" .. Age(e.t) .. "|r"
        local r, g, b = 0.8, 0.8, 0.8
        if i == 1 then r, g, b = 0.25, 1, 0.25 end
        tooltip:AddDoubleLine(left, Coins(e.p), r, g, b, 1, 1, 1)
    end
    tooltip:Show()
end

local function SafeAddPriceLines(tooltip, id)
    local ok, err = pcall(AddPriceLines, tooltip, id)
    if not ok then LogError(err) end
end

local function HookTooltips()
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tt, data)
            if tt ~= GameTooltip or not data then return end
            SafeAddPriceLines(tt, data.id)
        end)
    elseif GameTooltip and GameTooltip.HookScript then
        GameTooltip:HookScript("OnTooltipSetItem", function(tt)
            local _, link = tt:GetItem()
            local id = link and tonumber(link:match("item:(%d+)"))
            SafeAddPriceLines(tt, id)
        end)
    end
end

local function OnMerchantClosed()
    currentVendor = nil
    wipe(currentItems)
    if panel then panel:Hide() end
end

ns.HookTooltips = HookTooltips
ns.OnMerchantClosed = OnMerchantClosed
ns.ScanMerchant = ScanMerchant
