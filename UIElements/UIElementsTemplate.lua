-- FosterFrames - UI Frame Template Generator
-- Enhanced 1.12.1 Engine Stack

local TEXTURE  = [[Interface\AddOns\FosterFrames\globals\resources\barTexture]]
local BACKDROP = { bgFile = [[Interface\Tooltips\UI-Tooltip-Background]] }

local unitWidth, unitHeight = 126, 24
local hpWidth, hpHeight = 100, 18
local manaBarHeight = 5
local iconSize = 23
local castBarHeight = 9

function UIElementsGetDimensions()
    return unitWidth, unitHeight, hpWidth, hpHeight, manaBarHeight, iconSize, castBarHeight
end

function CreateEnemyUnitFrame(name, parentFrame)
    local btn = CreateFrame('Button', name, parentFrame)
    btn:SetWidth(unitWidth)
    btn:SetHeight(unitHeight)
    btn:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    btn.mo = false

    btn.border = CreateBorder(nil, btn, 12.8, 1 / 4.5)

    -- Health status bar (100 x 18)
    btn.hpbar = CreateFrame('StatusBar', nil, btn)
    btn.hpbar:SetFrameLevel(1)
    btn.hpbar:SetStatusBarTexture(TEXTURE)
    btn.hpbar:SetWidth(hpWidth)
    btn.hpbar:SetHeight(hpHeight)
    btn.hpbar:SetMinMaxValues(0, 100)
    btn.hpbar:SetPoint('TOPLEFT', btn, 'TOPLEFT', 0, 0)
    btn.hpbar:SetBackdrop(BACKDROP)
    btn.hpbar:SetBackdropColor(0, 0, 0, 0.6)
    SmoothBar(btn.hpbar)

    -- Mana status bar (100 x 5)
    btn.manabar = CreateFrame('StatusBar', nil, btn)
    btn.manabar:SetFrameLevel(1)
    btn.manabar:SetStatusBarTexture(TEXTURE)
    btn.manabar:SetHeight(manaBarHeight)
    btn.manabar:SetWidth(hpWidth)
    btn.manabar:SetPoint('TOPLEFT', btn.hpbar, 'BOTTOMLEFT', 0, 0)
    btn.manabar:SetBackdrop(BACKDROP)
    btn.manabar:SetBackdropColor(0, 0, 0, 0.6)
    SmoothBar(btn.manabar)

    -- CC / Class / Spec icon (23 x 23 flush on right side)
    btn.cc = CreateFrame('Frame', name .. 'CC', btn)
    btn.cc:SetWidth(iconSize)
    btn.cc:SetHeight(iconSize)
    btn.cc:SetPoint('TOPLEFT', btn, 'TOPLEFT', hpWidth + 3, 0)

    btn.cc.border = CreateBorder(nil, btn.cc, 12.8, 1 / 4.5)
    btn.cc.border:SetFrameLevel(5)

    btn.cc.icon = btn.cc:CreateTexture(nil, 'ARTWORK')
    btn.cc.icon:SetAllPoints()
    btn.cc.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    btn.cc.bg = btn.cc:CreateTexture(nil, 'BACKGROUND')
    btn.cc.bg:SetTexture(0, 0, 0, 0.6)
    btn.cc.bg:SetAllPoints()

    btn.cc.durationFrame = CreateFrame('Frame', nil, btn.cc)
    btn.cc.durationFrame:SetAllPoints()
    btn.cc.durationFrame:SetFrameLevel(6)

    btn.cc.duration = btn.cc.durationFrame:CreateFontString(nil, 'OVERLAY')
    btn.cc.duration:SetFont(STANDARD_TEXT_FONT, 9, 'OUTLINE')
    btn.cc.duration:SetTextColor(0.9, 0.9, 0.2, 1)
    btn.cc.duration:SetShadowOffset(1, -1)
    btn.cc.duration:SetShadowColor(0, 0, 0)
    btn.cc.duration:SetPoint('BOTTOM', btn.cc, 'BOTTOM', 0, 1)

    btn.cc.cd = CreateCooldown(btn.cc, 0.58, true)
    btn.cc.cd:SetAlpha(1)

    -- Cast bar (Attaches beneath card when casting)
    btn.ffCastbar = CreateFrame('StatusBar', nil, btn)
    btn.ffCastbar:SetStatusBarTexture(TEXTURE)
    btn.ffCastbar:SetHeight(castBarHeight)
    btn.ffCastbar:SetWidth(unitWidth - castBarHeight - 2)
    btn.ffCastbar:SetStatusBarColor(1, 0.4, 0)
    btn.ffCastbar:SetPoint('TOPLEFT', btn, 'BOTTOMLEFT', castBarHeight + 1, -1)
    btn.ffCastbar:SetBackdrop(BACKDROP)
    btn.ffCastbar:SetBackdropColor(0, 0, 0, 0.7)
    btn.ffCastbar:Hide()

    btn.ffCastbar.b = CreateBorder(nil, btn.ffCastbar, 9)
    btn.ffCastbar.b:SetPadding(0.4)

    btn.ffCastbar.iconborder = CreateFrame('Frame', nil, btn.ffCastbar)
    btn.ffCastbar.iconborder:SetWidth(castBarHeight + 1)
    btn.ffCastbar.iconborder:SetHeight(castBarHeight + 1)
    btn.ffCastbar.iconborder:SetPoint('RIGHT', btn.ffCastbar, 'LEFT', -1, 0)
    btn.ffCastbar.iconborder.border = CreateBorder(nil, btn.ffCastbar.iconborder, 8)

    btn.ffCastbar.icon = btn.ffCastbar.iconborder:CreateTexture(nil, 'ARTWORK')
    btn.ffCastbar.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    btn.ffCastbar.icon:SetAllPoints()

    btn.ffCastbar.text = btn.ffCastbar:CreateFontString(nil, 'OVERLAY')
    btn.ffCastbar.text:SetTextColor(1, 1, 1)
    btn.ffCastbar.text:SetFont(STANDARD_TEXT_FONT, 8, 'OUTLINE')
    btn.ffCastbar.text:SetShadowColor(0, 0, 0)
    btn.ffCastbar.text:SetPoint('LEFT', btn.ffCastbar, 'LEFT', 2, 0)

    btn.ffCastbar.timer = btn.ffCastbar:CreateFontString(nil, 'OVERLAY')
    btn.ffCastbar.timer:SetFont(STANDARD_TEXT_FONT, 7, 'OUTLINE')
    btn.ffCastbar.timer:SetTextColor(1, 1, 1)
    btn.ffCastbar.timer:SetShadowColor(0, 0, 0)
    btn.ffCastbar.timer:SetPoint('RIGHT', btn.ffCastbar, 'RIGHT', -1, 0)
    btn.ffCastbar.timer:SetText('1.5')

    -- Name text (Left Aligned on HP Bar)
    btn.name = btn:CreateFontString(nil, 'OVERLAY')
    btn.name:SetFont(STANDARD_TEXT_FONT, 9, 'OUTLINE')
    btn.name:SetTextColor(0.9, 0.9, 0.9, 0.9)
    btn.name:SetPoint('LEFT', btn.hpbar, 'LEFT', 3, 0)
    btn.name:SetJustifyH('LEFT')

    -- Health value text (Right Aligned on HP Bar)
    btn.hpText = btn.hpbar:CreateFontString(nil, 'OVERLAY')
    btn.hpText:SetFont(STANDARD_TEXT_FONT, 8, 'OUTLINE')
    btn.hpText:SetTextColor(1, 1, 1, 0.95)
    btn.hpText:SetPoint('RIGHT', btn.hpbar, 'RIGHT', -2, 0)
    btn.hpText:SetJustifyH('RIGHT')

    -- Mana value text
    btn.manaText = btn.manabar:CreateFontString(nil, 'OVERLAY')
    btn.manaText:SetFont(STANDARD_TEXT_FONT, 7, 'OUTLINE')
    btn.manaText:SetTextColor(1, 1, 1, 0.9)
    btn.manaText:SetPoint('RIGHT', btn.manabar, 'RIGHT', -2, 0)
    btn.manaText:SetJustifyH('RIGHT')
    btn.manaText:Hide()

    -- Target count badge
    btn.targetCount = CreateFrame('Frame', nil, btn)
    btn.targetCount:SetWidth(14)
    btn.targetCount:SetHeight(14)
    btn.targetCount:SetPoint('TOPLEFT', btn.hpbar, 'TOPLEFT', 1, -1)
    btn.targetCount:SetFrameLevel(7)

    btn.targetCount.text = btn.targetCount:CreateFontString(nil, 'OVERLAY')
    btn.targetCount.text:SetFont(STANDARD_TEXT_FONT, 9, 'OUTLINE')
    btn.targetCount.text:SetTextColor(1, 0.85, 0.1, 1)
    btn.targetCount.text:SetShadowOffset(1, -1)
    btn.targetCount.text:SetShadowColor(0, 0, 0)
    btn.targetCount.text:SetPoint('CENTER', btn.targetCount)
    btn.targetCount.text:SetText('')

    return btn
end