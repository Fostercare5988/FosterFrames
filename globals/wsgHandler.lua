-- FosterFrames - Warsong Gulch Flag Handler
-- Enhanced 1.12.1 Engine Stack (ClassicAPI / SuperWoW)

local flagCarriers = {}

function WSGHANDLERsetFlagCarriers(fc)
    flagCarriers = fc or {}
end

local function handleChatMessage(msg)
    if not msg then return end
    
    local flag, carrier = msg:match("The (%a+) (%a+) was picked up by (%a+)!")
    if flag and carrier then
        flagCarriers[flag] = carrier
        FOSTERFRAMECOREUpdateFlagCarriers(flagCarriers)
        return
    end

    local droppedFlag = msg:match("The (%a+) (%a+) was dropped")
    if droppedFlag then
        flagCarriers[droppedFlag] = nil
        FOSTERFRAMECOREUpdateFlagCarriers(flagCarriers)
        return
    end

    if msg:find("captured the") then
        table.wipe(flagCarriers)
        FOSTERFRAMECOREUpdateFlagCarriers(flagCarriers)
        return
    end
end

local function syncFlagCarriers()
    local a = flagCarriers['Alliance'] or ' '
    local h = flagCarriers['Horde'] or ' '
    if flagCarriers['Alliance'] or flagCarriers['Horde'] then
        sendMSG('EFC', a, h, true)
    end
end

local f = CreateFrame('Frame')
f:RegisterEvent('PLAYER_ENTERING_WORLD')
f:RegisterEvent('ZONE_CHANGED_NEW_AREA')
f:RegisterEvent('CHAT_MSG_BG_SYSTEM_ALLIANCE')
f:RegisterEvent('CHAT_MSG_BG_SYSTEM_HORDE')
f:RegisterEvent('RAID_ROSTER_UPDATE')

f:SetScript('OnEvent', function()
    local evt = event
    if evt == 'PLAYER_ENTERING_WORLD' or evt == 'ZONE_CHANGED_NEW_AREA' then
        table.wipe(flagCarriers)
    elseif evt == 'RAID_ROSTER_UPDATE' then
        syncFlagCarriers()
    else
        handleChatMessage(arg1)
    end
end)

SLASH_WSGHANDLER1 = '/wsg'
SlashCmdList["WSGHANDLER"] = function()
    DEFAULT_CHAT_FRAME:AddMessage("|cffae7cee[FosterFrames]|r Flag Carriers:")
    for k, v in pairs(flagCarriers) do
        DEFAULT_CHAT_FRAME:AddMessage("  " .. k .. ": " .. v)
    end
end