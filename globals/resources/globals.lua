-- FosterFrames - Global Constants, Palettes, and Utilities
-- Enhanced 1.12.1 Engine Stack (ClassicAPI, SuperWoW, NamPower, UnitXP SP3, DXVK)

FosterFrames = FosterFrames or {}
FosterFrames.Config = FosterFrames.Config or {}
FosterFrames.Helpers = FosterFrames.Helpers or {}

-- Shared Helper Functions
function FosterFrames.Helpers.Round(num, idp)
    if not num then return 0 end
    local mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function FosterFrames.Helpers.GetTimerLeft(tEnd, limit)
    if not tEnd then return "" end
    local t = tEnd - GetTime()
    if t <= 0 then return "" end
    limit = limit or 3
    if t > limit then
        return FosterFrames.Helpers.Round(t, 0)
    else
        return FosterFrames.Helpers.Round(t, 1)
    end
end

function FosterFrames.Helpers.GetDistanceColor(dist)
    if not dist then return 0.5, 0.5, 0.5, "|cFF808080" end
    if dist <= 30 then
        return 0.0, 1.0, 0.0, "|cFF00FF00" -- Neon Green
    elseif dist <= 50 then
        return 1.0, 1.0, 0.0, "|cFFFFFF00" -- Yellow
    elseif dist <= 80 then
        return 1.0, 0.5, 0.0, "|cFFFF8000" -- Orange
    else
        return 1.0, 0.25, 0.25, "|cFFFF4040" -- Red
    end
end

-- Global Color & Texture Tables
if not RAID_CLASS_COLORS then
    RAID_CLASS_COLORS = {
        ['DRUID']   = { r = 1.00, g = 0.49, b = 0.04 },
        ['HUNTER']  = { r = 0.67, g = 0.83, b = 0.45 },
        ['MAGE']    = { r = 0.41, g = 0.80, b = 0.94 },
        ['PALADIN'] = { r = 0.96, g = 0.55, b = 0.73 },
        ['PRIEST']  = { r = 1.00, g = 1.00, b = 1.00 },
        ['ROGUE']   = { r = 1.00, g = 0.96, b = 0.41 },
        ['SHAMAN']  = { r = 0.96, g = 0.55, b = 0.73 },
        ['WARLOCK'] = { r = 0.58, g = 0.51, b = 0.79 },
        ['WARRIOR'] = { r = 0.78, g = 0.61, b = 0.43 },
    }
end

if not HEX_CLASS_COLORS then
    HEX_CLASS_COLORS = {
        ['DRUID']   = 'ff7d0a',
        ['HUNTER']  = 'abd473',
        ['MAGE']    = '69ccf0',
        ['PALADIN'] = 'f58cba',
        ['PRIEST']  = 'ffffff',
        ['ROGUE']   = 'fff569',
        ['SHAMAN']  = 'f58cba',
        ['WARLOCK'] = '9482c9',
        ['WARRIOR'] = 'c79c6e',
    }
end

if not RGB_SPELL_SCHOOL_COLORS then
    RGB_SPELL_SCHOOL_COLORS = {
        ['physical'] = { 0.9, 0.9, 0.0 },
        ['arcane']   = { 0.9, 0.4, 0.9 },
        ['fire']     = { 0.9, 0.4, 0.0 },
        ['nature']   = { 0.3, 0.9, 0.2 },
        ['frost']    = { 0.4, 0.9, 0.9 },
        ['shadow']   = { 0.4, 0.4, 0.9 },
        ['holy']     = { 0.9, 0.4, 0.9 },
    }
end

if not RGB_FACTION_COLORS then
    RGB_FACTION_COLORS = {
        ['Alliance'] = { ['r'] = 0.0, ['g'] = 0.68, ['b'] = 0.94 },
        ['Horde']    = { ['r'] = 1.0, ['g'] = 0.10, ['b'] = 0.10 },
    }
end

if not RGB_POWER_COLORS then
    RGB_POWER_COLORS = {
        ['energy'] = { 1.0, 1.0, 0.0 },
        ['focus']  = { 1.0, 0.5, 0.25 },
        ['mana']   = { 0.0, 0.0, 1.0 },
        ['rage']   = { 1.0, 0.0, 0.0 },
    }
end

if not RGB_BORDER_DEBUFFS_COLOR then
    RGB_BORDER_DEBUFFS_COLOR = {
        ['curse']    = { 0.6, 0.0, 1.0 },
        ['disease']  = { 0.6, 0.4, 0.0 },
        ['magic']    = { 0.2, 0.6, 1.0 },
        ['physical'] = { 0.8, 0.0, 0.0 },
        ['poison']   = { 0.0, 0.6, 0.0 },
    }
end

local iconFolders = {
    ['class'] = [[Interface\AddOns\FosterFrames\globals\resources\ClassIcons\ClassIcon_]],
}

function GET_DEFAULT_ICON(op, value)
    local dir = iconFolders[op]
    if not value or not dir then return "" end
    return dir .. value
end


if not SPELLINFO_WSG_FLAGS then
    SPELLINFO_WSG_FLAGS = {
        ['Alliance'] = { ['icon'] = [[Interface\Icons\inv_bannervp_02]] },
        ['Horde']    = { ['icon'] = [[Interface\Icons\inv_bannerpvp_01]] },
    }
end
