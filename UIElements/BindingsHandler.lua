-- FosterFrames - Tactical Keybindings Handler
-- Enhanced 1.12.1 Engine Stack (ClassicAPI, SuperWoW)

BINDING_HEADER_FOSTERFRAMES = "FosterFrames Tactical Markers"
BINDING_NAME_SETSKULL       = "Set Skull Marker"
BINDING_NAME_SETCROSS       = "Set Cross Marker"
BINDING_NAME_SETSQUARE      = "Set Square Marker"
BINDING_NAME_SETMOON        = "Set Moon Marker"
BINDING_NAME_SETTRIANGLE    = "Set Triangle Marker"
BINDING_NAME_SETDIAMOND     = "Set Diamond Marker"
BINDING_NAME_SETCIRCLE      = "Set Circle Marker"
BINDING_NAME_SETSTAR        = "Set Star Marker"

local RAID_ICON_LOOKUP = {
    star     = 1,
    circle   = 2,
    diamond  = 3,
    triangle = 4,
    moon     = 5,
    square   = 6,
    cross    = 7,
    skull    = 8,
}

function setIconBind(iconName)
    if not UnitExists("target") then return end
    local id = RAID_ICON_LOOKUP[string.lower(iconName or "")]
    if id then
        local current = GetRaidTargetIndex("target")
        SetRaidTargetIcon("target", (current == id) and 0 or id)
    end
end