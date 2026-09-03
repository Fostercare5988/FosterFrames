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
    local currentZoneName = (cachedZone ~= "") and cachedZone or GetZoneText()
    local isAV = (currentZoneName == 'Alterac Valley') or (FOSTERFRAMES_TESTMODE and testUnitCount == 40)
    local isAVMode = isAV and (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['avMode'] ~= false)

    local width = newWidth or (isAVMode and FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['avUnitWidth']) or (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['unitWidth']) or (isAVMode and 112 or 126)
    local height = newHeight or (isAVMode and FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['avUnitHeight']) or (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['unitHeight']) or (isAVMode and 16 or 22)

    unitWidth = width
    unitHeight = height

    local iSize = height
    local hpW = math.max(30, width - iSize - 2)
    local showMana = (not isAVMode and FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayManabar']) or (isAVMode and FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['avShowMana'])

    for i = 1, unitLimit do
        local btn = units[i]
        if btn then
            btn:SetWidth(width)
            btn:SetHeight(height)

            btn.hpbar:SetWidth(hpW)
            btn.hpbar:SetHeight(height)

            if showMana then
                btn.manabar:SetHeight(3)
                btn.manabar:Show()
            else
                btn.manabar:Hide()
            end

            btn.cc:SetWidth(iSize)
            btn.cc:SetHeight(iSize)
            btn.cc:SetPoint('LEFT', btn.hpbar, 'RIGHT', 2, 0)

            btn.ffCastbar:SetAllPoints(btn.hpbar)
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
        button = button or arg1
        if button == "RightButton" then
            if UnitExists("target") and UnitName("target") == frame.tar then
                local currentIcon = GetRaidTargetIndex("target")
                SetRaidTargetIcon("target", (currentIcon == 8) and 0 or 8)
            else
                if frame.guid and TargetUnit and type(frame.guid) == "string" and frame.guid:sub(1, 2) == "0x" and not frame.guid:find("TEST") then
                    pcall(TargetUnit, frame.guid)
                elseif frame.tar then
                    TargetByName(frame.tar, true)
                end
            end
            return
        end

        if frame.guid and TargetUnit and type(frame.guid) == "string" and frame.guid:sub(1, 2) == "0x" and not frame.guid:find("TEST") then
            local ok = pcall(TargetUnit, frame.guid)
            if ok and UnitExists("target") and (not frame.tar or UnitName("target") == frame.tar) then
                return
            end
        end
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
        if SetMouseoverUnit and frame.guid then
            SetMouseoverUnit(frame.guid)
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
        if SetMouseoverUnit then
            SetMouseoverUnit(nil)
        end
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
local cachedZone = ""

local function UpdateCardVisuals(btn, data, isAV, isAVMode)
    if not btn or not data then return end

    local class = data.class or 'WARRIOR'
    local powerType = data.powerType or ((class == 'WARRIOR' and 'rage') or (class == 'ROGUE' and 'energy') or 'mana')
    local colour = RAID_CLASS_COLORS[class] or RAID_CLASS_COLORS['WARRIOR']
    local powerColor = RGB_POWER_COLORS[powerType] or RGB_POWER_COLORS['mana']
    local isNearby = (data.nearby ~= false)

    if isNearby then
        btn.hpbar:SetStatusBarColor(colour.r, colour.g, colour.b)
        btn.hoverEnabled = true
        if not btn.mo then btn.name:SetTextColor(colour.r, colour.g, colour.b) end
        btn.manabar:SetStatusBarColor(powerColor[1], powerColor[2], powerColor[3])
        btn.cc.icon:SetVertexColor(1, 1, 1, 1)
    else
        btn.hpbar:SetStatusBarColor(colour.r * 0.35, colour.g * 0.35, colour.b * 0.35)
        btn.hoverEnabled = false
        btn.name:SetTextColor(colour.r * 0.45, colour.g * 0.45, colour.b * 0.45)
        btn.manabar:SetStatusBarColor(powerColor[1] * 0.35, powerColor[2] * 0.35, powerColor[3] * 0.35)
        btn.cc.icon:SetVertexColor(0.4, 0.4, 0.4, 1)
    end

    btn.tar = data.name
    btn.guid = data.guid
    btn.name:SetText(data.name:sub(1, isAVMode and 6 or 7))

    if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayNames'] == false then
        btn.name:Hide()
    else
        btn.name:Show()
    end

    -- Target count badge
    local tarCount = data.targetcount or data.tarCount or 0
    if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['targetCounter'] and tarCount > 0 then
        btn.targetCount.text:SetText(tarCount)
        btn.targetCount.text:Show()
    else
        btn.targetCount.text:SetText("")
        btn.targetCount.text:Hide()
    end

    -- Health (UnitXP SP3)
    local maxHP = data.maxhealth or data.maxHp or 100
    local currHP = data.health or data.hp or (not isNearby and maxHP) or 100
    btn.hpbar:SetMinMaxValues(0, maxHP)
    btn.hpbar:SetValue(currHP)

    if maxHP > 100 and FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayHealthValues'] then
        btn.hpText:SetText((currHP >= 1000) and string.format("%.1fk", currHP / 1000) or tostring(currHP))
    else
        local pct = (maxHP > 0) and math.floor((currHP / maxHP) * 100) or 100
        btn.hpText:SetText(pct .. "%")
    end
    btn.hpText:Show()

    -- Mana / Power
    local maxMana = data.maxmana or data.maxMana or 100
    local currMana = data.mana or (not isNearby and maxMana) or 100
    btn.manabar:SetMinMaxValues(0, maxMana)
    btn.manabar:SetValue(currMana)

    local showMana = (not isAVMode and FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayManabar']) or (isAVMode and FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['avShowMana'])
    if showMana and FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayManaValues'] and powerType == 'mana' then
        if maxMana > 100 then
            btn.manaText:SetText((currMana >= 1000) and string.format("%.1fk", currMana / 1000) or tostring(currMana))
        else
            btn.manaText:SetText(math.floor(currMana) .. "%")
        end
        btn.manaText:Show()
    else
        btn.manaText:Hide()
    end

    -- 4-Stage Canonical Distance Color Grading (Rule B8)
    local dist = data.distance or (FOSTERFRAMES_TESTMODE and (8 + (btn.index * 3)))
    if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['showDistance'] ~= false and dist and dist > 0 and dist < 120 and isNearby then
        local d = math.floor(dist)
        local _, _, _, dColorHex = FosterFrames.Helpers.GetDistanceColor(d)
        btn.distText:SetText(dColorHex .. d .. "y|r")
        btn.distText:Show()
    else
        btn.distText:SetText("")
        btn.distText:Hide()
    end

    -- Target Border Highlight
    local currentTarget = UnitExists('target') and UnitName('target') or nil
    if currentTarget == data.name then
        btn.border:SetColor(enemyFactionColor.r, enemyFactionColor.g, enemyFactionColor.b)
        btn.hpbar:SetBackdropColor(enemyFactionColor.r - 0.6, enemyFactionColor.g - 0.6, enemyFactionColor.b - 0.6, 0.6)
        btn.manabar:SetBackdropColor(enemyFactionColor.r - 0.6, enemyFactionColor.g - 0.6, enemyFactionColor.b - 0.6, 0.6)
    else
        btn.border:SetColor(0.1, 0.1, 0.1)
        btn.hpbar:SetBackdropColor(0, 0, 0, 0.6)
        btn.manabar:SetBackdropColor(0, 0, 0, 0.6)
    end

    -- Casting State vs Resting State (Rule C9: Single-State UI Rendering)
    local unitID = (currentTarget == data.name and 'target') or (UnitExists('mouseover') and UnitName('mouseover') == data.name and 'mouseover') or nil
    local castInfo = (not FOSTERFRAMES_TESTMODE and SPELLCASTINGCOREgetCast(data.name, unitID)) or data.castinfo or (FOSTERFRAMES_TESTMODE and data.spell and data.cast > 0 and {
        spell     = data.spell,
        icon      = data.icon,
        timeStart = GetTime() - (data.castMax - data.cast),
        timeEnd   = GetTime() + data.cast,
        inverse   = false,
    })

    if castInfo and FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['castTimers'] ~= false and GetTime() < castInfo.timeEnd then
        local duration = castInfo.timeEnd - castInfo.timeStart
        if duration <= 0 then duration = 1 end
        btn.ffCastbar:SetMinMaxValues(0, duration)
        local now = GetTime()
        if castInfo.inverse then
            btn.ffCastbar:SetValue((castInfo.timeEnd - now) % duration)
        else
            btn.ffCastbar:SetValue((now - castInfo.timeStart) % duration)
        end
        btn.ffCastbar.text:SetText((castInfo.spell or ''):sub(1, 12))
        btn.ffCastbar.timer:SetText(FosterFrames.Helpers.GetTimerLeft(castInfo.timeEnd, 3) .. 's')
        btn.ffCastbar:Show()

        btn.name:Hide()
        btn.hpText:Hide()
        btn.distText:Hide()
        btn.manaText:Hide()

        if castInfo.icon then
            btn.cc.icon:SetTexture(castInfo.icon)
        else
            btn.cc.icon:SetTexture(GET_DEFAULT_ICON('class', class))
        end
        if btn.cc.cd then btn.cc.cd:Hide() end
    else
        btn.ffCastbar:Hide()
        if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayNames'] ~= false then
            btn.name:Show()
        end
        btn.hpText:Show()

        local trinket = data.guid and FOSTERFRAMECOREGetTrinketCooldown and FOSTERFRAMECOREGetTrinketCooldown(data.guid)
        if trinket then
            btn.cc.icon:SetTexture(trinket.icon or [[Interface\Icons\inv_jewelry_trinketpvp_01]])
            if btn.cc.cd then
                btn.cc.cd:SetTimers(trinket.start, trinket['end'])
                btn.cc.cd:Show()
            end
        else
            btn.cc.icon:SetTexture(GET_DEFAULT_ICON('class', class))
            if btn.cc.cd then btn.cc.cd:Hide() end
        end
    end

    local hideFarInAV = isAV and FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['avShowOnlyNearby']
    if ((FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['displayOnlyNearby']) or hideFarInAV) and not isNearby then
        btn:Hide()
    else
        btn:Show()
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

    local currentZoneName = (cachedZone ~= "") and cachedZone or GetZoneText()
    local isAV = (currentZoneName == 'Alterac Valley') or (FOSTERFRAMES_TESTMODE and testUnitCount == 40)
    local isAVMode = isAV and (FOSTERFRAMESPLAYERDATA['avMode'] ~= false)
    local isWSG = (currentZoneName == 'Warsong Gulch') or (FOSTERFRAMES_TESTMODE and testUnitCount == 10)
    local isAB = (currentZoneName == 'Arathi Basin') or (FOSTERFRAMES_TESTMODE and testUnitCount == 15)

    local width = unitWidth or 150
    local height = unitHeight or 24
    local currentXGap = isAVMode and 4 or xGap
    local currentYGap = isAVMode and 2 or yGap

    -- Groups of 5 standard PvP columns (or 10 in AV compact mode)
    local unitsPerCol = isAVMode and 10 or 5

    local activeUnits = 5
    if FOSTERFRAMES_TESTMODE then
        activeUnits = testUnitCount or 10
    elseif isAV then
        activeUnits = 40
    elseif isAB then
        activeUnits = 15
    elseif isWSG then
        activeUnits = 10
    else
        -- Open World: size columns dynamically to detected units (1 column if 0-5, 2 if 6-10, etc.)
        local spottedCount = (fosterFrame.uiList and #fosterFrame.uiList) or 0
        activeUnits = math.max(5, math.min(15, spottedCount))
    end

    local numCols = math.ceil(activeUnits / unitsPerCol)
    if numCols < 1 then numCols = 1 end

    fosterFrameDisplay:SetWidth(numCols * width + (numCols - 1) * currentXGap)

    if playerFaction == 'Alliance' then
        fosterFrameDisplay.Title:SetText('Horde')
    else
        fosterFrameDisplay.Title:SetText('Alliance')
    end

    for i = 1, unitLimit do
        units[i]:ClearAllPoints()
        local col = math.floor((i - 1) / unitsPerCol)
        local row = (i - 1) % unitsPerCol

        local xOfs = col * (width + currentXGap)
        local yOfs = -4 - row * (height + currentYGap)
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
        drawUnits(TEST_UNITS)
    end
end

local function drawUnits(list)
    local sourceList = FOSTERFRAMES_TESTMODE and TEST_UNITS or (list or {})
    fosterFrame.uiList = sourceList
    local count = FOSTERFRAMES_TESTMODE and testUnitCount or table.getn(sourceList)
    local isAV = (cachedZone == 'Alterac Valley')
    local isAVMode = isAV and (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['avMode'] ~= false)

    local i = 1
    for idx = 1, count do
        if i > unitLimit then break end
        local v = sourceList[idx]
        if v then
            UpdateCardVisuals(units[i], v, isAV, isAVMode)
            i = i + 1
        end
    end

    for j = i, unitLimit do
        if units[j]:IsShown() then
            units[j]:Hide()
        end
    end
end

local function updateUnits()
    if not fosterFrame.uiList then return end
    local isAV = (cachedZone == 'Alterac Valley')
    local isAVMode = isAV and (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['avMode'] ~= false)
    local count = FOSTERFRAMES_TESTMODE and testUnitCount or table.getn(fosterFrame.uiList)

    local i = 1
    for idx = 1, count do
        if i > unitLimit then break end
        local v = fosterFrame.uiList[idx]
        if v then
            UpdateCardVisuals(units[i], v, isAV, isAVMode)
            i = i + 1
        end
    end
end

local function fosterFramesOnUpdate()
    nextRefresh = nextRefresh - (arg1 or 0.016)
    if nextRefresh <= 0 then
        updateUnits()
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
    cachedZone = GetZoneText() or ""

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
        drawUnits(TEST_UNITS)
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
        drawUnits(TEST_UNITS)
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



