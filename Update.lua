-- QuickStack - Update notification (version exchange)
local ADDON, ns = ...
local DOWNLOAD_URL = ns.DOWNLOAD_URL
local GetMeta = ns.GetMeta
local L = ns.L
local PREFIX = ns.PREFIX
local Print = ns.Print

----------------------------------------------------------------------
-- Update notification (version exchange between players of the addon)
----------------------------------------------------------------------
local function OwnVersion()
    return GetMeta and GetMeta(ADDON, "Version") or nil
end

local function ParseVersion(v)
    local a, b, c = tostring(v or ""):match("^v?(%d+)%.?(%d*)%.?(%d*)")
    if not a then return nil end
    return { tonumber(a) or 0, tonumber(b) or 0, tonumber(c) or 0 }
end

local function CompareVersions(x, y)
    for i = 1, 3 do
        if x[i] ~= y[i] then return x[i] > y[i] and 1 or -1 end
    end
    return 0
end

ns.UpdateBanner = function()
    if not (ns.menu and ns.menu.update) then return end
    local newest = ns.DB and ns.DB.newestSeen
    if newest then
        ns.menu.update:SetText("|cffff9933" .. string.format(L.UPDATE_BANNER, newest) .. "|r")
    else
        ns.menu.update:SetText("")
    end
end

local function NotifyUpdate()
    if not (ns.DB and ns.DB.newestSeen) then return end
    ns.UpdateBanner()
    if ns.DB.notifyUpdate and ns.DB.notifiedVersion ~= ns.DB.newestSeen then
        ns.DB.notifiedVersion = ns.DB.newestSeen
        Print("|cffff9933" .. string.format(L.UPDATE_AVAILABLE, ns.DB.newestSeen, OwnVersion() or "?") .. "|r")
        Print(string.format(L.UPDATE_LINK, DOWNLOAD_URL))
    end
end

local function SendVersion(channel, target)
    local v = OwnVersion()
    if not (v and ParseVersion(v)) then return end
    local send = (C_ChatInfo and C_ChatInfo.SendAddonMessage) or SendAddonMessage
    if send then pcall(send, PREFIX, "V:" .. v, channel, target) end
end

local lastBroadcast = 0
local function BroadcastVersion()
    if time() - lastBroadcast < 30 then return end
    lastBroadcast = time()
    if IsInGuild and IsInGuild() then SendVersion("GUILD") end
    if IsInRaid and IsInRaid() then
        SendVersion("RAID")
    elseif IsInGroup and IsInGroup() then
        SendVersion("PARTY")
    end
    if IsInGroup and LE_PARTY_CATEGORY_INSTANCE and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        SendVersion("INSTANCE_CHAT")
    end
end

local replied = {}
local function OnRemoteVersion(text, channel, sender)
    local v = tostring(text or ""):match("^V:(.+)$")
    local remote, own = ParseVersion(v), ParseVersion(OwnVersion())
    if not (remote and own and ns.DB) then return end
    local c = CompareVersions(remote, own)
    if c > 0 then
        local known = ParseVersion(ns.DB.newestSeen)
        if not known or CompareVersions(remote, known) > 0 then ns.DB.newestSeen = v end
        NotifyUpdate()
    elseif c < 0 and channel ~= "WHISPER" and sender and not replied[sender] then
        -- tell players with an older version about ours so the news spreads
        replied[sender] = true
        SendVersion("WHISPER", sender)
    end
end

ns.BroadcastVersion = BroadcastVersion
ns.CompareVersions = CompareVersions
ns.NotifyUpdate = NotifyUpdate
ns.OnRemoteVersion = OnRemoteVersion
ns.OwnVersion = OwnVersion
ns.ParseVersion = ParseVersion
