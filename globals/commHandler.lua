-- FosterFrames - Addon Communication Handler
-- Enhanced 1.12.1 Engine Stack (ClassicAPI / Zero GC Churn)

if not (CLASSIC_API_VERSION and SUPERWOW_VERSION) then return end

local msgPrefix = {
    ['EFC']  = 'BGEFEFC',
    ['SCAN'] = 'BGEFSCN',
}

local spottedUnitBuffer = {
    name   = nil,
    class  = nil,
    guid   = nil,
    nearby = true,
}

local efcBuffer = {
    Alliance = nil,
    Horde    = nil,
}

function sendMSG(typ, d, icon, bg)
    if not typ or not msgPrefix[typ] then return end
    if not icon or icon == '' then icon = ' ' end
    local payload = UnitName('player') .. '/' .. (d or ' ') .. '/' .. icon
    local channel = bg and 'BATTLEGROUND' or (UnitInRaid('player') and 'RAID' or 'PARTY')
    if not UnitInRaid('player') and GetNumPartyMembers() == 0 and not bg then return end
    SendAddonMessage(msgPrefix[typ], payload, channel)
end

local function handleScan(message)
    local sender, name, class, guid = message:match("([^/]+)/([^/]+)/([^/]+)/([^/]+)")
    if sender and sender ~= UnitName('player') and name and name ~= "" then
        spottedUnitBuffer.name   = name
        spottedUnitBuffer.class  = (class ~= ' ' and class) or nil
        spottedUnitBuffer.guid   = (guid ~= ' ' and guid) or nil
        spottedUnitBuffer.nearby = true
        FOSTERFRAMECOREAddSpottedUnit(spottedUnitBuffer)
    end
end

local function handleEFC(message)
    local sender, allianceEFC, hordeEFC = message:match("([^/]+)/([^/]+)/([^/]+)")
    if sender and sender ~= UnitName('player') then
        efcBuffer.Alliance = (allianceEFC ~= ' ' and allianceEFC) or nil
        efcBuffer.Horde    = (hordeEFC ~= ' ' and hordeEFC) or nil
        FOSTERFRAMECOREUpdateFlagCarriers(efcBuffer)
    end
end

local f = CreateFrame('Frame')
f:RegisterEvent('CHAT_MSG_ADDON')
f:SetScript('OnEvent', function()
    local prefix = arg1
    local message = arg2
    if not prefix or not message then return end

    if prefix == msgPrefix['EFC'] then
        handleEFC(message)
    elseif prefix == msgPrefix['SCAN'] then
        handleScan(message)
    end
end)