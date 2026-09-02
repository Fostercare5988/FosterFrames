-- FosterFrames - Arathi Basin Assault Handler
-- Enhanced 1.12.1 Engine Stack (ClassicAPI / Event-Driven Zone Caching)

local playerFaction = UnitFactionGroup('player')
local isArathiBasin = false
local arathiBases = {
    ['Stables']     = true,
    ['Gold Mine']   = true,
    ['Blacksmith']  = true,
    ['Lumber Mill'] = true,
    ['Farm']        = true,
}
local lastABWarning = {}

local function warnArathiCap(baseName)
    local now = GetTime()
    if lastABWarning[baseName] and (now - lastABWarning[baseName]) < 1.5 then
        return
    end
    lastABWarning[baseName] = now

    local msg = 'Enemy is capping ' .. baseName .. '!'
    if RaidNotice_AddMessage and RaidWarningFrame then
        RaidNotice_AddMessage(RaidWarningFrame, msg, ChatTypeInfo['RAID_WARNING'])
    end
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage('|cffae7cee[FosterFrames]|r ' .. msg)
    end
end

local function handleChatMessage(msg)
    if not isArathiBasin or not msg then return end

    local assaultBase, assaultFaction = msg:match("The (.+) has been assaulted by the (.+)!")
    if assaultBase and assaultFaction and arathiBases[assaultBase] and assaultFaction ~= playerFaction then
        warnArathiCap(assaultBase)
    end
end

local f = CreateFrame('Frame')
f:RegisterEvent('PLAYER_ENTERING_WORLD')
f:RegisterEvent('ZONE_CHANGED_NEW_AREA')
f:RegisterEvent('CHAT_MSG_BG_SYSTEM_ALLIANCE')
f:RegisterEvent('CHAT_MSG_BG_SYSTEM_HORDE')

f:SetScript('OnEvent', function()
    local evt = event
    if evt == 'PLAYER_ENTERING_WORLD' or evt == 'ZONE_CHANGED_NEW_AREA' then
        playerFaction = UnitFactionGroup('player')
        isArathiBasin = (GetZoneText() == 'Arathi Basin')
        table.wipe(lastABWarning)
    else
        handleChatMessage(arg1)
    end
end)

