-- FosterFrames - Unified Class & Aura Tracker
-- Enhanced 1.12.1 Engine Stack (ClassicAPI / SuperWoW)

local CLASS_SPECIAL_BUFFS = {
    ['PALADIN'] = {
        ['Seal of Righteousness'] = true,
        ['Seal of the Crusader']  = true,
        ['Seal of Justice']       = true,
        ['Seal of Light']         = true,
        ['Seal of Wisdom']        = true,
        ['Seal of Command']       = true,
        ['Seal of Fury']          = true,
    },
    ['SHAMAN'] = {
        ['Water Shield']     = true,
        ['Lightning Shield'] = true,
        ['Earth Shield']     = true,
    },
}

local CLASS_SPECIAL_DEBUFFS = {
    ['ROGUE'] = {
        ['Rupture'] = true,
        ['Garrote'] = true,
    },
}

function FOSTERFRAMESUpdateClassSpecialAuras(player, unit)
    if not player or not unit or not UnitExists(unit) then return end
    local class = player.class
    if not class then return end

    if CLASS_SPECIAL_BUFFS[class] then
        local found = nil
        for i = 1, 40 do
            local name = UnitBuff(unit, i)
            if not name then break end
            if CLASS_SPECIAL_BUFFS[class][name] then
                found = name
                break
            end
        end
        player.activeSpecialBuff = found
    end

    if CLASS_SPECIAL_DEBUFFS[class] then
        local found = nil
        for i = 1, 40 do
            local name = UnitDebuff(unit, i)
            if not name then break end
            if CLASS_SPECIAL_DEBUFFS[class][name] then
                found = name
                break
            end
        end
        player.activeSpecialDebuff = found
    end
end
