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
        -- Options
        ['scale']                        = 1,
        ['unitWidth']                    = 126,
        ['unitHeight']                   = 24,
        ['groupsize']                    = 5,
        ['layout']                       = 'block',
        ['frameMovable']                 = true,
        ['enableFrames']                 = true,
        -- Features
        ['mouseOver']                    = false,
        ['targetFrameCastbar']           = true,
        ['integratedTargetFrameCastbar'] = true,
        ['targetDebuffTimers']           = false,
        ['playerTargetCounter']          = false,
        ['specSpecificIcons']            = true,
        ['ccAnnounce']                   = false,
        ['displayHealthValues']          = false,
        ['displayManaValues']            = false,
        -- Spy Mode
        ['openWorldScanning']            = true,
        ['spySoundAlert']                = true,
        ['spyFlashTaskbar']              = false,
        ['spyStealthAlert']              = true,
        ['spyAnnounceNearby']            = false,
        -- Battlegrounds
        ['smartDistanceSorting']         = false,
        ['efcBGannouncement']            = true,
        ['efcDistanceTracking']          = true,
        -- Optionals
        ['displayNames']                 = true,
        ['displayManabar']               = false,
        ['displayOnlyNearby']            = false,
        ['castTimers']                   = false,
        ['targetCounter']                = false,
        ['offX']                         = 0,
        ['offY']                         = 100,
    }
end

-- Configuration Tabs & Technical Tooltip Metadata
local TABS_CONFIG = {
    {
        name = 'General',
        title = 'General Settings',
        checkboxes = {
            {
                id = 'enableFrames',
                label = 'Enable Addon (Show Frames)',
                tooltipTitle = 'Enable FosterFrames',
                tooltipText = 'Master toggle to display enemy unit frame cards and tactical combat HUD elements.'
            },
        },
        hasScale = true,
        scaleTitle = 'Global Frame Scale',
        scaleTooltip = 'Scales the overall size and dimension of the FosterFrames unit grid between 0.8x and 1.5x.'
    },
    {
        name = 'Tactical',
        title = 'Tactical Features',
        checkboxes = {
            {
                id = 'mouseOver',
                label = 'Enable Mouseover Cast (on Frames)',
                tooltipTitle = 'Mouseover Spellcasting',
                tooltipText = 'Allows casting spells directly onto unit frame cards via mouseover bindings without dropping your current target.'
            },
            {
                id = 'targetFrameCastbar',
                label = 'Movable Casting Bar for Target',
                tooltipTitle = 'Movable Target Castbar',
                tooltipText = 'Renders an independent, movable castbar beneath your TargetFrame with spell icon, duration, and latency spark.'
            },
            {
                id = 'integratedTargetFrameCastbar',
                label = 'Compact Casting Bar (inside Name)',
                tooltipTitle = 'Embedded Nameplate Castbar',
                tooltipText = 'Embeds a sleek casting progress bar directly inside the default Blizzard TargetFrame nameplate background.'
            },
            {
                id = 'targetDebuffTimers',
                label = 'Show Timer Text on Target Debuffs',
                tooltipTitle = 'Target Debuff Timers',
                tooltipText = 'Displays numeric countdown seconds and cooldown spirals directly on TargetFrame buff and debuff icons.'
            },
            {
                id = 'specSpecificIcons',
                label = 'Show Talent Spec Icons (instead of Class)',
                tooltipTitle = 'Talent Spec Icons',
                tooltipText = 'Queries SuperWoW UnitSpec and talent data to display specialization icons (e.g. Shadow, Arms, Frost) instead of standard class crests.'
            },
            {
                id = 'ccAnnounce',
                label = 'Announce CCs to Chat (/say, /bg)',
                tooltipTitle = 'Crowd Control Alerts',
                tooltipText = 'Automatically alerts your team in /say or /battleground when your character is afflicted by major crowd control (Sap, Blind, Polymorph, Fear).'
            },
        },
    },
    {
        name = 'Spy',
        title = 'Spy & World PvP Detection',
        checkboxes = {
            {
                id = 'openWorldScanning',
                label = 'Scan Hostiles in Open World (Non-BG)',
                tooltipTitle = 'Open World PvP Radar',
                tooltipText = 'Enables nameplate and combat log scanning outside battlegrounds to detect, track, and display hostile players in world PvP.'
            },
            {
                id = 'spySoundAlert',
                label = 'Play Warning Alarm on Enemy Detected',
                tooltipTitle = 'Audio Warning Alarm',
                tooltipText = 'Plays an immediate raid warning audio alarm through the Master audio channel when a new hostile enemy is spotted.'
            },
            {
                id = 'spyFlashTaskbar',
                label = 'Flash OS Taskbar on Enemy Detected',
                tooltipTitle = 'OS Taskbar Flashing (UnitXP SP3)',
                tooltipText = 'Flashes your Windows taskbar via UnitXP SP3 FlashClientIcon when an enemy is spotted while you are alt-tabbed.'
            },
            {
                id = 'spyStealthAlert',
                label = 'Stealth Detection Warnings (Rogue/Druid)',
                tooltipTitle = 'Stealth Action Watcher',
                tooltipText = 'Watches combat logs and displays instant alerts when hostiles activate Stealth, Prowl, Vanish, or stealth openers.'
            },
            {
                id = 'spyAnnounceNearby',
                label = 'Broadcast Detected Hostiles to Party/Raid',
                tooltipTitle = 'Group Hostile Broadcast',
                tooltipText = 'Automatically sends a party or raid chat alert containing the enemy player\'s name and class when spotted.'
            },
        },
    },
    {
        name = 'Automation',
        title = 'Automation & Battlegrounds',
        checkboxes = {
            {
                id = 'smartDistanceSorting',
                label = 'Sort Frames by Distance (Closest first)',
                tooltipTitle = 'Smart Distance Sorting',
                tooltipText = 'Continuously sorts unit frame cards by real-time 3D Euclidean distance (via UnitXP SP3), placing the closest hostiles at the top.'
            },
            {
                id = 'efcDistanceTracking',
                label = 'Track Distance to Flag Carrier (WSG)',
                tooltipTitle = 'EFC Distance Telemetry',
                tooltipText = 'Calculates live 3D yard distance to the Enemy Flag Carrier in Warsong Gulch and updates targeting telemetry.'
            },
            {
                id = 'efcBGannouncement',
                label = 'Alert Chat when EFC has Low Health',
                tooltipTitle = 'EFC Low Health Announcement',
                tooltipText = 'Automatically broadcasts an alert to the /battleground chat channel when the Enemy Flag Carrier\'s health drops below 40%, 20%, or 10% in Warsong Gulch.'
            },
        },
    },
    {
        name = 'Appearance',
        title = 'Appearance & Layout',
        checkboxes = {
            {
                id = 'displayNames',
                label = 'Show Player Names on Frames',
                tooltipTitle = 'Display Player Names',
                tooltipText = 'Displays character names on enemy unit cards (automatically hidden when Health Numbers mode is active).'
            },
            {
                id = 'displayManabar',
                label = 'Show Mana/Rage/Energy Bar',
                tooltipTitle = 'Power Resource Bar',
                tooltipText = 'Displays secondary resource power bars (Mana, Rage, Energy) below unit health bars.'
            },
            {
                id = 'displayHealthValues',
                label = 'Show Health Numbers (UnitXP SP3)',
                tooltipTitle = 'Exact Health Numbers',
                tooltipText = 'Displays exact uncapped current and maximum numerical health values (e.g. 4850 / 5200) on unit health bars via UnitXP SP3.'
            },
            {
                id = 'displayManaValues',
                label = 'Show Mana Numbers (UnitXP SP3)',
                tooltipTitle = 'Exact Mana Numbers',
                tooltipText = 'Displays current and maximum numerical mana values on mana-using classes.'
            },
            {
                id = 'displayOnlyNearby',
                label = 'Hide Distant/Dead Units',
                tooltipTitle = 'Hide Out-of-Range Units',
                tooltipText = 'Dynamically hides enemy unit frame cards when players are out of range or not detected nearby.'
            },
            {
                id = 'castTimers',
                label = 'Show Cast Bar Timer Text',
                tooltipTitle = 'Cast Duration Timers',
                tooltipText = 'Displays real-time numerical countdown seconds (e.g. 1.4s) on enemy casting bars.'
            },
        },
        hasLayout = true,
        layoutTitle = 'Frame Layout Mode',
        layoutTooltip = 'Selects the layout arrangement for unit cards:\n• Horizontal: 1 row across\n• Horizontal Block: 5 columns x rows\n• Standard Block: 5 per group\n• Vertical Block: 2 columns\n• Vertical: 1 column down'
    }
}

local settings = CreateFrame('Frame', 'fosterFramesSettings', UIParent)
settings:ClearAllPoints()
settings:SetWidth(470)
settings:SetHeight(380)
settings:SetFrameLevel(60)
settings:SetPoint('CENTER', UIParent, 0, 0)
settings:SetBackdrop({
    bgFile   = [[Interface\Tooltips\UI-Tooltip-Background]],
    edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
    insets   = { left = 11, right = 12, top = 12, bottom = 11 }
})
settings:SetBackdropColor(0, 0, 0, 1)
settings:SetBackdropBorderColor(0.2, 0.2, 0.2)
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
settings.header:SetWidth(320)
settings.header:SetHeight(64)
settings.header:SetPoint('TOP', settings, 0, 12)
settings.header:SetTexture([[Interface\DialogFrame\UI-DialogBox-Header]])
settings.header:SetVertexColor(0.2, 0.2, 0.2)

settings.header.t = settings:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
settings.header.t:SetPoint('TOP', settings.header, 0, -14)
settings.header.t:SetText('FosterFrames Settings')
settings.header.t:SetTextColor(0.68, 0.49, 0.93, 0.9)

-- Close Button
settings.x = CreateFrame('Button', 'fosterFramesSettingsCloseButton', settings, 'UIPanelCloseButton')
settings.x:SetPoint('TOPRIGHT', -6, -6)

-- Sidebar
settings.sidebar = CreateFrame('Frame', nil, settings)
settings.sidebar:SetWidth(108)
settings.sidebar:SetPoint('TOPLEFT', settings, 'TOPLEFT', 11, -40)
settings.sidebar:SetPoint('BOTTOMLEFT', settings, 'BOTTOMLEFT', 11, 11)
settings.sidebar:SetBackdrop({ bgFile = [[Interface\Tooltips\UI-Tooltip-Background]] })
settings.sidebar:SetBackdropColor(0.1, 0.1, 0.1, 0.5)

-- Content Area
settings.content = CreateFrame('Frame', 'fosterFramesSettingsContent', settings)
settings.content:SetPoint('TOPLEFT', settings.sidebar, 'TOPRIGHT', 5, 0)
settings.content:SetPoint('BOTTOMRIGHT', settings, 'BOTTOMRIGHT', -12, 11)
settings.content:SetBackdrop({ bgFile = [[Interface\Tooltips\UI-Tooltip-Background]] })
settings.content:SetBackdropColor(0.05, 0.05, 0.05, 0.5)

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
        header:SetTextColor(factionColor.r, factionColor.g, factionColor.b, 0.9)

        local prev = header
        if tabData.checkboxes then
            for cbIdx, cbData in ipairs(tabData.checkboxes) do
                local cb = CreateFrame('CheckButton', 'fosterFramesCB_' .. tabIdx .. '_' .. cbIdx, container, 'UICheckButtonTemplate')
                cb:SetHeight(22)
                cb:SetWidth(22)
                cb:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', 0, (cbIdx == 1 and -10 or -6))

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

        -- Scale Slider for General
        if tabData.hasScale then
            local scaleLabel = container:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
            scaleLabel:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', 0, -15)
            scaleLabel:SetText('Global Frame Scale')
            scaleLabel:SetTextColor(factionColor.r, factionColor.g, factionColor.b, 0.9)

            local scaleSlider = CreateFrame('Slider', 'fosterFramesScaleSlider', container, 'OptionsSliderTemplate')
            scaleSlider:SetWidth(210)
            scaleSlider:SetHeight(16)
            scaleSlider:SetPoint('TOPLEFT', scaleLabel, 'BOTTOMLEFT', 5, -8)
            scaleSlider:SetMinMaxValues(0.8, 1.5)
            scaleSlider:SetValueStep(0.05)
            _G[scaleSlider:GetName() .. 'Low']:SetText('0.8')
            _G[scaleSlider:GetName() .. 'High']:SetText('1.5')
            _G[scaleSlider:GetName() .. 'Text']:SetText('')

            scaleSlider.ttTitle = tabData.scaleTitle or 'Frame Scale'
            scaleSlider.ttText = tabData.scaleTooltip

            scaleSlider:SetScript('OnValueChanged', function()
                local val = FosterFrames.Helpers.Round(this:GetValue(), 2)
                FOSTERFRAMESPLAYERDATA['scale'] = val
                if fosterFrameDisplay then
                    fosterFrameDisplay:SetScale(val)
                end
            end)

            scaleSlider:SetScript('OnEnter', function()
                ShowTooltip(this, this.ttTitle, this.ttText)
            end)
            scaleSlider:SetScript('OnLeave', function() GameTooltip:Hide() end)

            container.scaleSlider = scaleSlider
        end

        -- Dimensions & Layout Sliders for Appearance
        if tabData.hasLayout then
            -- Width Slider
            local widthLabel = container:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
            widthLabel:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', 0, -10)
            widthLabel:SetText('Frame Width')
            widthLabel:SetTextColor(factionColor.r, factionColor.g, factionColor.b, 0.9)

            local widthSlider = CreateFrame('Slider', 'fosterFramesWidthSlider', container, 'OptionsSliderTemplate')
            widthSlider:SetWidth(150)
            widthSlider:SetHeight(16)
            widthSlider:SetPoint('TOPLEFT', widthLabel, 'BOTTOMLEFT', 5, -8)
            widthSlider:SetMinMaxValues(80, 200)
            widthSlider:SetValueStep(2)
            _G[widthSlider:GetName() .. 'Low']:SetText('80px')
            _G[widthSlider:GetName() .. 'High']:SetText('200px')
            _G[widthSlider:GetName() .. 'Text']:SetText((FOSTERFRAMESPLAYERDATA['unitWidth'] or 126) .. 'px')

            widthSlider.ttTitle = 'Frame Width'
            widthSlider.ttText = 'Adjusts the horizontal width in pixels of each enemy unit card (default: 126px).'

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
            heightLabel:SetPoint('LEFT', widthLabel, 'LEFT', 170, 0)
            heightLabel:SetText('Frame Height')
            heightLabel:SetTextColor(factionColor.r, factionColor.g, factionColor.b, 0.9)

            local heightSlider = CreateFrame('Slider', 'fosterFramesHeightSlider', container, 'OptionsSliderTemplate')
            heightSlider:SetWidth(150)
            heightSlider:SetHeight(16)
            heightSlider:SetPoint('TOPLEFT', heightLabel, 'BOTTOMLEFT', 5, -8)
            heightSlider:SetMinMaxValues(16, 45)
            heightSlider:SetValueStep(1)
            _G[heightSlider:GetName() .. 'Low']:SetText('16px')
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

            -- Layout Slider
            local layoutLabel = container:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
            layoutLabel:SetPoint('TOPLEFT', widthSlider, 'BOTTOMLEFT', -5, -16)
            layoutLabel:SetText('Frame Layout Mode')
            layoutLabel:SetTextColor(factionColor.r, factionColor.g, factionColor.b, 0.9)

            local layoutSlider = CreateFrame('Slider', 'fosterFramesLayoutSlider', container, 'OptionsSliderTemplate')
            layoutSlider:SetWidth(210)
            layoutSlider:SetHeight(16)
            layoutSlider:SetPoint('TOPLEFT', layoutLabel, 'BOTTOMLEFT', 5, -8)
            layoutSlider:SetMinMaxValues(0, 4)
            layoutSlider:SetValueStep(1)
            _G[layoutSlider:GetName() .. 'Low']:SetText('Horizontal')
            _G[layoutSlider:GetName() .. 'High']:SetText('Vertical')
            _G[layoutSlider:GetName() .. 'Text']:SetText('')

            layoutSlider.ttTitle = tabData.layoutTitle or 'Layout Mode'
            layoutSlider.ttText = tabData.layoutTooltip

            layoutSlider:SetScript('OnValueChanged', function()
                local v = this:GetValue()
                local layoutMap = { [0] = 'horizontal', [1] = 'hblock', [2] = 'block', [3] = 'vblock', [4] = 'vertical' }
                local groupMap = { [0] = 1, [1] = 5, [2] = 5, [3] = 2, [4] = 15 }
                FOSTERFRAMESPLAYERDATA['layout'] = layoutMap[v] or 'block'
                FOSTERFRAMESPLAYERDATA['groupsize'] = groupMap[v] or 5
                if FOSTERFRAMESsettings then FOSTERFRAMESsettings() end
            end)

            layoutSlider:SetScript('OnEnter', function()
                ShowTooltip(this, this.ttTitle, this.ttText)
            end)
            layoutSlider:SetScript('OnLeave', function() GameTooltip:Hide() end)

            container.layoutSlider = layoutSlider
        end
    end
end

-- Refresh UI State
local function RefreshSettingsUI()
    for _, cb in ipairs(checkButtons) do
        cb:SetChecked(FOSTERFRAMESPLAYERDATA[cb.settingId] and true or false)
    end

    if containers[1] and containers[1].scaleSlider then
        containers[1].scaleSlider:SetValue(FOSTERFRAMESPLAYERDATA['scale'] or 1.0)
    end

    if containers[5] then
        if containers[5].widthSlider then
            local w = FOSTERFRAMESPLAYERDATA['unitWidth'] or 126
            containers[5].widthSlider:SetValue(w)
            _G[containers[5].widthSlider:GetName() .. 'Text']:SetText(w .. 'px')
        end
        if containers[5].heightSlider then
            local h = FOSTERFRAMESPLAYERDATA['unitHeight'] or 24
            containers[5].heightSlider:SetValue(h)
            _G[containers[5].heightSlider:GetName() .. 'Text']:SetText(h .. 'px')
        end
        if containers[5].layoutSlider then
            local layout = FOSTERFRAMESPLAYERDATA['layout'] or 'block'
            local val = (layout == 'horizontal' and 0) or (layout == 'hblock' and 1) or (layout == 'block' and 2) or (layout == 'vblock' and 3) or 4
            containers[5].layoutSlider:SetValue(val)
        end
    end
end

-- Sidebar Navigation Buttons
settings.tabs = {}
for i, tabData in ipairs(TABS_CONFIG) do
    local btn = CreateFrame('Button', 'fosterFramesTabBtn' .. i, settings.sidebar, 'UIPanelButtonTemplate')
    btn:SetWidth(98)
    btn:SetHeight(23)
    btn:SetText(tabData.name)
    btn:SetPoint('TOP', settings.sidebar, 'TOP', 0, -8 - (i - 1) * 26)
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
settings.testBtn:SetWidth(98)
settings.testBtn:SetHeight(23)
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
settings.unlock:SetWidth(98)
settings.unlock:SetHeight(23)
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
    if FOSTERFRAMESsettings then FOSTERFRAMESsettings() end
end)
settings.unlock:SetScript('OnEnter', function()
    ShowTooltip(this, this.ttTitle, this.ttText)
end)
settings.unlock:SetScript('OnLeave', function() GameTooltip:Hide() end)

-- Reset Position Button
settings.reset = CreateFrame('Button', 'fosterFramesSettingsResetButton', settings.sidebar, 'UIPanelButtonTemplate')
settings.reset:SetWidth(98)
settings.reset:SetHeight(23)
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

-- Slash Commands
SLASH_FOSTERFRAMES1 = '/ff'
SLASH_FOSTERFRAMES2 = '/fosterframes'
SLASH_FOSTERFRAMES3 = '/ffs'
SlashCmdList["FOSTERFRAMES"] = function(msg)
    if msg == '15' or msg == 'ab' then
        FOSTERFRAMES_SetTestMode(true, 15)
    elseif msg == '10' or msg == 'wsg' or msg == 'debug' or msg == 'test' then
        FOSTERFRAMES_SetTestMode(true, 10)
    elseif msg == 'hide' or msg == 'off' then
        FOSTERFRAMES_HideFrames()
    elseif msg == 'data' then
        FOSTERFRAMES_DebugDisplayPlayerData()
    else
        if settings:IsShown() then
            closeSettings()
            settings:Hide()
        else
            setupSettings()
        end
    end
end


