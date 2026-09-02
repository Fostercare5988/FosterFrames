-- FosterFrames - Main Visual Frame Suite
-- Enhanced 1.12.1 Engine Stack (ClassicAPI, SuperWoW, NamPower, UnitXP SP3, DXVK)

-- Mandatory Engine Dependency Guard
if not (CLASSIC_API_VERSION and SUPERWOW_VERSION) then
    DEFAULT_CHAT_FRAME:AddMessage("|cffff2020[Fatal Error]|r FosterFrames requires ClassicAPI.dll & SuperWoW! Please ensure ClassicAPI.dll and SuperWoW are loaded.", 1, 0.2, 0.2)
    return
end

local playerFaction
local insideBG = false
local enemyFactionColor = { r = 1, g = 0.1, b = 0.1 }

-- Timers & Refresh Intervals
local rtMenuInterval = 5
local rtMenuEndtime = 0
local refreshInterval = 1 / 60
local nextRefresh = 0

-- Unit Limits & Collections
local unitLimit = 15
local maxUnits = 15
local units = {}
local raidTargets = {}
local raidIcons, raidIconsN = { [1] = 'skull', [2] = 'moon', [3] = 'square', [4] = 'triangle', [5] = 'star', [6] = 'diamond', [7] = 'cross', [8] = 'circle' }, 8

local enabled = false
FOSTERFRAMES_DEBUG = false
FOSTERFRAMES_TESTMODE = false
MOUSEOVERUNINAME = nil

local BACKDROP = { bgFile = [[Interface\Tooltips\UI-Tooltip-Background]] }

-- Main Display Container
fosterFrameDisplay = CreateFrame('Frame', 'fosterFrameDisplay', UIParent)
fosterFrame = fosterFrameDisplay
fosterFrame:SetFrameStrata("LOW")
fosterFrame:SetPoint('CENTER', UIParent, 0, 100)
fosterFrame:SetHeight(20)
fosterFrame:SetMovable(true)
fosterFrame:SetClampedToScreen(true)

fosterFrame:SetScript('OnDragStart', function()
    local frame = this or self
    if (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['frameMovable']) or (fosterFramesSettings and fosterFramesSettings:IsShown()) then
        frame:StartMoving()
    end
end)

fosterFrame:SetScript('OnDragStop', function()
    local frame = this or self
    frame:StopMovingOrSizing()
end)

fosterFrame:RegisterForDrag('LeftButton')
fosterFrame:EnableMouse(true)

fosterFrame.bg = fosterFrame:CreateTexture(nil, 'BACKGROUND')
fosterFrame.bg:SetAllPoints()
fosterFrame.bg:SetTexture(0, 0, 0, 0.6)
fosterFrame.bg:Hide()

fosterFrame.Title = fosterFrame:CreateFontString(nil, 'OVERLAY')
fosterFrame.Title:SetFont(STANDARD_TEXT_FONT, 12, 'OUTLINE')
fosterFrame.Title:SetPoint('CENTER', fosterFrame, 'CENTER', 0, 1)

fosterFrame.totalPlayers = fosterFrame:CreateFontString(nil, 'OVERLAY')
fosterFrame.totalPlayers:SetFont(STANDARD_TEXT_FONT, 12, 'OUTLINE')
fosterFrame.totalPlayers:SetPoint('RIGHT', fosterFrame, 'RIGHT', -4, 1)
fosterFrame.totalPlayers:Hide()

-- Raid Target Indicator Frame
fosterFrame.raidTargetFrame = CreateFrame('Frame', nil, fosterFrame)
fosterFrame.raidTargetFrame:SetFrameLevel(2)
fosterFrame.raidTargetFrame:SetHeight(36)
fosterFrame.raidTargetFrame:SetWidth(36)
fosterFrame.raidTargetFrame:SetPoint('CENTER', UIParent, 'CENTER', 0, 160)
fosterFrame.raidTargetFrame:Hide()

fosterFrame.raidTargetFrame.text = fosterFrame.raidTargetFrame:CreateFontString(nil, 'OVERLAY')
fosterFrame.raidTargetFrame.text:SetFont(STANDARD_TEXT_FONT, 18, 'OUTLINE')
fosterFrame.raidTargetFrame.text:SetTextColor(0.8, 0.8, 0.8, 0.8)
fosterFrame.raidTargetFrame.text:SetPoint('CENTER', fosterFrame.raidTargetFrame, 'CENTER', 0, 0)
fosterFrame.raidTargetFrame.text:SetText('Player')

fosterFrame.raidTargetFrame.iconl = fosterFrame.raidTargetFrame:CreateTexture(nil, 'OVERLAY')
fosterFrame.raidTargetFrame.iconl:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
fosterFrame.raidTargetFrame.iconl:SetTexCoord(0.75, 1, 0.25, 0.5)
fosterFrame.raidTargetFrame.iconl:SetHeight(36)
fosterFrame.raidTargetFrame.iconl:SetWidth(36)
fosterFrame.raidTargetFrame.iconl:SetPoint('RIGHT', fosterFrame.raidTargetFrame.text, 'LEFT', -6, 0)

fosterFrame.raidTargetFrame.iconr = fosterFrame.raidTargetFrame:CreateTexture(nil, 'OVERLAY')
fosterFrame.raidTargetFrame.iconr:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
fosterFrame.raidTargetFrame.iconr:SetTexCoord(0.75, 1, 0.25, 0.5)
fosterFrame.raidTargetFrame.iconr:SetHeight(36)
fosterFrame.raidTargetFrame.iconr:SetWidth(36)
fosterFrame.raidTargetFrame.iconr:SetPoint('LEFT', fosterFrame.raidTargetFrame.text, 'RIGHT', 6, 0)

-- Raid Target Popup Menu
local rtMenuIconsize = 26
fosterFrame.raidTargetMenu = CreateFrame('Frame', nil, fosterFrame)
fosterFrame.raidTargetMenu:SetFrameLevel(7)
fosterFrame.raidTargetMenu:SetHeight(rtMenuIconsize * 2 + 4)
fosterFrame.raidTargetMenu:SetWidth(rtMenuIconsize * 4 + 10)
fosterFrame.raidTargetMenu:SetBackdrop(BACKDROP)
fosterFrame.raidTargetMenu:SetBackdropColor(0, 0, 0, 0.6)
fosterFrame.raidTargetMenu:Hide()
fosterFrame.raidTargetMenu.border = CreateBorder(nil, fosterFrame.raidTargetMenu, 10)
fosterFrame.raidTargetMenu.icons = {}

for j = 1, raidIconsN do
    local btn = CreateFrame('Button', 'fosterFrameRaidTargetMenuIcon' .. j, fosterFrame.raidTargetMenu)
    btn:SetHeight(rtMenuIconsize)
    btn:SetWidth(rtMenuIconsize)
    if j == 1 then
        btn:SetPoint('TOPLEFT', fosterFrame.raidTargetMenu, 'TOPLEFT', 1, -1)
    elseif j < 5 then
        btn:SetPoint('LEFT', fosterFrame.raidTargetMenu.icons[j - 1], 'RIGHT', 2, 0)
    else
        btn:SetPoint('TOP', fosterFrame.raidTargetMenu.icons[j - 4], 'BOTTOM', 0, -2)
    end
    btn.id = j
    btn.tex = btn:CreateTexture(nil, 'OVERLAY')
    btn.tex:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
    btn.tex:SetAlpha(0.6)
    local tCoords = RAID_TARGET_TCOORDS[raidIcons[j]]
    btn.tex:SetTexCoord(tCoords[1], tCoords[2], tCoords[3], tCoords[4])
    btn.tex:SetAllPoints()
    btn:SetScript('OnEnter', function() this.tex:SetAlpha(1) end)
    btn:SetScript('OnLeave', function() this.tex:SetAlpha(0.6) end)
    fosterFrame.raidTargetMenu.icons[j] = btn
end

local function spawnRTMenu(b, tar)
    fosterFrame.raidTargetMenu:SetPoint('TOP', b, 'BOTTOM', rtMenuIconsize / 2, 0)
    if fosterFrame.raidTargetMenu.target == tar and rtMenuEndtime > GetTime() then
        fosterFrame.raidTargetMenu:Hide()
        return
    end
    fosterFrame.raidTargetMenu.target = tar
    fosterFrame.raidTargetMenu:Show()
    rtMenuEndtime = GetTime() + rtMenuInterval
    for j = 1, raidIconsN do
        fosterFrame.raidTargetMenu.icons[j]:SetScript('OnClick', function()
            FOSTERFRAMECORESendRaidTarget(raidIcons[this.id], tar)
            fosterFrame.raidTargetMenu:Hide()
            rtMenuEndtime = 0
        end)
    end
end

local unitWidth, unitHeight, castBarHeight, ccIconWidth, manaBarHeight = UIElementsGetDimensions()
local leftSpacing = 5

-- Create Unit Frames
for i = 1, unitLimit do
    units[i] = CreateEnemyUnitFrame('fosterFrameUnit' .. i, fosterFrame)
    units[i].index = i
    units[i].hoverEnabled = false

    units[i]:SetScript('OnClick', function(self, button)
        local b = button or arg1
        local frame = self or this
        if b == 'LeftButton' and frame.tar then
            TargetByName(frame.tar, true)
        elseif b == 'RightButton' and frame.tar then
            spawnRTMenu(frame, frame.tar)
        end
    end)

    units[i]:SetScript('OnEnter', function(self)
        local frame = self or this
        if frame.hoverEnabled then
            frame.name:SetTextColor(enemyFactionColor.r, enemyFactionColor.g, enemyFactionColor.b)
            frame.mo = true
            MOUSEOVERUNINAME = frame.tar
        end
    end)

    units[i]:SetScript('OnLeave', function(self)
        local frame = self or this
        local r, g, b = frame.hpbar:GetStatusBarColor()
        if frame.hoverEnabled then
            frame.name:SetTextColor(r, g, b)
        else
            frame.name:SetTextColor(r, g, b, 0.6)
        end
        frame.mo = false
        MOUSEOVERUNINAME = nil
    end)
end

-- Mock Test Data Definition
local TEST_UNITS = {
    { name = "Gladiator", class = "WARRIOR", powerType = "rage",   hp = 4850, maxHp = 5200, mana = 65,   maxMana = 100, spell = "Mortal Strike", icon = [[Interface\Icons\Ability_Warrior_SavageBlow]],   cast = 0,   castMax = 0,   tarCount = 3, iconCoord = {0.75, 1, 0.25, 0.5} },
    { name = "HolyHeals", class = "PRIEST",  powerType = "mana",   hp = 3120, maxHp = 4100, mana = 2800, maxMana = 4900, spell = "Greater Heal",  icon = [[Interface\Icons\Spell_Holy_GreaterHeal]],       cast = 1.4, castMax = 2.5, tarCount = 2, iconCoord = nil },
    { name = "FrostBite", class = "MAGE",    powerType = "mana",   hp = 2950, maxHp = 3800, mana = 3400, maxMana = 5400, spell = "Polymorph",     icon = [[Interface\Icons\Spell_Nature_Polymorph]],       cast = 0.8, castMax = 1.5, tarCount = 1, iconCoord = nil },
    { name = "ShadowCut", class = "ROGUE",   powerType = "energy", hp = 3400, maxHp = 4400, mana = 100,  maxMana = 100,  spell = nil,             icon = nil,                                              cast = 0,   castMax = 0,   tarCount = 0, iconCoord = nil },
    { name = "MoonFire",  class = "DRUID",   powerType = "mana",   hp = 3800, maxHp = 4600, mana = 2100, maxMana = 4200, spell = "Entangling Roots", icon = [[Interface\Icons\Spell_Nature_Stranglevines]], cast = 0.6, castMax = 1.5, tarCount = 1, iconCoord = nil },
    { name = "DarkChaos", class = "WARLOCK", powerType = "mana",   hp = 4100, maxHp = 5000, mana = 3600, maxMana = 5100, spell = "Fear",             icon = [[Interface\Icons\Spell_Shadow_Possession]],       cast = 1.1, castMax = 1.5, tarCount = 0, iconCoord = nil },
    { name = "EagleEye",  class = "HUNTER",  powerType = "mana",   hp = 3600, maxHp = 4500, mana = 1900, maxMana = 3800, spell = "Aimed Shot",      icon = [[Interface\Icons\Inv_spear_07]],                  cast = 1.8, castMax = 3.0, tarCount = 0, iconCoord = nil },
    { name = "Thunder",   class = "SHAMAN",  powerType = "mana",   hp = 3900, maxHp = 4700, mana = 2200, maxMana = 4400, spell = "Chain Lightning", icon = [[Interface\Icons\Spell_Nature_ChainLightning]],  cast = 1.2, castMax = 2.0, tarCount = 1, iconCoord = nil },
    { name = "Avenger",   class = "PALADIN", powerType = "mana",   hp = 4200, maxHp = 5100, mana = 2500, maxMana = 4600, spell = "Holy Light",      icon = [[Interface\Icons\Spell_Holy_HolyBolt]],          cast = 1.6, castMax = 2.5, tarCount = 0, iconCoord = nil },
    { name = "Bladestorm",class = "WARRIOR", powerType = "rage",   hp = 2200, maxHp = 5400, mana = 25,   maxMana = 100,  spell = nil,             icon = nil,                                              cast = 0,   castMax = 0,   tarCount = 4, iconCoord = {0, 0.25, 0, 0.25} },
}

local function renderTestVisuals()
    local count = #TEST_UNITS
    for i = 1, unitLimit do
        if i <= count then
            local data = TEST_UNITS[i]
            local clr = RAID_CLASS_COLORS[data.class] or RAID_CLASS_COLORS['WARRIOR']
            local pClr = RGB_POWER_COLORS[data.powerType] or RGB_POWER_COLORS['mana']

            units[i].name:SetText(data.name)
            units[i].tar = data.name
            units[i].guid = "0xTEST" .. i
            units[i].hoverEnabled = true

            units[i].hpbar:SetStatusBarColor(clr.r, clr.g, clr.b)
            units[i].manabar:SetStatusBarColor(pClr[1], pClr[2], pClr[3])

            units[i].hpbar:SetMinMaxValues(0, data.maxHp)
            units[i].hpbar:SetValue(data.hp)

            units[i].manabar:SetMinMaxValues(0, data.maxMana)
            units[i].manabar:SetValue(data.mana)

            if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayHealthValues'] then
                units[i].hpText:SetText(data.hp .. " / " .. data.maxHp)
                units[i].hpText:Show()
                units[i].name:Hide()
            else
                units[i].hpText:Hide()
                if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayNames'] then
                    units[i].name:Show()
                else
                    units[i].name:Hide()
                end
            end

            if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayManaValues'] then
                if data.powerType == 'mana' then
                    units[i].manaText:SetText(data.mana .. " / " .. data.maxMana)
                    units[i].manaText:Show()
                else
                    units[i].manaText:SetText("")
                    units[i].manaText:Hide()
                end
            else
                units[i].manaText:Hide()
            end

            -- CC / Spec Icon
            units[i].cc.icon:SetTexture(GET_DEFAULT_ICON('class', data.class))
            units[i].cc.icon:SetVertexColor(1, 1, 1, 1)

            -- Target Count
            if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['targetCounter'] and data.tarCount > 0 then
                units[i].targetCount.text:SetText(data.tarCount)
                units[i].targetCount.text:Show()
            else
                units[i].targetCount.text:SetText("")
                units[i].targetCount.text:Hide()
            end

            -- Raid Icon
            if data.iconCoord then
                units[i].raidTarget.icon:SetTexCoord(data.iconCoord[1], data.iconCoord[2], data.iconCoord[3], data.iconCoord[4])
                units[i].raidTarget:Show()
            else
                units[i].raidTarget:Hide()
            end

            -- Cast Bar
            if data.spell and data.cast > 0 then
                units[i].ffCastbar:SetMinMaxValues(0, data.castMax)
                units[i].ffCastbar:SetValue(data.castMax - data.cast)
                units[i].ffCastbar.text:SetText(data.spell)
                units[i].ffCastbar.timer:SetText(data.cast .. "s")
                units[i].ffCastbar.icon:SetTexture(data.icon)
                units[i].ffCastbar.b:SetColor(0.1, 0.1, 0.1)
                units[i].ffCastbar:Show()
            else
                units[i].ffCastbar:Hide()
            end

            units[i]:Show()
        else
            units[i]:Hide()
        end
    end
end

local function optionals()
    if not FOSTERFRAMESPLAYERDATA then return end
    for i = 1, unitLimit do
        if not FOSTERFRAMESPLAYERDATA['displayNames'] then
            units[i].name:Hide()
        else
            units[i].name:Show()
        end

        if not FOSTERFRAMESPLAYERDATA['displayManabar'] then
            units[i].hpbar:SetHeight(unitHeight)
            units[i].manabar:Hide()
        else
            units[i].hpbar:SetHeight(unitHeight - manaBarHeight)
            units[i].manabar:Show()
        end

        if not FOSTERFRAMESPLAYERDATA['castTimers'] then
            units[i].ffCastbar.timer:Hide()
        else
            units[i].ffCastbar.timer:Show()
        end

        if not FOSTERFRAMESPLAYERDATA['targetCounter'] then
            units[i].targetCount.text:Hide()
        else
            units[i].targetCount.text:Show()
        end
    end
end

local function arrangeUnits()
    if not FOSTERFRAMESPLAYERDATA then return end
    local unitGroup = FOSTERFRAMESPLAYERDATA['groupsize'] or 5
    local layout = FOSTERFRAMESPLAYERDATA['layout'] or 'block'

    if playerFaction == 'Alliance' then
        fosterFrameDisplay.Title:SetText(layout == 'vertical' and 'H ' or 'Horde')
    else
        fosterFrameDisplay.Title:SetText(layout == 'vertical' and 'A ' or 'Alliance')
    end

    for i = 1, unitLimit do
        units[i]:ClearAllPoints()
        if i == 1 then
            units[i]:SetPoint('TOPLEFT', fosterFrameDisplay, 'BOTTOMLEFT', 0, -4)
        else
            if i > unitGroup then
                if layout == 'hblock' or layout == 'vblock' then
                    units[i]:SetPoint('TOPLEFT', units[i - unitGroup].ffCastbar.iconborder, 'BOTTOMLEFT', 1, -5)
                else
                    units[i]:SetPoint('TOPLEFT', units[i - unitGroup].cc, 'TOPRIGHT', leftSpacing, 0)
                end
            else
                if layout == 'hblock' or layout == 'vblock' then
                    units[i]:SetPoint('TOPLEFT', units[i - 1].cc, 'TOPRIGHT', leftSpacing, 0)
                else
                    units[i]:SetPoint('TOPLEFT', units[i - 1].ffCastbar.iconborder, 'BOTTOMLEFT', 1, -5)
                end
            end
        end
    end
end

local function showHideBars()
    if not FOSTERFRAMESPLAYERDATA then return end
    local isUnlocked = FOSTERFRAMESPLAYERDATA['frameMovable'] or (fosterFramesSettings and fosterFramesSettings:IsShown())
    if isUnlocked then
        fosterFrameDisplay.bg:Show()
    else
        fosterFrameDisplay.bg:Hide()
    end
    fosterFrameDisplay:EnableMouse(isUnlocked)
end

local function SetupFrames(maxU)
    maxUnits = maxU or 15
    if maxUnits < 1 then maxUnits = 1 end
    playerFaction = UnitFactionGroup('player')

    if playerFaction == 'Alliance' then
        enemyFactionColor = RGB_FACTION_COLORS['Horde']
        fosterFrameDisplay.Title:SetText('Horde')
    else
        enemyFactionColor = RGB_FACTION_COLORS['Alliance']
        fosterFrameDisplay.Title:SetText('Alliance')
    end

    fosterFrameDisplay.Title:SetTextColor(enemyFactionColor.r, enemyFactionColor.g, enemyFactionColor.b, 0.9)
    fosterFrameDisplay.totalPlayers:SetTextColor(enemyFactionColor.r, enemyFactionColor.g, enemyFactionColor.b, 0.9)

    local layout = FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['layout'] or 'block'
    local groupSize = FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['groupsize'] or 5
    if groupSize < 1 then groupSize = 5 end

    local col = (layout == 'hblock' and 5) or (layout == 'vblock' and 2) or (layout == 'vertical' and 1) or math.floor(maxUnits / groupSize)
    if col < 1 then col = 1 end

    fosterFrameDisplay:SetWidth((unitWidth + ccIconWidth + 5) * col + leftSpacing * (col - 1))

    showHideBars()

    if FOSTERFRAMES_DEBUG or FOSTERFRAMES_TESTMODE then
        renderTestVisuals()
    end
end

local function drawUnits(list)
    if FOSTERFRAMES_TESTMODE then return end
    fosterFrame.uiList = list or {}
    local i = 1

    for _, v in pairs(fosterFrame.uiList) do
        if i > unitLimit then break end

        local class = v.class or 'WARRIOR'
        local powerType = v.powerType or 'mana'
        local colour = RAID_CLASS_COLORS[class] or RAID_CLASS_COLORS['WARRIOR']
        local powerColor = RGB_POWER_COLORS[powerType] or RGB_POWER_COLORS['mana']

        if v.nearby then
            units[i].hpbar:SetStatusBarColor(colour.r, colour.g, colour.b)
            units[i].hoverEnabled = true
            if not units[i].mo then units[i].name:SetTextColor(colour.r, colour.g, colour.b) end
            units[i].manabar:SetStatusBarColor(powerColor[1], powerColor[2], powerColor[3])
            units[i].cc.icon:SetVertexColor(1, 1, 1, 1)
        else
            units[i].hoverEnabled = false
            units[i].hpbar:SetStatusBarColor(colour.r / 2, colour.g / 2, colour.b / 2, 0.7)
            units[i].manabar:SetStatusBarColor(powerColor[1] / 2, powerColor[2] / 2, powerColor[3] / 2)
            if not units[i].mo then units[i].name:SetTextColor(colour.r / 2, colour.g / 2, colour.b / 2, 0.7) end
            if v.fc then
                units[i].cc.icon:SetVertexColor(1, 1, 1, 1)
            else
                units[i].cc.icon:SetVertexColor(0.4, 0.4, 0.4, 0.7)
            end
            units[i].cc.cd:Hide()
        end

        units[i].name:SetText((v.name or 'Unknown'):sub(1, 7))
        units[i].tar = v.name
        units[i].guid = v.guid

        -- CC / Spec icon
        local icon = v.fc and SPELLINFO_WSG_FLAGS[playerFaction]['icon'] or GET_DEFAULT_ICON('class', v.class)
        if not v.fc and FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['specSpecificIcons'] and v.spec then
            icon = GET_DEFAULT_ICON('spec', v.spec)
        end
        units[i].cc.icon:SetTexture(icon)

        -- Target count
        units[i].targetCount.text:SetText(v.targetcount and (v.targetcount > 0 and v.targetcount or '') or '')

        -- HP & Mana display (UnitXP SP3)
        local maxHP = v.maxhealth or 100
        local currHP = v.health or (not v.nearby and maxHP) or 100
        units[i].hpbar:SetMinMaxValues(0, maxHP)
        units[i].hpbar:SetValue(currHP)

        if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayHealthValues'] then
            units[i].hpText:SetText(currHP .. " / " .. maxHP)
            units[i].hpText:Show()
            units[i].name:Hide()
        else
            units[i].hpText:Hide()
            if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayNames'] then units[i].name:Show() end
        end

        local maxMana = v.maxmana or 100
        local currMana = v.mana or (not v.nearby and maxMana) or 100
        units[i].manabar:SetMinMaxValues(0, maxMana)
        units[i].manabar:SetValue(currMana)

        if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayManaValues'] then
            if v.class ~= 'WARRIOR' and v.class ~= 'ROGUE' then
                units[i].manaText:SetText(currMana .. " / " .. maxMana)
                units[i].manaText:Show()
            else
                units[i].manaText:SetText("")
                units[i].manaText:Hide()
            end
        else
            units[i].manaText:Hide()
        end

        if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayOnlyNearby'] and not v.nearby then
            units[i]:Hide()
        else
            units[i]:Show()
        end

        i = i + 1
    end

    for j = i, unitLimit do
        if units[j]:IsShown() then
            units[j]:Hide()
        end
    end
end

local function updateUnits()
    if FOSTERFRAMES_TESTMODE then return end
    local now = GetTime()
    if rtMenuEndtime < now then fosterFrame.raidTargetMenu:Hide() end
    if not fosterFrame.uiList then return end

    local currentTarget = UnitExists('target') and UnitName('target') or nil
    local currentMouseover = UnitExists('mouseover') and UnitName('mouseover') or nil

    local i = 1
    for _, v in pairs(fosterFrame.uiList) do
        if i > unitLimit then return end

        local unitID = (currentTarget == v.name and 'target') or (currentMouseover == v.name and 'mouseover') or nil

        -- Border highlights
        if currentTarget == v.name then
            units[i].border:SetColor(enemyFactionColor.r, enemyFactionColor.g, enemyFactionColor.b)
            units[i].hpbar:SetBackdropColor(enemyFactionColor.r - 0.6, enemyFactionColor.g - 0.6, enemyFactionColor.b - 0.6, 0.6)
            units[i].manabar:SetBackdropColor(enemyFactionColor.r - 0.6, enemyFactionColor.g - 0.6, enemyFactionColor.b - 0.6, 0.6)
        else
            units[i].border:SetColor(0.1, 0.1, 0.1)
            units[i].hpbar:SetBackdropColor(0, 0, 0, 0.6)
            units[i].manabar:SetBackdropColor(0, 0, 0, 0.6)
        end

        -- Cast bar (UnitCastingInfo / UnitChannelInfo)
        local castInfo = SPELLCASTINGCOREgetCast(v.name, unitID)
        units[i].ffCastbar:Hide()
        if castInfo then
            local duration = castInfo.timeEnd - castInfo.timeStart
            units[i].ffCastbar:SetMinMaxValues(0, duration)
            if castInfo.inverse then
                units[i].ffCastbar:SetValue((castInfo.timeEnd - now) % duration)
            else
                units[i].ffCastbar:SetValue((now - castInfo.timeStart) % duration)
            end
            local charLim = (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['castTimers']) and 14 or 15
            units[i].ffCastbar.text:SetText((castInfo.spell or ''):sub(1, charLim))
            units[i].ffCastbar.timer:SetText(FosterFrames.Helpers.GetTimerLeft(castInfo.timeEnd, 3))
            units[i].ffCastbar.icon:SetTexture(castInfo.icon)
            if castInfo.borderClr then
                units[i].ffCastbar.b:SetColor(castInfo.borderClr[1], castInfo.borderClr[2], castInfo.borderClr[3])
            else
                units[i].ffCastbar.b:SetColor(0.1, 0.1, 0.1)
            end
            units[i].ffCastbar:Show()
        end

        -- Trinket CD
        local trinket = FOSTERFRAMECOREGetTrinketCooldown(v.guid)
        if trinket then
            units[i].trinket.icon:SetTexture(trinket.icon or [[Interface\Icons\inv_jewelry_trinketpvp_01]])
            units[i].trinket.cd:SetTimers(trinket.start, trinket['end'])
            units[i].trinket.cd:Show()
            units[i].trinket:Show()
        else
            units[i].trinket:Hide()
        end

        -- Raid Target
        if v.name and raidTargets[v.name] then
            local tCoords = RAID_TARGET_TCOORDS[raidTargets[v.name].icon]
            if tCoords then
                units[i].raidTarget.icon:SetTexCoord(tCoords[1], tCoords[2], tCoords[3], tCoords[4])
                units[i].raidTarget:Show()
            else
                units[i].raidTarget:Hide()
            end
        else
            units[i].raidTarget:Hide()
        end

        if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayOnlyNearby'] and not v.nearby then
            units[i]:Hide()
        else
            units[i]:Show()
        end

        i = i + 1
    end
end

local function fosterFramesOnUpdate()
    nextRefresh = nextRefresh - (arg1 or 0.016)
    if nextRefresh <= 0 then
        if not FOSTERFRAMES_TESTMODE then
            raidTargets = FOSTERFRAMECOREGetRaidTarget() or {}
            updateUnits()
        end
        nextRefresh = refreshInterval
    end
end

--- Global Entry Points ---

function FOSTERFRAMESUpdatePlayers(list)
    if not FOSTERFRAMES_TESTMODE then
        drawUnits(list)
    end
end

function FOSTERFRAMESInitialize(maxU, isBG)
    insideBG = isBG
    MOUSEOVERUNINAME = nil

    if maxU then
        SetupFrames(maxU)
        arrangeUnits()
        optionals()
        enabled = true

        if (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['enableFrames']) or insideBG or FOSTERFRAMES_TESTMODE then
            fosterFrame:Show()
        else
            fosterFrame:Hide()
        end
        fosterFrame:SetScript('OnUpdate', fosterFramesOnUpdate)
    else
        fosterFrame:SetScript('OnUpdate', nil)
    end
end

function FOSTERFRAMESsettings()
    optionals()
    if FOSTERFRAMES_TESTMODE or not enabled or (not insideBG and (fosterFramesSettings and fosterFramesSettings:IsShown())) then
        SetupFrames(10)
        renderTestVisuals()
    else
        SetupFrames(maxUnits)
    end
    arrangeUnits()
    if (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['enableFrames']) or insideBG or FOSTERFRAMES_TESTMODE then
        fosterFrame:Show()
    else
        fosterFrame:Hide()
    end

    if not enabled and not FOSTERFRAMES_TESTMODE and not (fosterFramesSettings and fosterFramesSettings:IsShown()) then
        for i = 1, unitLimit do units[i]:Hide() end
    end
end

function FOSTERFRAMES_SetTestMode(enable)
    FOSTERFRAMES_TESTMODE = enable and true or false
    if FOSTERFRAMES_TESTMODE then
        SetupFrames(10)
        arrangeUnits()
        optionals()
        renderTestVisuals()
        fosterFrame:Show()
    else
        if not insideBG and not (fosterFramesSettings and fosterFramesSettings:IsShown()) then
            for i = 1, unitLimit do units[i]:Hide() end
            fosterFrame:Hide()
        else
            FOSTERFRAMESsettings()
        end
    end
end

-- Debug Utilities
function FOSTERFRAMES_DebugDisplayPlayerData()
    local list = FOSTERFRAMECOREgetPlayerList and FOSTERFRAMECOREgetPlayerList() or {}
    DEFAULT_CHAT_FRAME:AddMessage("|cffae7cee[FosterFrames]|r Player Data Dump:")
    for k, v in pairs(list) do
        DEFAULT_CHAT_FRAME:AddMessage("  " .. tostring(k) .. ":")
        for i, j in pairs(v) do
            DEFAULT_CHAT_FRAME:AddMessage("    " .. tostring(i) .. " = " .. tostring(j))
        end
    end
end

function FOSTERFRAMES_DebugCooldownTest()
    FOSTERFRAMES_SetTestMode(true)
end

function FOSTERFRAMES_HideFrames()
    FOSTERFRAMES_SetTestMode(false)
    FOSTERFRAMES_DEBUG = false
    for i = 1, unitLimit do units[i]:Hide() end
    if fosterFrameDisplay then fosterFrameDisplay:Hide() end
end


