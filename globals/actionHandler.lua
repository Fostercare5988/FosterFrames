
-- FosterFrames - Action Handler
-- Enhanced 1.12.1 Engine Stack (SuperWoW Mouseover Integration)

local SPELLINFO_SINGLE_TARGET_BUFF_SPELLS = {
    ['Mark of the Wild'] = true,
    ['Thorns'] = true,
    ['Power Word: Fortitude'] = true,
    ['Divine Spirit'] = true,
    ['Shadow Protection'] = true,
    ['Power Word: Shield'] = true,
    ['Renew'] = true,
    ['Arcane Intellect'] = true,
    ['Arcane Brilliance'] = true,
    ['Dampen Magic'] = true,
    ['Amplify Magic'] = true,
    ['Blessing of Might'] = true,
    ['Blessing of Wisdom'] = true,
    ['Blessing of Kings'] = true,
    ['Blessing of Sanctuary'] = true,
    ['Blessing of Light'] = true,
    ['Blessing of Salvation'] = true,
    ['Blessing of Protection'] = true,
    ['Blessing of Freedom'] = true,
    ['Lay on Hands'] = true,
    ['Holy Light'] = true,
    ['Flash of Light'] = true,
    ['Cleanse'] = true,
    ['Purify'] = true,
}

local function castingChecks(spell)
    if not (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['mouseOver']) or not MOUSEOVERUNINAME then
        return false
    end
    if spell and SPELLINFO_SINGLE_TARGET_BUFF_SPELLS[spell] then
        return false
    end
    TargetByName(MOUSEOVERUNINAME, true)
    return true
end

local function reTarget(swapped, currentTarget)
    if swapped then
        if not currentTarget then
            ClearTarget()
        else
            TargetByName(currentTarget, true)
        end
    end
end

local UseAction_Original = UseAction
UseAction = function(slot, checkFlags, checkSelf)
    local currentTarget = UnitExists('target') and UnitName('target') or nil
    local swapped = castingChecks(nil)
    UseAction_Original(slot, checkFlags, checkSelf)
    reTarget(swapped, currentTarget)
end

local CastSpellByName_Original = CastSpellByName
CastSpellByName = function(spellName, onself)
    local currentTarget = UnitExists('target') and UnitName('target') or nil
    local swapped = castingChecks(spellName)
    CastSpellByName_Original(spellName, onself)
    reTarget(swapped, currentTarget)
end

