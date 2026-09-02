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
        ['openWorldScanning']            = true,
        ['specSpecificIcons']            = true,
        ['smartDistanceSorting']         = false,
        ['ccAnnounce']                   = false,
        ['displayHealthValues']          = false,
        ['displayManaValues']            = false,
        -- Battlegrounds
        ['efcBGannouncement']            = true,
        ['efcDistanceTracking']          = true,
        -- Optionals
        ['displayNames']                 = true,
        ['displayManabar']               = false,
        ['displayOnlyNearby']            = false,
        ['castTimers']                   = false,
        ['targetCounter']                = false,
        ['offX']                         = 0,
        ['offY']                         = 0,
    }
end

-- Configuration Tabs Definition
local TABS_CONFIG = {
    {
        name = 'General',
        title = 'General Settings',
        checkboxes = {
            { id = 'enableFrames', label = 'Enable Addon (Show Frames)' },
        },
        hasScale = true,
    },
    {
        name = 'Tactical',
        title = 'Tactical Features',
        checkboxes = {
            { id = 'mouseOver',                    label = 'Enable Mouseover Cast (on Frames)' },
            { id = 'targetFrameCastbar',           label = 'Movable Casting Bar for Target' },
            { id = 'integratedTargetFrameCastbar', label = 'Compact Casting Bar (inside Name)' },
            { id = 'targetDebuffTimers',           label = 'Show Timer Text on Target Debuffs' },
            { id = 'specSpecificIcons',            label = 'Show Talent Spec Icons (instead of Class)' },
            { id = 'ccAnnounce',                   label = 'Announce CCs to Chat (/say, /bg)' },
        },
    },
    {
        name = 'Automation',
        title = 'Automation & Battlegrounds',
        checkboxes = {
            { id = 'openWorldScanning',    label = 'Scan Players in Open World (Non-BG)' },
            { id = 'smartDistanceSorting', label = 'Sort Frames by Distance (Closest first)' },
            { id = 'efcDistanceTracking',  label = 'Track Distance to Flag Carrier (WSG)' },
            { id = 'efcBGannouncement',    label = 'Alert Chat when EFC has Low Health' },
        },
    },
    {
        name = 'Appearance',
        title = 'Appearance & Layout',
        checkboxes = {
            { id = 'displayNames',        label = 'Show Player Names on Frames' },
            { id = 'displayManabar',      label = 'Show Mana/Rage/Energy Bar' },
            { id = 'displayHealthValues', label = 'Show Health Numbers (UnitXP SP3)' },
            { id = 'displayManaValues',   label = 'Show Mana Numbers (UnitXP SP3)' },
            { id = 'displayOnlyNearby',   label = 'Hide Distant/Dead Units' },
            { id = 'castTimers',          label = 'Show Cast Bar Timer Text' },
        },
        hasLayout = true,
    }
}

local settings = CreateFrame('Frame', 'fosterFramesSettings', UIParent)
settings:ClearAllPoints()
settings:SetWidth(460)
settings:SetHeight(360)
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
settings.sidebar:SetWidth(100)
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
                cb:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', (cbIdx == 1 and 0 or 0), (cbIdx == 1 and -10 or -6))

                local cbText = _G[cb:GetName() .. 'Text']
                cbText:SetText(cbData.label)
                cbText:SetPoint('LEFT', cb, 'RIGHT', 6, 0)
                cbText:SetTextColor(factionColor.r, factionColor.g, factionColor.b, 0.9)

                cb.settingId = cbData.id
                cb:SetScript('OnClick', function()
                    FOSTERFRAMESPLAYERDATA[this.settingId] = this:GetChecked() and true or false
                    if FOSTERFRAMESsettings then FOSTERFRAMESsettings() end
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
            scaleSlider:SetWidth(200)
            scaleSlider:SetHeight(16)
            scaleSlider:SetPoint('TOPLEFT', scaleLabel, 'BOTTOMLEFT', 5, -8)
            scaleSlider:SetMinMaxValues(0.8, 1.5)
            scaleSlider:SetValueStep(0.05)
            _G[scaleSlider:GetName() .. 'Low']:SetText('0.8')
            _G[scaleSlider:GetName() .. 'High']:SetText('1.5')
            _G[scaleSlider:GetName() .. 'Text']:SetText('')

            scaleSlider:SetScript('OnValueChanged', function()
                local val = FosterFrames.Helpers.Round(this:GetValue(), 2)
                FOSTERFRAMESPLAYERDATA['scale'] = val
                if fosterFrameDisplay then
                    fosterFrameDisplay:SetScale(val)
                end
            end)
            container.scaleSlider = scaleSlider
        end

        -- Layout Slider for Appearance
        if tabData.hasLayout then
            local layoutLabel = container:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
            layoutLabel:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', 0, -15)
            layoutLabel:SetText('Frame Layout Mode')
            layoutLabel:SetTextColor(factionColor.r, factionColor.g, factionColor.b, 0.9)

            local layoutSlider = CreateFrame('Slider', 'fosterFramesLayoutSlider', container, 'OptionsSliderTemplate')
            layoutSlider:SetWidth(200)
            layoutSlider:SetHeight(16)
            layoutSlider:SetPoint('TOPLEFT', layoutLabel, 'BOTTOMLEFT', 5, -8)
            layoutSlider:SetMinMaxValues(0, 4)
            layoutSlider:SetValueStep(1)
            _G[layoutSlider:GetName() .. 'Low']:SetText('Horizontal')
            _G[layoutSlider:GetName() .. 'High']:SetText('Vertical')
            _G[layoutSlider:GetName() .. 'Text']:SetText('')

            layoutSlider:SetScript('OnValueChanged', function()
                local v = this:GetValue()
                local layoutMap = { [0] = 'horizontal', [1] = 'hblock', [2] = 'block', [3] = 'vblock', [4] = 'vertical' }
                local groupMap = { [0] = 1, [1] = 5, [2] = 5, [3] = 2, [4] = 15 }
                FOSTERFRAMESPLAYERDATA['layout'] = layoutMap[v] or 'block'
                FOSTERFRAMESPLAYERDATA['groupsize'] = groupMap[v] or 5
                if FOSTERFRAMESsettings then FOSTERFRAMESsettings() end
            end)
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

    if containers[4] and containers[4].layoutSlider then
        local layout = FOSTERFRAMESPLAYERDATA['layout'] or 'block'
        local val = (layout == 'horizontal' and 0) or (layout == 'hblock' and 1) or (layout == 'block' and 2) or (layout == 'vblock' and 3) or 4
        containers[4].layoutSlider:SetValue(val)
    end
end

-- Sidebar Navigation Buttons
settings.tabs = {}
for i, tabData in ipairs(TABS_CONFIG) do
    local btn = CreateFrame('Button', 'fosterFramesTabBtn' .. i, settings.sidebar, 'UIPanelButtonTemplate')
    btn:SetWidth(90)
    btn:SetHeight(24)
    btn:SetText(tabData.name)
    btn:SetPoint('TOP', settings.sidebar, 'TOP', 0, -10 - (i - 1) * 30)
    btn.tabIdx = i

    btn:SetScript('OnClick', function()
        for idx, cont in ipairs(containers) do
            if idx == this.tabIdx then cont:Show() else cont:Hide() end
        end
    end)
    settings.tabs[i] = btn
end

-- Unlock/Lock Position Button
settings.unlock = CreateFrame('Button', 'fosterFramesSettingsUnlockButton', settings.sidebar, 'UIPanelButtonTemplate')
settings.unlock:SetWidth(90)
settings.unlock:SetHeight(24)
settings.unlock:SetPoint('BOTTOM', settings.sidebar, 'BOTTOM', 0, 40)
settings.unlock:SetText(FOSTERFRAMESPLAYERDATA['frameMovable'] and 'Lock' or 'Unlock')
settings.unlock:SetScript('OnClick', function()
    FOSTERFRAMESPLAYERDATA['frameMovable'] = not FOSTERFRAMESPLAYERDATA['frameMovable']
    this:SetText(FOSTERFRAMESPLAYERDATA['frameMovable'] and 'Lock' or 'Unlock')
    if fosterFrameDisplay and fosterFrameDisplay.bg then
        if FOSTERFRAMESPLAYERDATA['frameMovable'] then fosterFrameDisplay.bg:Show() else fosterFrameDisplay.bg:Hide() end
    end
    if FOSTERFRAMESsettings then FOSTERFRAMESsettings() end
end)

-- Reset Position Button
settings.reset = CreateFrame('Button', 'fosterFramesSettingsResetButton', settings.sidebar, 'UIPanelButtonTemplate')
settings.reset:SetWidth(90)
settings.reset:SetHeight(24)
settings.reset:SetPoint('BOTTOM', settings.sidebar, 'BOTTOM', 0, 10)
settings.reset:SetText('Reset Pos')
settings.reset:SetScript('OnClick', function()
    if fosterFrameDisplay then
        fosterFrameDisplay:ClearAllPoints()
        fosterFrameDisplay:SetPoint('CENTER', UIParent, 0, 100)
    end
    FOSTERFRAMESPLAYERDATA['offX'] = 0
    FOSTERFRAMESPLAYERDATA['offY'] = 0
end)

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

    if FOSTERFRAMESsettings then FOSTERFRAMESsettings() end
    if TARGETFRAMECASTBARsettings then TARGETFRAMECASTBARsettings(true) end
end

local function closeSettings()
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
            FOSTERFRAMESPLAYERDATA['offY'] = yOfs or 0
        end
    end
end)

-- Slash Commands
SLASH_FOSTERFRAMES1 = '/ff'
SLASH_FOSTERFRAMES2 = '/fosterframes'
SLASH_FOSTERFRAMES3 = '/ffs'
SlashCmdList["FOSTERFRAMES"] = function(msg)
    if msg == 'debug' or msg == 'cd' then
        FOSTERFRAMES_DebugCooldownTest()
    elseif msg == 'hide' then
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

