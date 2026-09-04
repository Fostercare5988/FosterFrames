-- FosterFrames - Settings & Configuration Suite
-- Enhanced 1.12.1 Engine Stack (ClassicAPI, SuperWoW, NamPower, UnitXP SP3)

-- Mandatory Engine Dependency Guard
if not (CLASSIC_API_VERSION and SUPERWOW_VERSION) then
    return
end

FOSTERFRAMESVERSION = "1.0.0"

-- Initialize SavedVariables with defaults
if FOSTERFRAMESPLAYERDATA == nil then
    FOSTERFRAMESPLAYERDATA = {
        -- Display & Layout
        ['scale']                        = 1,
        ['unitWidth']                    = 150,
        ['unitHeight']                   = 24,
        ['frameMovable']                 = true,
        ['enableFrames']                 = true,
        ['displayNames']                 = true,
        ['displayHealthValues']          = false,
        ['displayManabar']               = false,
        ['displayManaValues']            = false,
        ['displayOnlyNearby']            = false,

        
        -- Battlegrounds Suite
        ['avMode']                       = true,
        ['avShowOnlyNearby']             = false,
        ['avUnitWidth']                  = 112,
        ['avUnitHeight']                 = 16,
        ['avShowMana']                   = false,
        ['smartDistanceSorting']         = false,

        -- Spy & Open World Radar
        ['openWorldScanning']            = true,
        ['showDistance']                 = true,
        ['spySoundAlert']                = true,
        ['spyFlashTaskbar']              = false,
        ['spyStealthAlert']              = true,
        ['spyAnnounceNearby']            = false,

        -- Target Frame & Combat HUD
        ['integratedTargetFrameCastbar'] = true,
        ['targetFrameCastbar']           = true,
        ['targetDebuffTimers']           = false,
        ['playerTargetCounter']          = false,
        ['targetCounter']                = false,
        ['castTimers']                   = false,
        ['ccAnnounce']                   = false,
        ['mouseOver']                    = false,

        -- Positioning
        ['offX']                         = 0,
        ['offY']                         = 100,
    }
end

-- Configuration Tabs & Technical Tooltip Metadata
local TABS_CONFIG = {
    {
        name = 'Display',
        title = 'Display & Frame Layout',
        checkboxes = {
            {
                id = 'enableFrames',
                label = 'Enable FosterFrames Unit Grid',
                tooltipTitle = 'Enable FosterFrames',
                tooltipText = 'Master toggle to display enemy unit frame cards and tactical combat HUD elements.'
            },
            {
                id = 'displayNames',
                label = 'Show Character Names on Cards',
                tooltipTitle = 'Display Player Names',
                tooltipText = 'Displays character names on enemy unit cards.'
            },
            {
                id = 'displayHealthValues',
                label = 'Show Health Numbers & % (UnitXP SP3)',
                tooltipTitle = 'Exact Health Numbers',
                tooltipText = 'Displays real-time uncapped current and maximum numerical health (e.g. 4.8k / 100%) on unit health bars via UnitXP SP3.'
            },
            {
                id = 'displayManabar',
                label = 'Show Power Bar (Mana / Rage / Energy)',
                tooltipTitle = 'Power Resource Bar',
                tooltipText = 'Displays secondary resource power bars below unit health bars.'
            },
            {
                id = 'displayManaValues',
                label = 'Show Mana Numbers (UnitXP SP3)',
                tooltipTitle = 'Exact Mana Numbers',
                tooltipText = 'Displays current and maximum numerical mana values on mana-using classes.'
            },
            {
                id = 'displayOnlyNearby',
                label = 'Hide Out-of-Range Units (>80yd)',
                tooltipTitle = 'Hide Out-of-Range Units',
                tooltipText = 'Dynamically hides enemy unit frame cards when players are out of range or not detected nearby.'
            },
        },
        hasDimensions = true,
        hasScale = true,
    },
    {
        name = 'Battlegrounds',
        title = 'Battlegrounds Engine (AV / WSG / AB)',
        checkboxes = {
            {
                id = 'avMode',
                label = 'Enable AV Compact Mode (BattlegroundTargets Style)',
                tooltipTitle = 'AV BattlegroundTargets Mode',
                tooltipText = 'In Alterac Valley (40 enemies), automatically switches to an ultra-compact 4x10 grid with 16px slim bars (BattlegroundTargets style) to keep your screen completely clear and unobstructed.'
            },
            {
                id = 'avShowOnlyNearby',
                label = 'AV: Show Only Nearby / Active Combatants',
                tooltipTitle = 'AV Active Enemy Filter',
                tooltipText = 'In Alterac Valley, automatically hides far-away hostiles, showing only enemies that are nearby or engaged in active combat around you.'
            },
            {
                id = 'smartDistanceSorting',
                label = 'Sort Frames by Distance (Closest First)',
                tooltipTitle = 'Smart Distance Sorting',
                tooltipText = 'Continuously sorts unit frame cards by real-time 3D Euclidean distance (via UnitXP SP3), placing the closest hostiles at the top.'
            },
        },
    },
    {
        name = 'Spy & Radar',
        title = 'Open World PvP Radar & Stealth Watcher',
        checkboxes = {
            {
                id = 'openWorldScanning',
                label = 'Scan Hostiles in Open World (Non-BG Radar)',
                tooltipTitle = 'Open World PvP Radar',
                tooltipText = 'Enables nameplate and combat log scanning outside battlegrounds to detect, track, and display hostile players in world PvP.'
            },
            {
                id = 'showDistance',
                label = 'Show Live 3D Yard Distance on Enemy Cards',
                tooltipTitle = 'Live 3D Distance Tracker',
                tooltipText = 'Calculates real-time 3D Euclidean distance (in yards) to detected hostiles via SuperWoW UnitPosition, displaying color-coded yard tags directly on each enemy frame (Red <10yd, Yellow 10-30yd, Green >30yd).'
            },
            {
                id = 'spyStealthAlert',
                label = 'Stealth & Prowl Detection Warnings (Rogue / Druid)',
                tooltipTitle = 'Stealth Action Watcher',
                tooltipText = 'Watches combat logs and displays instant alerts when hostiles activate Stealth, Prowl, Vanish, or stealth openers.'
            },
            {
                id = 'spySoundAlert',
                label = 'Play Audio Alarm on Enemy Spotted',
                tooltipTitle = 'Audio Warning Alarm',
                tooltipText = 'Plays an immediate raid warning audio alarm through the Master audio channel when a new hostile enemy is spotted.'
            },
            {
                id = 'spyFlashTaskbar',
                label = 'Flash Windows Taskbar on Enemy Spotted (Alt-Tab Alert)',
                tooltipTitle = 'OS Taskbar Flashing (UnitXP SP3)',
                tooltipText = 'Flashes your Windows taskbar via UnitXP SP3 FlashClientIcon when an enemy is spotted while you are alt-tabbed.'
            },
            {
                id = 'spyAnnounceNearby',
                label = 'Broadcast Spotted Hostiles to Party / Raid Chat',
                tooltipTitle = 'Group Hostile Broadcast',
                tooltipText = 'Automatically sends a party or raid chat alert containing the enemy player\'s name and class when spotted.'
            },
        },
    },
    {
        name = 'Combat HUD',
        title = 'Target Frame & Combat HUD Alerts',
        checkboxes = {
            {
                id = 'integratedTargetFrameCastbar',
                label = 'Compact Casting Bar inside TargetFrame Nameplate',
                tooltipTitle = 'Embedded Nameplate Castbar',
                tooltipText = 'Embeds a sleek casting progress bar directly inside the default Blizzard TargetFrame nameplate background.'
            },
            {
                id = 'targetFrameCastbar',
                label = 'Independent Movable Target Castbar with Icon',
                tooltipTitle = 'Movable Target Castbar',
                tooltipText = 'Renders an independent, movable castbar beneath your TargetFrame with spell icon, duration, and latency spark.'
            },
            {
                id = 'targetDebuffTimers',
                label = 'Show Timer Text on Target Debuffs',
                tooltipTitle = 'Target Debuff Timers',
                tooltipText = 'Displays numeric countdown seconds and cooldown spirals directly on TargetFrame buff and debuff icons.'
            },
            {
                id = 'targetCounter',
                label = 'Player Target Counter (Teammate Focus Indicator)',
                tooltipTitle = 'Focus Fire Target Counter',
                tooltipText = 'Shows the number of raid/party members currently targeting each enemy unit card for instant focus fire coordination.'
            },
            {
                id = 'castTimers',
                label = 'Show Cast Duration Timers on Unit Cards',
                tooltipTitle = 'Unit Card Cast Timers',
                tooltipText = 'Displays real-time numerical countdown seconds (e.g. 1.4s) on enemy card casting bars.'
            },
            {
                id = 'ccAnnounce',
                label = 'Announce Crowd Control (CC) Breaks to Chat',
                tooltipTitle = 'Crowd Control Alerts',
                tooltipText = 'Automatically alerts your team in /say or /battleground when your character is afflicted by major crowd control (Sap, Blind, Polymorph, Fear).'
            },
            {
                id = 'mouseOver',
                label = 'Enable Mouseover Spellcasting (on Frames)',
                tooltipTitle = 'Mouseover Spellcasting',
                tooltipText = 'Allows casting spells directly onto unit frame cards via mouseover bindings without dropping your current target.'
            },
        },
    },
}

local settings = CreateFrame('Frame', 'fosterFramesSettings', UIParent)
settings:ClearAllPoints()
settings:SetWidth(520)
settings:SetHeight(440)
settings:SetFrameLevel(60)
settings:SetPoint('CENTER', UIParent, 0, 0)
settings:SetBackdrop({
    bgFile   = [[Interface\Tooltips\UI-Tooltip-Background]],
    edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
    insets   = { left = 11, right = 12, top = 12, bottom = 11 }
})
settings:SetBackdropColor(0, 0, 0, 0.98)
settings:SetBackdropBorderColor(0.25, 0.25, 0.25)
settings:SetMovable(true)
settings:SetUserPlaced(true)
settings:SetClampedToScreen(true)
settings:RegisterForDrag('LeftButton')
settings:EnableMouse(true)
settings:SetScript('OnDragStart', function() this:StartMoving() end)
settings:SetScript('OnDragStop', function() this:StopMovingOrSizing() end)
table.insert(UISpecialFrames, 'fosterFramesSettings')
settings:Hide()

-- Header
settings.header = settings:CreateTexture(nil, 'ARTWORK')
settings.header:SetWidth(340)
settings.header:SetHeight(64)
settings.header:SetPoint('TOP', settings, 0, 12)
settings.header:SetTexture([[Interface\DialogFrame\UI-DialogBox-Header]])
settings.header:SetVertexColor(0.2, 0.2, 0.2)

settings.header.t = settings:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
settings.header.t:SetPoint('TOP', settings.header, 0, -14)
settings.header.t:SetText('FosterFrames Configuration')
settings.header.t:SetTextColor(0.68, 0.49, 0.93, 0.95)

-- Close Button
settings.x = CreateFrame('Button', 'fosterFramesSettingsCloseButton', settings, 'UIPanelCloseButton')
settings.x:SetPoint('TOPRIGHT', -6, -6)

-- Sidebar
settings.sidebar = CreateFrame('Frame', nil, settings)
settings.sidebar:SetWidth(118)
settings.sidebar:SetPoint('TOPLEFT', settings, 'TOPLEFT', 11, -40)
settings.sidebar:SetPoint('BOTTOMLEFT', settings, 'BOTTOMLEFT', 11, 11)
settings.sidebar:SetBackdrop({ bgFile = [[Interface\Tooltips\UI-Tooltip-Background]] })
settings.sidebar:SetBackdropColor(0.1, 0.1, 0.1, 0.6)

-- Content Area
settings.content = CreateFrame('Frame', 'fosterFramesSettingsContent', settings)
settings.content:SetPoint('TOPLEFT', settings.sidebar, 'TOPRIGHT', 6, 0)
settings.content:SetPoint('BOTTOMRIGHT', settings, 'BOTTOMRIGHT', -12, 11)
settings.content:SetBackdrop({ bgFile = [[Interface\Tooltips\UI-Tooltip-Background]] })
settings.content:SetBackdropColor(0.04, 0.04, 0.04, 0.6)

-- Containers and Controls
local containers = {}
local checkButtons = {}

local function ShowTooltip(owner, title, text)
    if not text then return end
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT", 4, 0)
    if title then
        GameTooltip:AddLine(title, 1, 0.82, 0)
    end
    GameTooltip:AddLine(text, 0.9, 0.9, 0.9, 1)
    GameTooltip:Show()
end

local function CreateTabContainers()
    local playerFaction = UnitFactionGroup('player')
    local factionColor = (playerFaction == 'Alliance') and RGB_FACTION_COLORS['Horde'] or RGB_FACTION_COLORS['Alliance']

    for tabIdx, tabData in ipairs(TABS_CONFIG) do
        local container = CreateFrame('Frame', 'fosterFramesTabContainer' .. tabIdx, settings.content)
        container:SetAllPoints(settings.content)
        container:EnableMouse(true)
        container:Hide()
        containers[tabIdx] = container

        local header = container:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
        header:SetPoint('TOPLEFT', container, 'TOPLEFT', 15, -15)
        header:SetText(tabData.title)
        header:SetTextColor(factionColor.r, factionColor.g, factionColor.b, 0.95)

        local prev = header
        if tabData.checkboxes then
            for cbIdx, cbData in ipairs(tabData.checkboxes) do
                local cb = CreateFrame('CheckButton', 'fosterFramesCB_' .. tabIdx .. '_' .. cbIdx, container, 'UICheckButtonTemplate')
                cb:SetHeight(22)
                cb:SetWidth(22)
                cb:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', 0, (cbIdx == 1 and -10 or -5))

                local cbText = _G[cb:GetName() .. 'Text']
                cbText:SetText(cbData.label)
                cbText:SetPoint('LEFT', cb, 'RIGHT', 6, 0)
                cbText:SetTextColor(factionColor.r, factionColor.g, factionColor.b, 0.9)

                cb.settingId = cbData.id
                cb.ttTitle = cbData.tooltipTitle or cbData.label
                cb.ttText = cbData.tooltipText

                cb:SetScript('OnClick', function()
                    FOSTERFRAMESPLAYERDATA[this.settingId] = this:GetChecked() and true or false
                    if FOSTERFRAMESsettings then FOSTERFRAMESsettings() end
                end)

                cb:SetScript('OnEnter', function()
                    ShowTooltip(this, this.ttTitle, this.ttText)
                end)
                cb:SetScript('OnLeave', function()
                    GameTooltip:Hide()
                end)

                table.insert(checkButtons, cb)
                prev = cb
            end
        end

        -- Dimensions & Sliders for Display Tab
        if tabData.hasDimensions then
            -- Width Slider
            local widthLabel = container:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
            widthLabel:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', 0, -12)
            widthLabel:SetText('Frame Width')
            widthLabel:SetTextColor(factionColor.r, factionColor.g, factionColor.b, 0.9)

            local widthSlider = CreateFrame('Slider', 'fosterFramesWidthSlider', container, 'OptionsSliderTemplate')
            widthSlider:SetWidth(160)
            widthSlider:SetHeight(16)
            widthSlider:SetPoint('TOPLEFT', widthLabel, 'BOTTOMLEFT', 5, -8)
            widthSlider:SetMinMaxValues(100, 240)
            widthSlider:SetValueStep(2)
            _G[widthSlider:GetName() .. 'Low']:SetText('100px')
            _G[widthSlider:GetName() .. 'High']:SetText('240px')
            _G[widthSlider:GetName() .. 'Text']:SetText((FOSTERFRAMESPLAYERDATA['unitWidth'] or 150) .. 'px')

            widthSlider.ttTitle = 'Frame Width'
            widthSlider.ttText = 'Adjusts the horizontal width in pixels of each enemy unit card (default: 150px).'

            widthSlider:SetScript('OnValueChanged', function()
                local v = math.floor(this:GetValue() + 0.5)
                FOSTERFRAMESPLAYERDATA['unitWidth'] = v
                _G[this:GetName() .. 'Text']:SetText(v .. 'px')
                if FOSTERFRAMES_UpdateDimensions then
                    FOSTERFRAMES_UpdateDimensions(v, FOSTERFRAMESPLAYERDATA['unitHeight'])
                end
            end)
            widthSlider:SetScript('OnEnter', function() ShowTooltip(this, this.ttTitle, this.ttText) end)
            widthSlider:SetScript('OnLeave', function() GameTooltip:Hide() end)
            container.widthSlider = widthSlider

            -- Height Slider
            local heightLabel = container:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
            heightLabel:SetPoint('LEFT', widthLabel, 'LEFT', 185, 0)
            heightLabel:SetText('Frame Height')
            heightLabel:SetTextColor(factionColor.r, factionColor.g, factionColor.b, 0.9)

            local heightSlider = CreateFrame('Slider', 'fosterFramesHeightSlider', container, 'OptionsSliderTemplate')
            heightSlider:SetWidth(160)
            heightSlider:SetHeight(16)
            heightSlider:SetPoint('TOPLEFT', heightLabel, 'BOTTOMLEFT', 5, -8)
            heightSlider:SetMinMaxValues(18, 45)
            heightSlider:SetValueStep(1)
            _G[heightSlider:GetName() .. 'Low']:SetText('18px')
            _G[heightSlider:GetName() .. 'High']:SetText('45px')
            _G[heightSlider:GetName() .. 'Text']:SetText((FOSTERFRAMESPLAYERDATA['unitHeight'] or 24) .. 'px')


            heightSlider.ttTitle = 'Frame Height'
            heightSlider.ttText = 'Adjusts the vertical height in pixels of each enemy unit card (default: 24px).'

            heightSlider:SetScript('OnValueChanged', function()
                local v = math.floor(this:GetValue() + 0.5)
                FOSTERFRAMESPLAYERDATA['unitHeight'] = v
                _G[this:GetName() .. 'Text']:SetText(v .. 'px')
                if FOSTERFRAMES_UpdateDimensions then
                    FOSTERFRAMES_UpdateDimensions(FOSTERFRAMESPLAYERDATA['unitWidth'], v)
                end
            end)
            heightSlider:SetScript('OnEnter', function() ShowTooltip(this, this.ttTitle, this.ttText) end)
            heightSlider:SetScript('OnLeave', function() GameTooltip:Hide() end)
            container.heightSlider = heightSlider

            -- Scale Slider
            -- Scale Slider
            local scaleLabel = container:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
            scaleLabel:SetPoint('TOPLEFT', widthSlider, 'BOTTOMLEFT', -5, -14)
            scaleLabel:SetText('Global Scale')
            scaleLabel:SetTextColor(factionColor.r, factionColor.g, factionColor.b, 0.9)

            local scaleSlider = CreateFrame('Slider', 'fosterFramesScaleSlider', container, 'OptionsSliderTemplate')
            scaleSlider:SetWidth(160)
            scaleSlider:SetHeight(16)
            scaleSlider:SetPoint('TOPLEFT', scaleLabel, 'BOTTOMLEFT', 5, -8)
            scaleSlider:SetMinMaxValues(0.8, 1.5)
            scaleSlider:SetValueStep(0.05)
            _G[scaleSlider:GetName() .. 'Low']:SetText('0.8x')
            _G[scaleSlider:GetName() .. 'High']:SetText('1.5x')
            _G[scaleSlider:GetName() .. 'Text']:SetText((FOSTERFRAMESPLAYERDATA['scale'] or 1.0) .. 'x')

            scaleSlider.ttTitle = 'Global Scale'
            scaleSlider.ttText = 'Scales the overall size and dimensions of the FosterFrames unit grid between 0.8x and 1.5x.'

            scaleSlider:SetScript('OnValueChanged', function()
                local val = FosterFrames.Helpers.Round(this:GetValue(), 2)
                FOSTERFRAMESPLAYERDATA['scale'] = val
                _G[this:GetName() .. 'Text']:SetText(val .. 'x')
                if fosterFrameDisplay then
                    fosterFrameDisplay:SetScale(val)
                end
            end)
            scaleSlider:SetScript('OnEnter', function() ShowTooltip(this, this.ttTitle, this.ttText) end)
            scaleSlider:SetScript('OnLeave', function() GameTooltip:Hide() end)
            container.scaleSlider = scaleSlider
        end
    end
end

-- Refresh UI State
local function RefreshSettingsUI()
    for _, cb in ipairs(checkButtons) do
        cb:SetChecked(FOSTERFRAMESPLAYERDATA[cb.settingId] and true or false)
    end

    if containers[1] then
        if containers[1].widthSlider then
            local w = FOSTERFRAMESPLAYERDATA['unitWidth'] or 150
            containers[1].widthSlider:SetValue(w)
            _G[containers[1].widthSlider:GetName() .. 'Text']:SetText(w .. 'px')
        end
        if containers[1].heightSlider then
            local h = FOSTERFRAMESPLAYERDATA['unitHeight'] or 24
            containers[1].heightSlider:SetValue(h)
            _G[containers[1].heightSlider:GetName() .. 'Text']:SetText(h .. 'px')
        end
        if containers[1].scaleSlider then
            local s = FOSTERFRAMESPLAYERDATA['scale'] or 1.0
            containers[1].scaleSlider:SetValue(s)
            _G[containers[1].scaleSlider:GetName() .. 'Text']:SetText(s .. 'x')
        end
    end
end


-- Sidebar Navigation Buttons
settings.tabs = {}
for i, tabData in ipairs(TABS_CONFIG) do
    local btn = CreateFrame('Button', 'fosterFramesTabBtn' .. i, settings.sidebar, 'UIPanelButtonTemplate')
    btn:SetWidth(106)
    btn:SetHeight(25)
    btn:SetText(tabData.name)
    btn:SetPoint('TOP', settings.sidebar, 'TOP', 0, -8 - (i - 1) * 28)
    btn.tabIdx = i

    btn:SetScript('OnClick', function()
        for idx, cont in ipairs(containers) do
            if idx == this.tabIdx then cont:Show() else cont:Hide() end
        end
    end)
    settings.tabs[i] = btn
end

-- Test Mode Button (Live Preview Cycler: 10 -> 15 -> 40 -> OFF)
settings.testBtn = CreateFrame('Button', 'fosterFramesSettingsTestButton', settings.sidebar, 'UIPanelButtonTemplate')
settings.testBtn:SetWidth(106)
settings.testBtn:SetHeight(24)
settings.testBtn:SetPoint('BOTTOM', settings.sidebar, 'BOTTOM', 0, 68)
settings.testBtn:SetText('Test: 10')
settings.testBtn.ttTitle = 'Live Preview Scenarios'
settings.testBtn.ttText = 'Cycles live preview test scenarios:\n• Test: 10 (Warsong Gulch & Arena 10v10)\n• Test: 15 (Arathi Basin 15v15)\n• Test: 40 (Alterac Valley 40v40)\n• Test: OFF (Disable preview)'
settings.testBtn:SetScript('OnClick', function()
    if not FOSTERFRAMES_TESTMODE then
        FOSTERFRAMES_SetTestMode(true, 10)
        this:SetText('Test: 10 (WSG)')
    elseif FOSTERFRAMES_GetTestCount and FOSTERFRAMES_GetTestCount() == 10 then
        FOSTERFRAMES_SetTestMode(true, 15)
        this:SetText('Test: 15 (AB)')
    elseif FOSTERFRAMES_GetTestCount and FOSTERFRAMES_GetTestCount() == 15 then
        FOSTERFRAMES_SetTestMode(true, 40)
        this:SetText('Test: 40 (AV)')
    else
        FOSTERFRAMES_SetTestMode(false)
        this:SetText('Test: OFF')
    end
end)
settings.testBtn:SetScript('OnEnter', function()
    ShowTooltip(this, this.ttTitle, this.ttText)
end)
settings.testBtn:SetScript('OnLeave', function() GameTooltip:Hide() end)

-- Unlock/Lock Position Button
settings.unlock = CreateFrame('Button', 'fosterFramesSettingsUnlockButton', settings.sidebar, 'UIPanelButtonTemplate')
settings.unlock:SetWidth(106)
settings.unlock:SetHeight(24)
settings.unlock:SetPoint('BOTTOM', settings.sidebar, 'BOTTOM', 0, 39)
settings.unlock:SetText(FOSTERFRAMESPLAYERDATA['frameMovable'] and 'Lock' or 'Unlock')
settings.unlock.ttTitle = 'Lock / Unlock Frames'
settings.unlock.ttText = 'When unlocked, enables dragging the FosterFrames container across your screen with the mouse.'
settings.unlock:SetScript('OnClick', function()
    FOSTERFRAMESPLAYERDATA['frameMovable'] = not FOSTERFRAMESPLAYERDATA['frameMovable']
    this:SetText(FOSTERFRAMESPLAYERDATA['frameMovable'] and 'Lock' or 'Unlock')
    if fosterFrameDisplay and fosterFrameDisplay.bg then
        if FOSTERFRAMESPLAYERDATA['frameMovable'] then fosterFrameDisplay.bg:Show() else fosterFrameDisplay.bg:Hide() end
    end
    if fosterFrameDisplay and fosterFrameDisplay.lockBtn and fosterFrameDisplay.lockBtn.text then
        fosterFrameDisplay.lockBtn.text:SetText(FOSTERFRAMESPLAYERDATA['frameMovable'] and '-' or '+')
    end
    if FOSTERFRAMESsettings then FOSTERFRAMESsettings() end
end)
settings.unlock:SetScript('OnEnter', function()
    ShowTooltip(this, this.ttTitle, this.ttText)
end)
settings.unlock:SetScript('OnLeave', function() GameTooltip:Hide() end)

-- Reset Position Button
settings.reset = CreateFrame('Button', 'fosterFramesSettingsResetButton', settings.sidebar, 'UIPanelButtonTemplate')
settings.reset:SetWidth(106)
settings.reset:SetHeight(24)
settings.reset:SetPoint('BOTTOM', settings.sidebar, 'BOTTOM', 0, 10)
settings.reset:SetText('Reset Pos')
settings.reset.ttTitle = 'Reset Position'
settings.reset.ttText = 'Resets the frame grid location to the default screen center.'
settings.reset:SetScript('OnClick', function()
    if fosterFrameDisplay then
        fosterFrameDisplay:ClearAllPoints()
        fosterFrameDisplay:SetPoint('CENTER', UIParent, 0, 100)
    end
    FOSTERFRAMESPLAYERDATA['offX'] = 0
    FOSTERFRAMESPLAYERDATA['offY'] = 100
end)
settings.reset:SetScript('OnEnter', function()
    ShowTooltip(this, this.ttTitle, this.ttText)
end)
settings.reset:SetScript('OnLeave', function() GameTooltip:Hide() end)

local function setupSettings()
    if #containers == 0 then
        CreateTabContainers()
    end

    RefreshSettingsUI()

    for idx, cont in ipairs(containers) do
        if idx == 1 then cont:Show() else cont:Hide() end
    end

    settings:Show()
    settings.unlock:SetText(FOSTERFRAMESPLAYERDATA['frameMovable'] and 'Lock' or 'Unlock')

    -- Automatically activate test preview when opening settings for immediate visual feedback
    FOSTERFRAMES_SetTestMode(true, 10)
    settings.testBtn:SetText('Test: 10 (WSG)')

    if FOSTERFRAMESsettings then FOSTERFRAMESsettings() end
    if TARGETFRAMECASTBARsettings then TARGETFRAMECASTBARsettings(true) end
end

local function closeSettings()
    if not FOSTERFRAMES_DEBUG then
        FOSTERFRAMES_SetTestMode(false)
    end
    if FOSTERFRAMESPLAYERDATA and not FOSTERFRAMESPLAYERDATA['enableFrames'] and fosterFrameDisplay then
        fosterFrameDisplay:Hide()
    end
    if TARGETFRAMECASTBARsettings then TARGETFRAMECASTBARsettings(false) end
end

settings.x:SetScript('OnClick', function()
    closeSettings()
    settings:Hide()
end)

settings:SetScript('OnHide', closeSettings)

-- Event Handler
local eventFrame = CreateFrame('Frame')
eventFrame:RegisterEvent('PLAYER_LOGIN')
eventFrame:RegisterEvent('PLAYER_LOGOUT')
eventFrame:SetScript('OnEvent', function()
    if event == 'PLAYER_LOGIN' then
        DEFAULT_CHAT_FRAME:AddMessage("|cffae7cee[FosterFrames]|r v" .. FOSTERFRAMESVERSION .. " loaded (ClassicAPI + SuperWoW). Type |cffffffff/ff|r or |cffffffff/ffs|r for settings.")
        if fosterFrameDisplay then
            fosterFrameDisplay:SetScale(FOSTERFRAMESPLAYERDATA['scale'] or 1.0)
            fosterFrameDisplay:ClearAllPoints()
            fosterFrameDisplay:SetPoint('CENTER', UIParent, FOSTERFRAMESPLAYERDATA['offX'] or 0, FOSTERFRAMESPLAYERDATA['offY'] or 100)
        end
    elseif event == 'PLAYER_LOGOUT' then
        if fosterFrameDisplay then
            local _, _, _, xOfs, yOfs = fosterFrameDisplay:GetPoint()
            FOSTERFRAMESPLAYERDATA['offX'] = xOfs or 0
            FOSTERFRAMESPLAYERDATA['offY'] = yOfs or 100
        end
    end
end)

-- Slash Commands (Rule F3: O(1) Dispatch Table)
SLASH_FOSTERFRAMES1 = '/ff'
SLASH_FOSTERFRAMES2 = '/fosterframes'
SLASH_FOSTERFRAMES3 = '/ffs'

local slashCommands = {
    ['15']    = function() FOSTERFRAMES_SetTestMode(true, 15) end,
    ['ab']    = function() FOSTERFRAMES_SetTestMode(true, 15) end,
    ['10']    = function() FOSTERFRAMES_SetTestMode(true, 10) end,
    ['wsg']   = function() FOSTERFRAMES_SetTestMode(true, 10) end,
    ['debug'] = function() FOSTERFRAMES_SetTestMode(true, 10) end,
    ['test']  = function() FOSTERFRAMES_SetTestMode(true, 10) end,
    ['40']    = function() FOSTERFRAMES_SetTestMode(true, 40) end,
    ['av']    = function() FOSTERFRAMES_SetTestMode(true, 40) end,
    ['hide']  = function() FOSTERFRAMES_HideFrames() end,
    ['off']   = function() FOSTERFRAMES_HideFrames() end,
    ['data']  = function() FOSTERFRAMES_DebugDisplayPlayerData() end,
}

SlashCmdList["FOSTERFRAMES"] = function(msg)
    local cmd = string.lower(msg or "")
    local handler = slashCommands[cmd]
    if handler then
        handler()
    else
        if settings:IsShown() then
            closeSettings()
            settings:Hide()
        else
            setupSettings()
        end
    end
end



