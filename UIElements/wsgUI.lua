-- FosterFrames - Warsong Gulch UI Overlay & EFC Health Tracking
-- Enhanced 1.12.1 Engine Stack (ClassicAPI, SuperWoW, UnitXP SP3)

local flagCarriers = {}
local fcHealth = {}
local sentAnnouncement = false
local healthWarnings = { 10, 20, 40 }
local nextAnnouncement = 0
local lowestWarning = 100
local announceInterval = 4

local h = WorldStateAlwaysUpFrame:CreateFontString(nil, 'OVERLAY')
h:SetFontObject(GameFontNormalSmall)
h:SetTextColor(RGB_FACTION_COLORS['Horde'].r, RGB_FACTION_COLORS['Horde'].g, RGB_FACTION_COLORS['Horde'].b)
h:SetJustifyH('LEFT')
h:SetText('')

local hb = CreateFrame('Button', nil, WorldStateAlwaysUpFrame)
hb:SetFrameLevel(2)
hb:SetAllPoints(h)
hb:EnableMouse(true)

local hh = WorldStateAlwaysUpFrame:CreateFontString(nil, 'OVERLAY')
hh:SetFontObject(GameFontNormalSmall)
hh:SetJustifyH('RIGHT')
hh:SetPoint('LEFT', h, 'RIGHT', 5, 0)
hh:SetText('')

local a = WorldStateAlwaysUpFrame:CreateFontString(nil, 'OVERLAY')
a:SetFontObject(GameFontNormalSmall)
a:SetTextColor(RGB_FACTION_COLORS['Alliance'].r, RGB_FACTION_COLORS['Alliance'].g, RGB_FACTION_COLORS['Alliance'].b)
a:SetJustifyH('LEFT')
a:SetText('')

local ab = CreateFrame('Button', nil, WorldStateAlwaysUpFrame)
ab:SetFrameLevel(2)
ab:SetAllPoints(a)
ab:EnableMouse(true)

local ah = WorldStateAlwaysUpFrame:CreateFontString(nil, 'OVERLAY')
ah:SetFontObject(GameFontNormalSmall)
ah:SetJustifyH('RIGHT')
ah:SetPoint('LEFT', a, 'RIGHT', 5, 0)
ah:SetText('')

local function OnEnter(btn)
    local label = (btn == hb) and h or a
    label:SetTextColor(0.9, 0.9, 0.4)
    local txt = label:GetText()
    if txt and txt ~= '' then
        GameTooltip:SetOwner(btn, 'ANCHOR_TOPRIGHT', -40, 10)
        GameTooltip:SetText('Click to target ' .. txt)
        GameTooltip:Show()
    end
end

local function OnLeave(btn)
    local label = (btn == hb) and h or a
    local fName = (label == a) and 'Alliance' or 'Horde'
    label:SetTextColor(RGB_FACTION_COLORS[fName].r, RGB_FACTION_COLORS[fName].g, RGB_FACTION_COLORS[fName].b)
    GameTooltip:Hide()
end

local function OnClick(btn)
    local label = (btn == hb) and h or a
    local t = label:GetText()
    if t and t ~= '' then
        TargetByName(t, true)
    end
end

hb:SetScript('OnClick', function() OnClick(this) end)
hb:SetScript('OnEnter', function() OnEnter(this) end)
hb:SetScript('OnLeave', function() OnLeave(this) end)

ab:SetScript('OnClick', function() OnClick(this) end)
ab:SetScript('OnEnter', function() OnEnter(this) end)
ab:SetScript('OnLeave', function() OnLeave(this) end)

function WSGUIupdateFC(fc)
    flagCarriers = fc or {}

    if flagCarriers['Horde'] then
        h:SetText(flagCarriers['Horde'])
    else
        h:SetText('')
        hh:SetText('')
        fcHealth['Horde'] = nil
    end

    if flagCarriers['Alliance'] then
        a:SetText(flagCarriers['Alliance'])
    else
        a:SetText('')
        ah:SetText('')
        fcHealth['Alliance'] = nil
    end
end

local function efcLowHealth()
    local playerFaction = UnitFactionGroup('player')
    local enemyFaction = (playerFaction == 'Alliance') and 'Horde' or 'Alliance'
    local now = GetTime()

    if flagCarriers[enemyFaction] and fcHealth[enemyFaction] then
        for i = 1, table.getn(healthWarnings) do
            local threshold = healthWarnings[i]
            if fcHealth[enemyFaction] < threshold then
                if (not sentAnnouncement or threshold < lowestWarning) and now > nextAnnouncement then
                    nextAnnouncement = now + announceInterval
                    lowestWarning = threshold
                    SendChatMessage('Enemy Flag Carrier (' .. flagCarriers[enemyFaction] .. ') has less than ' .. threshold .. '% Health! Get ready to cap!', 'BATTLEGROUND')
                    sentAnnouncement = true
                end
                return
            end
        end
    end
    sentAnnouncement = false
end

local function getPerc(unit)
    local curHP, maxHP
    local ok, res = pcall(UnitXP, "health", unit)
    if ok and type(res) == "number" then curHP = res else curHP = UnitHealth(unit) or 0 end
    local ok2, res2 = pcall(UnitXP, "maxhealth", unit)
    if ok2 and type(res2) == "number" then maxHP = res2 else maxHP = UnitHealthMax(unit) or 100 end
    if not maxHP or maxHP <= 0 then maxHP = 100 end
    return FosterFrames.Helpers.Round((curHP * 100) / maxHP, 1)
end

function WSGUIupdateFChealth(unit)
    if unit and UnitExists(unit) and UnitIsPlayer(unit) then
        local name = UnitName(unit)
        if name == flagCarriers['Horde'] then
            fcHealth['Horde'] = getPerc(unit)
            hh:SetText(fcHealth['Horde'] .. '%')
        elseif name == flagCarriers['Alliance'] then
            fcHealth['Alliance'] = getPerc(unit)
            ah:SetText(fcHealth['Alliance'] .. '%')
        end
    end

    if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['efcBGannouncement'] then
        efcLowHealth()
    end
end

function WSGUIinit(isBG)
    if isBG then
        local hdb = AlwaysUpFrame1DynamicIconButton
        if hdb then
            h:ClearAllPoints()
            h:SetPoint('LEFT', hdb, 'RIGHT', 4, 2)
            h:Show()
            hh:Show()
        end

        local adb = AlwaysUpFrame2DynamicIconButton
        if adb then
            a:ClearAllPoints()
            a:SetPoint('LEFT', adb, 'RIGHT', 4, 2)
            a:Show()
            ah:Show()
        end
    else
        h:Hide()
        hh:Hide()
        a:Hide()
        ah:Hide()
        table.wipe(flagCarriers)
        table.wipe(fcHealth)
    end
end