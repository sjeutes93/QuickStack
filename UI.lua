-- QuickStack - UI toolkit in the native WoW look
local ADDON, ns = ...
local MAX_SLIDER = ns.MAX_SLIDER

----------------------------------------------------------------------
-- UI toolkit (native WoW look: dialog frame, panel buttons, slider bars)
----------------------------------------------------------------------
local TPL = BackdropTemplateMixin and "BackdropTemplate" or nil

local DIALOG_BACKDROP = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
}
local TOOLTIP_BACKDROP = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}
local SLIDER_BACKDROP = {
    bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
    edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = { left = 3, right = 3, top = 6, bottom = 6 },
}

local function Box(f)
    f:SetBackdrop(TOOLTIP_BACKDROP)
    f:SetBackdropColor(0, 0, 0, 0.55)
    f:SetBackdropBorderColor(0.7, 0.7, 0.7, 1)
end

local function NewFrame(parent, name)
    return CreateFrame("Frame", name, parent, TPL)
end

local function NewText(parent, template)
    local fs = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlight")
    fs:SetJustifyH("LEFT")
    return fs
end

local function NewButton(parent, text, w, h)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(w, h)
    b:SetText(text)
    return b
end

local function SetSelected(button, selected)
    if selected then button:LockHighlight() else button:UnlockHighlight() end
end

-- Item icon with the classic action-button frame around it
local function NewIcon(parent, size)
    local tex = parent:CreateTexture(nil, "ARTWORK")
    tex:SetSize(size, size)
    tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    local border = parent:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    border:SetSize(size * 1.8, size * 1.8)
    border:SetPoint("CENTER", tex, "CENTER", 0, -1)
    return tex
end

local function NewSlider(parent, w)
    local s = CreateFrame("Slider", nil, parent, TPL)
    s:SetOrientation("HORIZONTAL")
    s:SetSize(w, 17)
    s:SetBackdrop(SLIDER_BACKDROP)
    s:SetMinMaxValues(1, MAX_SLIDER)
    s:SetValueStep(1)
    if s.SetObeyStepOnDrag then s:SetObeyStepOnDrag(true) end
    s:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    local thumb = s:GetThumbTexture()
    if thumb then thumb:SetSize(32, 32) end
    s:EnableMouse(true)
    return s
end

local function NewInput(parent, w, h, numeric)
    local e = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    e:SetSize(w, h)
    e:SetAutoFocus(false)
    if numeric then
        e:SetNumeric(true)
        e:SetMaxLetters(5)
        e:SetJustifyH("CENTER")
    end
    e:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    return e
end

local function NewCheck(parent, label, getter, setter)
    local b = CreateFrame("CheckButton", nil, parent)
    b:SetSize(26, 26)
    b:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
    b:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
    b:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")
    b:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    local fs = NewText(b, "GameFontHighlight")
    fs:SetPoint("LEFT", b, "RIGHT", 4, 1)
    fs:SetText(label)
    function b:Refresh()
        self:SetChecked(getter() and true or false)
    end
    b:SetScript("OnClick", function(self)
        setter(self:GetChecked() and true or false)
    end)
    return b
end

local function NewScroll(parent, w, h)
    local scroll = CreateFrame("ScrollFrame", nil, parent)
    scroll:SetSize(w, h)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local cur, max = self:GetVerticalScroll(), self:GetVerticalScrollRange()
        self:SetVerticalScroll(math.max(0, math.min(max, cur - delta * 40)))
    end)
    return scroll
end

local function NewMultiline(parent, w, h)
    local box = NewFrame(parent)
    box:SetSize(w, h)
    Box(box)
    local scroll = NewScroll(box, w - 14, h - 14)
    scroll:SetPoint("TOPLEFT", 7, -7)
    local eb = CreateFrame("EditBox", nil, scroll)
    eb:SetMultiLine(true)
    eb:SetFontObject(ChatFontNormal)
    eb:SetWidth(w - 14)
    eb:SetHeight(h - 14)
    eb:SetAutoFocus(false)
    eb:SetTextInsets(2, 2, 2, 2)
    eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    scroll:SetScrollChild(eb)
    scroll:EnableMouse(true)
    scroll:SetScript("OnMouseDown", function() eb:SetFocus() end)
    return box, eb
end


local function NewDeleteButton(parent)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(24, 24)
    b:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
    b:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Down")
    b:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Highlight", "ADD")
    return b
end

ns.Box = Box
ns.DIALOG_BACKDROP = DIALOG_BACKDROP
ns.NewButton = NewButton
ns.NewCheck = NewCheck
ns.NewDeleteButton = NewDeleteButton
ns.NewFrame = NewFrame
ns.NewIcon = NewIcon
ns.NewInput = NewInput
ns.NewMultiline = NewMultiline
ns.NewScroll = NewScroll
ns.NewSlider = NewSlider
ns.NewText = NewText
ns.SetSelected = SetSelected
ns.TPL = TPL
