-- FosterFrames - Raid Target Keybindings Handler
-- Enhanced 1.12.1 Engine Stack (ClassicAPI, SuperWoW)

local enabled = false

-- Keybinding UI Globals
BINDING_HEADER_EFKHEADER = "FosterFrames Keybinds"
BINDING_NAME_SETSKULL    = "Assign Skull to Target"
BINDING_NAME_SETSTAR     = "Assign Star to Target"
BINDING_NAME_SETMOON     = "Assign Moon to Target"
BINDING_NAME_SETSQUARE   = "Assign Square to Target"
BINDING_NAME_SETDIAMOND  = "Assign Diamond to Target"
BINDING_NAME_SETCROSS    = "Assign Cross to Target"
BINDING_NAME_SETCIRCLE   = "Assign Circle to Target"
BINDING_NAME_SETTRIANGLE = "Assign Triangle to Target"

function setIconBind(icon)
    if enabled and icon then
        local tar = MOUSEOVERUNINAME or (UnitExists('target') and UnitName('target')) or nil
        if tar then
            FOSTERFRAMECORESendRaidTarget(icon, tar)
        end
    end
end

function bindingsInit()
    enabled = true
end

local f = CreateFrame('Frame')
f:RegisterEvent('PLAYER_ENTERING_WORLD')
f:RegisterEvent('ZONE_CHANGED_NEW_AREA')
f:SetScript('OnEvent', function()
    enabled = false
end)