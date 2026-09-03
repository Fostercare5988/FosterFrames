-- FosterFrames - Modernized UI Frame Template Generator
-- Enhanced 1.12.1 Engine Stack (ClassicAPI, SuperWoW, UnitXP SP3)

local TEXTURE  = [[Interface\AddOns\FosterFrames\globals\resources\barTexture]]
local BACKDROP = {
    bgFile   = [[Interface\Tooltips\UI-Tooltip-Background]],
    edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
    tile     = true,
    tileSize = 8,
    edgeSize = 8,
    insets   = { left = 1, right = 1, top = 1, bottom = 1 }
}

local unitWidth, unitHeight = 150, 24
local hpWidth, hpHeight = 124, 24
local manaBarHeight = 3
local iconSize = 24
local castBarHeight = 24

function UIElementsGetDimensions()
    return unitWidth, unitHeight, hpWidth, hpHeight, manaBarHeight, iconSize, castBarHeight
end


function CreateEnemyUnitFrame(name, parentFrame)
    local btn = CreateFrame('Button', name, parentFrame)
    btn:SetWidth(unitWidth)
    btn:SetHeight(unitHeight)
    btn:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'LeftButtonDown', 'RightButtonDown')
    btn:EnableMouse(true)
    btn.mo = false

    -- Health status bar (Smooth class-colored bar)
    btn.hpbar = CreateFrame('StatusBar', nil, btn)
    btn.hpbar:SetFrameLevel(1)
    btn.hpbar:EnableMouse(false)
    btn.hpbar:SetStatusBarTexture(TEXTURE)
    btn.hpbar:SetWidth(hpWidth)
    btn.hpbar:SetHeight(hpHeight)
    btn.hpbar:SetMinMaxValues(0, 100)
    btn.hpbar:SetPoint('TOPLEFT', btn, 'TOPLEFT', 0, 0)
    btn.hpbar:SetBackdrop({ bgFile = [[Interface\Tooltips\UI-Tooltip-Background]] })
    btn.hpbar:SetBackdropColor(0, 0, 0, 0.65)
    SmoothBar(btn.hpbar)

    btn.hpbar.border = CreateBorder(nil, btn.hpbar, 10, 1 / 5)
    btn.hpbar.border:SetFrameLevel(2)

    -- Mana / Power Status Bar (Embedded 3px hairline bar at bottom of card)
    btn.manabar = CreateFrame('StatusBar', nil, btn.hpbar)
    btn.manabar:SetFrameLevel(2)
    btn.manabar:EnableMouse(false)
    btn.manabar:SetStatusBarTexture(TEXTURE)
    btn.manabar:SetHeight(manaBarHeight)
    btn.manabar:SetPoint('BOTTOMLEFT', btn.hpbar, 'BOTTOMLEFT', 0, 0)
    btn.manabar:SetPoint('BOTTOMRIGHT', btn.hpbar, 'BOTTOMRIGHT', 0, 0)
    btn.manabar:SetBackdrop({ bgFile = [[Interface\Tooltips\UI-Tooltip-Background]] })
    btn.manabar:SetBackdropColor(0, 0, 0, 0.7)
    btn.manabar:Hide()
    SmoothBar(btn.manabar)

    -- Class / Spell / CC Icon (Flush on right edge, matching card height)
    btn.cc = CreateFrame('Frame', name .. 'CC', btn)
    btn.cc:EnableMouse(false)
    btn.cc:SetWidth(iconSize)
    btn.cc:SetHeight(iconSize)
    btn.cc:SetPoint('LEFT', btn.hpbar, 'RIGHT', 2, 0)
    btn.cc:SetFrameLevel(3)

    btn.cc.border = CreateBorder(nil, btn.cc, 10, 1 / 5)
    btn.cc.border:SetFrameLevel(5)
    btn.cc.border:EnableMouse(false)

    btn.cc.icon = btn.cc:CreateTexture(nil, 'ARTWORK')
    btn.cc.icon:SetAllPoints()
    btn.cc.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    btn.cc.bg = btn.cc:CreateTexture(nil, 'BACKGROUND')
    btn.cc.bg:SetTexture(0, 0, 0, 0.7)
    btn.cc.bg:SetAllPoints()

    btn.cc.durationFrame = CreateFrame('Frame', nil, btn.cc)
    btn.cc.durationFrame:SetAllPoints()
    btn.cc.durationFrame:SetFrameLevel(6)
    btn.cc.durationFrame:EnableMouse(false)

    btn.cc.duration = btn.cc.durationFrame:CreateFontString(nil, 'OVERLAY')
    btn.cc.duration:SetFont(STANDARD_TEXT_FONT, 9, 'OUTLINE')
    btn.cc.duration:SetTextColor(0.95, 0.95, 0.2, 1)
    btn.cc.duration:SetShadowOffset(1, -1)
    btn.cc.duration:SetShadowColor(0, 0, 0)
    btn.cc.duration:SetPoint('BOTTOM', btn.cc, 'BOTTOM', 0, 1)

    btn.cc.cd = CreateCooldown(btn.cc, 0.58, true)
    btn.cc.cd:SetAlpha(1)
    btn.cc.cd:EnableMouse(false)

    -- Integrated In-Card Castbar (Overlay directly inside hpbar - Zero overlap between rows!)
    btn.ffCastbar = CreateFrame('StatusBar', nil, btn.hpbar)
    btn.ffCastbar:SetFrameLevel(4)
    btn.ffCastbar:EnableMouse(false)
    btn.ffCastbar:SetStatusBarTexture(TEXTURE)
    btn.ffCastbar:SetAllPoints(btn.hpbar)
    btn.ffCastbar:SetStatusBarColor(1.0, 0.55, 0.0, 0.9)
    btn.ffCastbar:SetBackdrop({ bgFile = [[Interface\Tooltips\UI-Tooltip-Background]] })
    btn.ffCastbar:SetBackdropColor(0, 0, 0, 0.75)
    btn.ffCastbar:Hide()

    btn.ffCastbar.text = btn.ffCastbar:CreateFontString(nil, 'OVERLAY')
    btn.ffCastbar.text:SetTextColor(1, 1, 1, 1)
    btn.ffCastbar.text:SetFont(STANDARD_TEXT_FONT, 9, 'OUTLINE')
    btn.ffCastbar.text:SetShadowColor(0, 0, 0)
    btn.ffCastbar.text:SetShadowOffset(1, -1)
    btn.ffCastbar.text:SetPoint('LEFT', btn.ffCastbar, 'LEFT', 4, 0)
    btn.ffCastbar.text:SetJustifyH('LEFT')

    btn.ffCastbar.timer = btn.ffCastbar:CreateFontString(nil, 'OVERLAY')
    btn.ffCastbar.timer:SetFont(STANDARD_TEXT_FONT, 8, 'OUTLINE')
    btn.ffCastbar.timer:SetTextColor(1, 0.9, 0.3, 1)
    btn.ffCastbar.timer:SetShadowColor(0, 0, 0)
    btn.ffCastbar.timer:SetShadowOffset(1, -1)
    btn.ffCastbar.timer:SetPoint('RIGHT', btn.ffCastbar, 'RIGHT', -4, 0)
    btn.ffCastbar.timer:SetJustifyH('RIGHT')
    btn.ffCastbar.timer:SetText('1.5s')

    btn.ffCastbar.b = btn.hpbar.border

    -- Name text (Left Aligned on HP Bar)
    btn.name = btn.hpbar:CreateFontString(nil, 'OVERLAY')
    btn.name:SetFont(STANDARD_TEXT_FONT, 9, 'OUTLINE')
    btn.name:SetTextColor(0.95, 0.95, 0.95, 1)
    btn.name:SetShadowOffset(1, -1)
    btn.name:SetShadowColor(0, 0, 0)
    btn.name:SetPoint('LEFT', btn.hpbar, 'LEFT', 4, 0)
    btn.name:SetJustifyH('LEFT')

    -- Live 3D Distance text (Right next to Name)
    btn.distText = btn.hpbar:CreateFontString(nil, 'OVERLAY')
    btn.distText:SetFont(STANDARD_TEXT_FONT, 8, 'OUTLINE')
    btn.distText:SetTextColor(0.4, 1.0, 0.4, 0.95)
    btn.distText:SetShadowOffset(1, -1)
    btn.distText:SetShadowColor(0, 0, 0)
    btn.distText:SetPoint('LEFT', btn.name, 'RIGHT', 3, 0)
    btn.distText:SetJustifyH('LEFT')
    btn.distText:Hide()

    -- Health value text (Right Aligned on HP Bar)
    btn.hpText = btn.hpbar:CreateFontString(nil, 'OVERLAY')
    btn.hpText:SetFont(STANDARD_TEXT_FONT, 8, 'OUTLINE')
    btn.hpText:SetTextColor(1, 1, 1, 0.95)
    btn.hpText:SetShadowOffset(1, -1)
    btn.hpText:SetShadowColor(0, 0, 0)
    btn.hpText:SetPoint('RIGHT', btn.hpbar, 'RIGHT', -4, 0)
    btn.hpText:SetJustifyH('RIGHT')

    -- Mana value text
    btn.manaText = btn.manabar:CreateFontString(nil, 'OVERLAY')
    btn.manaText:SetFont(STANDARD_TEXT_FONT, 7, 'OUTLINE')
    btn.manaText:SetTextColor(1, 1, 1, 0.9)
    btn.manaText:SetPoint('RIGHT', btn.manabar, 'RIGHT', -2, 0)
    btn.manaText:SetJustifyH('RIGHT')
    btn.manaText:Hide()

    -- Target count badge (Modern Focus Fire Badge on top-left of Card)
    btn.targetCount = CreateFrame('Frame', nil, btn.hpbar)
    btn.targetCount:SetWidth(14)
    btn.targetCount:SetHeight(14)
    btn.targetCount:SetPoint('TOPLEFT', btn.hpbar, 'TOPLEFT', 0, 2)
    btn.targetCount:SetFrameLevel(7)
    btn.targetCount:EnableMouse(false)

    btn.targetCount.text = btn.targetCount:CreateFontString(nil, 'OVERLAY')
    btn.targetCount.text:SetFont(STANDARD_TEXT_FONT, 9, 'OUTLINE')
    btn.targetCount.text:SetTextColor(1, 0.85, 0.1, 1)
    btn.targetCount.text:SetShadowOffset(1, -1)
    btn.targetCount.text:SetShadowColor(0, 0, 0)
    btn.targetCount.text:SetPoint('CENTER', btn.targetCount)
    btn.targetCount.text:SetText('')

    btn.border = btn.hpbar.border

    return btn
end