-- FosterFrames - UI Frame Template Generator
-- Enhanced 1.12.1 Engine Stack

local TEXTURE  = [[Interface\AddOns\FosterFrames\globals\resources\barTexture]]
local BACKDROP = { bgFile = [[Interface\Tooltips\UI-Tooltip-Background]] }

local unitWidth, unitHeight, castBarHeight, ccIconWidth, manaBarHeight = 64, 22, 8, 28, 6

function UIElementsGetDimensions()
    return unitWidth, unitHeight, castBarHeight, ccIconWidth, manaBarHeight
end

function CreateEnemyUnitFrame(name, parentFrame)
    local btn = CreateFrame('Button', name, parentFrame)
    btn:SetWidth(unitWidth)
    btn:SetHeight(unitHeight)
    btn:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    btn.mo = false

    btn.border = CreateBorder(nil, btn, 12.8, 1 / 4.5)

    -- Health status bar
    btn.hpbar = CreateFrame('StatusBar', nil, btn)
    btn.hpbar:SetFrameLevel(1)
    btn.hpbar:SetStatusBarTexture(TEXTURE)
    btn.hpbar:SetWidth(unitWidth)
    btn.hpbar:SetHeight(unitHeight)
    btn.hpbar:SetMinMaxValues(0, 100)
    btn.hpbar:SetPoint('TOPLEFT', btn, 'TOPLEFT', 0, 0)
    btn.hpbar:SetBackdrop(BACKDROP)
    btn.hpbar:SetBackdropColor(0, 0, 0, 0.6)
    SmoothBar(btn.hpbar)

    -- Mana status bar
    btn.manabar = CreateFrame('StatusBar', nil, btn)
    btn.manabar:SetFrameLevel(1)
    btn.manabar:SetStatusBarTexture(TEXTURE)
    btn.manabar:SetHeight(manaBarHeight)
    btn.manabar:SetWidth(unitWidth)
    btn.manabar:SetPoint('TOPLEFT', btn.hpbar, 'BOTTOMLEFT', 0, 0)
    btn.manabar:SetBackdrop(BACKDROP)
    btn.manabar:SetBackdropColor(0, 0, 0, 0.6)
    SmoothBar(btn.manabar)

    -- Cast bar
    btn.ffCastbar = CreateFrame('StatusBar', nil, btn)
    btn.ffCastbar:SetStatusBarTexture(TEXTURE)
    btn.ffCastbar:SetHeight(castBarHeight)
    btn.ffCastbar:SetWidth((unitWidth + ccIconWidth + 4) - castBarHeight)
    btn.ffCastbar:SetStatusBarColor(1, 0.4, 0)
    btn.ffCastbar:SetPoint('TOPLEFT', btn, 'BOTTOMLEFT', castBarHeight, -3)
    btn.ffCastbar:SetBackdrop(BACKDROP)
    btn.ffCastbar:SetBackdropColor(0, 0, 0, 0.6)

    btn.ffCastbar.b = CreateBorder(nil, btn.ffCastbar, 9)
    btn.ffCastbar.b:SetPadding(0.4)

    btn.ffCastbar.iconborder = CreateFrame('Frame', nil, btn.ffCastbar)
    btn.ffCastbar.iconborder:SetWidth(castBarHeight + 1)
    btn.ffCastbar.iconborder:SetHeight(castBarHeight + 1)
    btn.ffCastbar.iconborder:SetPoint('RIGHT', btn.ffCastbar, 'LEFT', 0, 0)
    btn.ffCastbar.iconborder.border = CreateBorder(nil, btn.ffCastbar.iconborder, 8)

    btn.ffCastbar.icon = btn.ffCastbar.iconborder:CreateTexture(nil, 'ARTWORK')
    btn.ffCastbar.icon:SetTexCoord(0.078, 0.92, 0.079, 0.937)
    btn.ffCastbar.icon:SetAllPoints()

    btn.ffCastbar.text = btn.ffCastbar:CreateFontString(nil, 'OVERLAY')
    btn.ffCastbar.text:SetTextColor(1, 1, 1)
    btn.ffCastbar.text:SetFont(STANDARD_TEXT_FONT, 8, 'OUTLINE')
    btn.ffCastbar.text:SetShadowColor(0, 0, 0)
    btn.ffCastbar.text:SetPoint('LEFT', btn.ffCastbar, 'LEFT', 1, 0.5)

    btn.ffCastbar.timer = btn.ffCastbar:CreateFontString(nil, 'OVERLAY')
    btn.ffCastbar.timer:SetFont(STANDARD_TEXT_FONT, 7, 'OUTLINE')
    btn.ffCastbar.timer:SetTextColor(1, 1, 1)
    btn.ffCastbar.timer:SetShadowColor(0, 0, 0)
    btn.ffCastbar.timer:SetPoint('RIGHT', btn.ffCastbar, 'RIGHT', 0, 0)
    btn.ffCastbar.timer:SetText('1.5')

    -- Name text
    btn.name = btn:CreateFontString(nil, 'OVERLAY')
    btn.name:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE')
    btn.name:SetTextColor(0.8, 0.8, 0.8, 0.8)
    btn.name:SetPoint('CENTER', btn.hpbar, 'CENTER', 0, 0)

    -- Health value text
    btn.hpText = btn.hpbar:CreateFontString(nil, 'OVERLAY')
    btn.hpText:SetFont(STANDARD_TEXT_FONT, 8, 'OUTLINE')
    btn.hpText:SetTextColor(1, 1, 1, 0.9)
    btn.hpText:SetPoint('CENTER', btn.hpbar, 'CENTER', 0, 0)
    btn.hpText:Hide()

    -- Mana value text
    btn.manaText = btn.manabar:CreateFontString(nil, 'OVERLAY')
    btn.manaText:SetFont(STANDARD_TEXT_FONT, 8, 'OUTLINE')
    btn.manaText:SetTextColor(1, 1, 1, 0.9)
    btn.manaText:SetPoint('CENTER', btn.manabar, 'CENTER', 0, 0)
    btn.manaText:Hide()

    -- Target count badge
    btn.targetCount = CreateFrame('Frame', nil, btn)
    btn.targetCount:SetWidth(ccIconWidth - 2)
    btn.targetCount:SetHeight(unitHeight - 2)
    btn.targetCount:SetPoint('CENTER', btn, 'TOPLEFT', 1, -1)
    btn.targetCount:SetFrameLevel(7)

    btn.targetCount.text = btn.targetCount:CreateFontString(nil, 'OVERLAY')
    btn.targetCount.text:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE')
    btn.targetCount.text:SetTextColor(0.9, 0.9, 0.2, 1)
    btn.targetCount.text:SetShadowOffset(1, -1)
    btn.targetCount.text:SetShadowColor(0, 0, 0)
    btn.targetCount.text:SetPoint('CENTER', btn.targetCount)
    btn.targetCount.text:SetText('')

    -- Raid target icon
    btn.raidTarget = CreateFrame('Frame', nil, btn)
    btn.raidTarget:SetWidth(ccIconWidth - 2)
    btn.raidTarget:SetHeight(unitHeight - 2)
    btn.raidTarget:SetPoint('CENTER', btn, 'TOPRIGHT', 0, -4)
    btn.raidTarget:SetFrameLevel(7)

    btn.raidTarget.icon = btn.raidTarget:CreateTexture(nil, 'ARTWORK')
    btn.raidTarget.icon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
    btn.raidTarget.icon:SetAllPoints()

    -- CC / Class / Spec icon
    btn.cc = CreateFrame('Frame', name .. 'CC', btn)
    btn.cc:SetWidth(ccIconWidth)
    btn.cc:SetHeight(unitHeight)
    btn.cc:SetPoint('TOPLEFT', btn, 'TOPRIGHT', 3, 0)

    btn.cc.border = CreateBorder(nil, btn.cc, 12.8, 1 / 4.5)
    btn.cc.border:SetFrameLevel(5)

    btn.cc.icon = btn.cc:CreateTexture(nil, 'ARTWORK')
    btn.cc.icon:SetAllPoints()
    btn.cc.icon:SetTexCoord(0.1, 0.9, 0.25, 0.75)

    btn.cc.bg = btn.cc:CreateTexture(nil, 'BACKGROUND')
    btn.cc.bg:SetTexture(0, 0, 0, 0.6)
    btn.cc.bg:SetAllPoints()

    btn.cc.durationFrame = CreateFrame('Frame', nil, btn.cc)
    btn.cc.durationFrame:SetAllPoints()
    btn.cc.durationFrame:SetFrameLevel(6)

    btn.cc.duration = btn.cc.durationFrame:CreateFontString(nil, 'OVERLAY')
    btn.cc.duration:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')
    btn.cc.duration:SetTextColor(0.9, 0.9, 0.2, 1)
    btn.cc.duration:SetShadowOffset(1, -1)
    btn.cc.duration:SetShadowColor(0, 0, 0)
    btn.cc.duration:SetPoint('BOTTOM', btn.cc, 'BOTTOM', 0, 1)

    btn.cc.cd = CreateCooldown(btn.cc, 0.58, true)
    btn.cc.cd:SetAlpha(1)

    -- Trinket icon
    btn.trinket = CreateFrame('Frame', name .. 'Trinket', btn)
    btn.trinket:SetWidth(ccIconWidth)
    btn.trinket:SetHeight(unitHeight)
    btn.trinket:SetPoint('TOPLEFT', btn.cc, 'TOPRIGHT', 3, 0)

    btn.trinket.border = CreateBorder(nil, btn.trinket, 12.8, 1 / 4.5)
    btn.trinket.border:SetFrameLevel(5)

    btn.trinket.icon = btn.trinket:CreateTexture(nil, 'ARTWORK')
    btn.trinket.icon:SetAllPoints()
    btn.trinket.icon:SetTexCoord(0.1, 0.9, 0.25, 0.75)

    btn.trinket.bg = btn.trinket:CreateTexture(nil, 'BACKGROUND')
    btn.trinket.bg:SetTexture(0, 0, 0, 0.6)
    btn.trinket.bg:SetAllPoints()

    btn.trinket.cd = CreateCooldown(btn.trinket, 0.58, true)
    btn.trinket.cd:SetAlpha(1)

    return btn
end