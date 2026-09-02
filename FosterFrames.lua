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
local refreshInterval = 1 / 60
local nextRefresh = 0

-- Unit Limits & Collections
local unitLimit = 40
local maxUnits = 40
local units = {}

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

-- Header Lock/Unlock Toggle Button
fosterFrame.lockBtn = CreateFrame('Button', 'fosterFrameHeaderLockButton', fosterFrame)
fosterFrame.lockBtn:SetWidth(20)
fosterFrame.lockBtn:SetHeight(20)
fosterFrame.lockBtn:SetFrameLevel(10)
fosterFrame.lockBtn:SetPoint('LEFT', fosterFrame, 'LEFT', 6, 1)
fosterFrame.lockBtn:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
fosterFrame.lockBtn:EnableMouse(true)

fosterFrame.lockBtn.text = fosterFrame.lockBtn:CreateFontString(nil, 'OVERLAY')
fosterFrame.lockBtn.text:SetFont(STANDARD_TEXT_FONT, 14, 'OUTLINE')
fosterFrame.lockBtn.text:SetPoint('CENTER', fosterFrame.lockBtn, 'CENTER', 0, 0)
fosterFrame.lockBtn.text:SetTextColor(0.85, 0.85, 0.85, 0.9)
fosterFrame.lockBtn.text:SetText(FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['frameMovable'] and '-' or '+')

fosterFrame.lockBtn:SetScript('OnClick', function()
    if not FOSTERFRAMESPLAYERDATA then return end
    FOSTERFRAMESPLAYERDATA['frameMovable'] = not FOSTERFRAMESPLAYERDATA['frameMovable']
    local isMovable = FOSTERFRAMESPLAYERDATA['frameMovable']
    this.text:SetText(isMovable and '-' or '+')
    if fosterFrameDisplay.bg then
        if isMovable then fosterFrameDisplay.bg:Show() else fosterFrameDisplay.bg:Hide() end
    end
    if fosterFramesSettings and fosterFramesSettings.unlock then
        fosterFramesSettings.unlock:SetText(isMovable and 'Lock' or 'Unlock')
    end
    PlaySound("igMainMenuOptionCheckBoxOn")
end)

fosterFrame.lockBtn:SetScript('OnEnter', function()
    this.text:SetTextColor(1, 0.9, 0.2, 1)
    GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT", 0, 4)
    GameTooltip:AddLine("Lock / Unlock Frames", 1, 0.82, 0)
    GameTooltip:AddLine(FOSTERFRAMESPLAYERDATA['frameMovable'] and "Click to lock frame position." or "Click to unlock frame for dragging.", 0.9, 0.9, 0.9)
    GameTooltip:Show()
end)

fosterFrame.lockBtn:SetScript('OnLeave', function()
    this.text:SetTextColor(0.85, 0.85, 0.85, 0.9)
    GameTooltip:Hide()
end)

fosterFrame.totalPlayers = fosterFrame:CreateFontString(nil, 'OVERLAY')
fosterFrame.totalPlayers:SetFont(STANDARD_TEXT_FONT, 12, 'OUTLINE')
fosterFrame.totalPlayers:SetPoint('RIGHT', fosterFrame, 'RIGHT', -4, 1)
fosterFrame.totalPlayers:Hide()

local unitWidth, unitHeight, hpWidth, hpHeight, manaBarHeight, iconSize, castBarHeight = UIElementsGetDimensions()
local xGap = 6
local yGap = 4

function FOSTERFRAMES_UpdateDimensions(newWidth, newHeight)
    local width = newWidth or (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['unitWidth']) or unitWidth or 126
    local height = newHeight or (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['unitHeight']) or unitHeight or 24

    unitWidth = width
    unitHeight = height

    local iSize = math.max(16, height - 1)
    local hpW = math.max(30, width - iSize - 3)
    local manaH = math.max(3, math.floor(height * 0.22))
    local hpH = math.max(8, height - manaH - 1)

    for i = 1, unitLimit do
        local btn = units[i]
        if btn then
            btn:SetWidth(width)
            btn:SetHeight(height)

            local showMana = (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayManabar'])
            btn.hpbar:SetWidth(hpW)
            btn.hpbar:SetHeight(showMana and hpH or (height - 1))

            btn.manabar:SetWidth(hpW)
            btn.manabar:SetHeight(manaH)

            btn.cc:SetWidth(iSize)
            btn.cc:SetHeight(iSize)
            btn.cc:SetPoint('TOPLEFT', btn, 'TOPLEFT', hpW + 3, 0)

            btn.ffCastbar:SetWidth(width - 4)
        end
    end

    if arrangeUnits then arrangeUnits() end
end

-- Create Unit Frames
for i = 1, unitLimit do
    units[i] = CreateEnemyUnitFrame('fosterFrameUnit' .. i, fosterFrame)
    units[i].index = i
    units[i].hoverEnabled = false

    units[i]:SetScript('OnClick', function(self, button)
        local frame = self or this
        if frame.tar then
            TargetByName(frame.tar, true)
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


-- Mock Test Data Definition (40 Units for WSG, AB, and AV testing)
local TEST_UNITS = {
    { name = "Gladiator", class = "WARRIOR", powerType = "rage",   hp = 4850, maxHp = 5200, mana = 65,   maxMana = 100, spell = "Mortal Strike", icon = [[Interface\Icons\Ability_Warrior_SavageBlow]],   cast = 0,   castMax = 0,   tarCount = 3 },
    { name = "HolyHeals", class = "PRIEST",  powerType = "mana",   hp = 3120, maxHp = 4100, mana = 2800, maxMana = 4900, spell = "Greater Heal",  icon = [[Interface\Icons\Spell_Holy_GreaterHeal]],       cast = 1.4, castMax = 2.5, tarCount = 2 },
    { name = "FrostBite", class = "MAGE",    powerType = "mana",   hp = 2950, maxHp = 3800, mana = 3400, maxMana = 5400, spell = "Polymorph",     icon = [[Interface\Icons\Spell_Nature_Polymorph]],       cast = 0.8, castMax = 1.5, tarCount = 1 },
    { name = "ShadowCut", class = "ROGUE",   powerType = "energy", hp = 3400, maxHp = 4400, mana = 100,  maxMana = 100,  spell = nil,             icon = nil,                                              cast = 0,   castMax = 0,   tarCount = 0 },
    { name = "MoonFire",  class = "DRUID",   powerType = "mana",   hp = 3800, maxHp = 4600, mana = 2100, maxMana = 4200, spell = "Entangling Roots", icon = [[Interface\Icons\Spell_Nature_Stranglevines]], cast = 0.6, castMax = 1.5, tarCount = 1 },
    { name = "DarkChaos", class = "WARLOCK", powerType = "mana",   hp = 4100, maxHp = 5000, mana = 3600, maxMana = 5100, spell = "Fear",             icon = [[Interface\Icons\Spell_Shadow_Possession]],       cast = 1.1, castMax = 1.5, tarCount = 0 },
    { name = "EagleEye",  class = "HUNTER",  powerType = "mana",   hp = 3600, maxHp = 4500, mana = 1900, maxMana = 3800, spell = "Aimed Shot",      icon = [[Interface\Icons\Inv_spear_07]],                  cast = 1.8, castMax = 3.0, tarCount = 0 },
    { name = "Thunder",   class = "SHAMAN",  powerType = "mana",   hp = 3900, maxHp = 4700, mana = 2200, maxMana = 4400, spell = "Chain Lightning", icon = [[Interface\Icons\Spell_Nature_ChainLightning]],  cast = 1.2, castMax = 2.0, tarCount = 1 },
    { name = "Avenger",   class = "PALADIN", powerType = "mana",   hp = 4200, maxHp = 5100, mana = 2500, maxMana = 4600, spell = "Holy Light",      icon = [[Interface\Icons\Spell_Holy_HolyBolt]],          cast = 1.6, castMax = 2.5, tarCount = 0 },
    { name = "Bladestorm",class = "WARRIOR", powerType = "rage",   hp = 2200, maxHp = 5400, mana = 25,   maxMana = 100,  spell = nil,             icon = nil,                                              cast = 0,   castMax = 0,   tarCount = 4 },
    { name = "ShadowPri", class = "PRIEST",  powerType = "mana",   hp = 3300, maxHp = 4200, mana = 3100, maxMana = 4800, spell = "Mind Blast",    icon = [[Interface\Icons\Spell_Shadow_UnholyFrenzy]],    cast = 0.9, castMax = 1.5, tarCount = 1 },
    { name = "FireMage",  class = "MAGE",    powerType = "mana",   hp = 2700, maxHp = 3600, mana = 2900, maxMana = 5200, spell = "Pyroblast",     icon = [[Interface\Icons\Spell_Fire_Fireball02]],        cast = 2.4, castMax = 3.5, tarCount = 0 },
    { name = "SubRogue",  class = "ROGUE",   powerType = "energy", hp = 3600, maxHp = 4500, mana = 100,  maxMana = 100,  spell = nil,             icon = nil,                                              cast = 0,   castMax = 0,   tarCount = 0 },
    { name = "BeastHunt", class = "HUNTER",  powerType = "mana",   hp = 3800, maxHp = 4600, mana = 1600, maxMana = 3600, spell = "Multi-Shot",     icon = [[Interface\Icons\Ability_UpgradeMoonGlaive]],    cast = 0,   castMax = 0,   tarCount = 0 },
    { name = "AffLock",   class = "WARLOCK", powerType = "mana",   hp = 3950, maxHp = 4900, mana = 3200, maxMana = 5000, spell = "Shadow Bolt",    icon = [[Interface\Icons\Spell_Shadow_ShadowBolt]],      cast = 1.7, castMax = 2.5, tarCount = 2 },
}

-- Auto-fill up to 40 mock test units
local extraClasses = {"WARRIOR", "PRIEST", "MAGE", "ROGUE", "DRUID", "WARLOCK", "HUNTER", "SHAMAN", "PALADIN"}
for idx = #TEST_UNITS + 1, 40 do
    local cls = extraClasses[(idx % #extraClasses) + 1]
    local pType = (cls == 'WARRIOR' and 'rage') or (cls == 'ROGUE' and 'energy') or 'mana'
    TEST_UNITS[idx] = {
        name = "Enemy" .. idx,
        class = cls,
        powerType = pType,
        hp = 3000 + (idx * 40) % 2200,
        maxHp = 4000 + (idx * 50) % 1500,
        mana = 2000 + (idx * 30) % 2500,
        maxMana = 4500,
        spell = nil,
        icon = nil,
        cast = 0,
        castMax = 0,
        tarCount = 0,
    }
end


local testUnitCount = 10

local function renderTestVisuals()
    for i = 1, unitLimit do
        if i <= testUnitCount and i <= #TEST_UNITS then
            local data = TEST_UNITS[i]
            local clr = RAID_CLASS_COLORS[data.class] or RAID_CLASS_COLORS['WARRIOR']
            local pClr = RGB_POWER_COLORS[data.powerType] or RGB_POWER_COLORS['mana']

            units[i].name:SetText(data.name:sub(1, 6))
            units[i].name:Show()
            units[i].tar = data.name
            units[i].guid = "0xTEST" .. i
            units[i].hoverEnabled = true

            units[i].hpbar:SetStatusBarColor(clr.r, clr.g, clr.b)
            units[i].manabar:SetStatusBarColor(pClr[1], pClr[2], pClr[3])

            units[i].hpbar:SetMinMaxValues(0, data.maxHp)
            units[i].hpbar:SetValue(data.hp)

            units[i].manabar:SetMinMaxValues(0, data.maxMana)
            units[i].manabar:SetValue(data.mana)

            local hpFormatted
            if data.maxHp > 100 and FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayHealthValues'] then
                hpFormatted = (data.hp >= 1000) and string.format("%.1fk", data.hp / 1000) or tostring(data.hp)
            else
                local pct = math.floor((data.hp / data.maxHp) * 100)
                hpFormatted = pct .. "%"
            end
            units[i].hpText:SetText(hpFormatted)
            units[i].hpText:Show()

            if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayManaValues'] and data.powerType == 'mana' then
                local manaFormatted = (data.mana >= 1000) and string.format("%.1fk", data.mana / 1000) or tostring(data.mana)
                units[i].manaText:SetText(manaFormatted)
                units[i].manaText:Show()
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
            units[i].hpbar:SetHeight(hpHeight + manaBarHeight)
            units[i].manabar:Hide()
        else
            units[i].hpbar:SetHeight(hpHeight)
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
    local layout = FOSTERFRAMESPLAYERDATA['layout'] or 'block'
    local activeUnits = FOSTERFRAMES_TESTMODE and testUnitCount or maxUnits
    if activeUnits < 1 then activeUnits = 1 end

    local numCols = 1
    if layout == 'horizontal' then
        numCols = activeUnits
    elseif layout == 'hblock' then
        numCols = math.min(5, activeUnits)
    elseif layout == 'vblock' then
        numCols = 2
    elseif layout == 'vertical' then
        numCols = 1
    else -- 'block' default: 5 units per column
        numCols = math.ceil(activeUnits / 5)
    end
    if numCols < 1 then numCols = 1 end

    fosterFrameDisplay:SetWidth(numCols * unitWidth + (numCols - 1) * xGap)

    if playerFaction == 'Alliance' then
        fosterFrameDisplay.Title:SetText(layout == 'vertical' and 'H ' or 'Horde')
    else
        fosterFrameDisplay.Title:SetText(layout == 'vertical' and 'A ' or 'Alliance')
    end

    for i = 1, unitLimit do
        units[i]:ClearAllPoints()
        local col, row = 0, 0

        if layout == 'horizontal' then
            col = i - 1
            row = 0
        elseif layout == 'hblock' then
            col = (i - 1) % 5
            row = math.floor((i - 1) / 5)
        elseif layout == 'vblock' then
            col = (i - 1) % 2
            row = math.floor((i - 1) / 2)
        elseif layout == 'vertical' then
            col = 0
            row = i - 1
        else -- 'block'
            col = math.floor((i - 1) / 5)
            row = (i - 1) % 5
        end

        local xOfs = col * (unitWidth + xGap)
        local yOfs = -4 - row * (unitHeight + yGap)
        units[i]:SetPoint('TOPLEFT', fosterFrameDisplay, 'BOTTOMLEFT', xOfs, yOfs)
    end
end

local function showHideBars()
    if not FOSTERFRAMESPLAYERDATA then return end
    local isUnlocked = FOSTERFRAMESPLAYERDATA['frameMovable'] or (fosterFramesSettings and fosterFramesSettings:IsShown())
    if isUnlocked then
        fosterFrameDisplay.bg:Show()
        if fosterFrameDisplay.lockBtn and fosterFrameDisplay.lockBtn.text then
            fosterFrameDisplay.lockBtn.text:SetText("-")
        end
    else
        fosterFrameDisplay.bg:Hide()
        if fosterFrameDisplay.lockBtn and fosterFrameDisplay.lockBtn.text then
            fosterFrameDisplay.lockBtn.text:SetText("+")
        end
    end
    fosterFrameDisplay:EnableMouse(true)
end

local function SetupFrames(maxU)
    maxUnits = maxU or 40
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

    FOSTERFRAMES_UpdateDimensions()
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

        local displayName = (v.name or 'Unknown'):sub(1, 6)
        units[i].name:SetText(displayName)
        if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayNames'] == false then
            units[i].name:Hide()
        else
            units[i].name:Show()
        end

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

        local hpFormatted
        if maxHP > 100 and FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayHealthValues'] then
            hpFormatted = (currHP >= 1000) and string.format("%.1fk", currHP / 1000) or tostring(currHP)
        else
            local pct = (maxHP > 0) and math.floor((currHP / maxHP) * 100) or 100
            hpFormatted = pct .. "%"
        end
        units[i].hpText:SetText(hpFormatted)
        units[i].hpText:Show()

        local maxMana = v.maxmana or 100
        local currMana = v.mana or (not v.nearby and maxMana) or 100
        units[i].manabar:SetMinMaxValues(0, maxMana)
        units[i].manabar:SetValue(currMana)

        if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayManaValues'] and v.class ~= 'WARRIOR' and v.class ~= 'ROGUE' then
            local manaFormatted
            if maxMana > 100 then
                manaFormatted = (currMana >= 1000) and string.format("%.1fk", currMana / 1000) or tostring(currMana)
            else
                manaFormatted = tostring(math.floor(currMana)) .. "%"
            end
            units[i].manaText:SetText(manaFormatted)
            units[i].manaText:Show()
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

        -- Trinket CD (overlays or overrides CC icon if on cooldown)
        local trinket = FOSTERFRAMECOREGetTrinketCooldown(v.guid)
        if trinket then
            units[i].cc.icon:SetTexture(trinket.icon or [[Interface\Icons\inv_jewelry_trinketpvp_01]])
            units[i].cc.cd:SetTimers(trinket.start, trinket['end'])
            units[i].cc.cd:Show()
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
        SetupFrames(testUnitCount)
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

function FOSTERFRAMES_SetTestMode(enable, count)
    if type(enable) == "number" then
        count = enable
        enable = true
    end
    testUnitCount = count or testUnitCount or 10
    FOSTERFRAMES_TESTMODE = enable and true or false
    if FOSTERFRAMES_TESTMODE then
        SetupFrames(testUnitCount)
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

function FOSTERFRAMES_GetTestCount()
    return testUnitCount
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
    FOSTERFRAMES_SetTestMode(true, 15)
end

function FOSTERFRAMES_HideFrames()
    FOSTERFRAMES_SetTestMode(false)
    FOSTERFRAMES_DEBUG = false
    for i = 1, unitLimit do units[i]:Hide() end
    if fosterFrameDisplay then fosterFrameDisplay:Hide() end
end



