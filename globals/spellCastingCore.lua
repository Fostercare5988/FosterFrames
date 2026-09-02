
-- FosterFrames - Spell Casting & Aura Core
-- Enhanced 1.12.1 Engine Stack (ClassicAPI / SuperWoW Native Cast & Aura Queries)

local function convertCastInfo(caster, spellName, icon, startTime, endTime, isChannel, interrupt)
    return {
        caster    = caster,
        spell     = spellName,
        icon      = icon,
        timeStart = startTime / 1000,
        timeEnd   = endTime / 1000,
        inverse   = isChannel,
        borderClr = (interrupt == false) and { 0.3, 0.3, 0.3 } or { 0.1, 0.1, 0.1 },
    }
end

function SPELLCASTINGCOREgetCast(caster, unit)
    if not caster then return nil end
    if not unit or not UnitExists(unit) then return nil end

    if UnitCastingInfo then
        local ok, spell, rank, displayName, icon, startTime, endTime, isTradeSkill, castID, notInterruptible = pcall(UnitCastingInfo, unit)
        if ok and spell and endTime and endTime > 0 then
            return convertCastInfo(caster, spell, icon, startTime, endTime, false, notInterruptible)
        end
    end

    if UnitChannelInfo then
        local ok, spell, rank, displayName, icon, startTime, endTime, isTradeSkill, notInterruptible = pcall(UnitChannelInfo, unit)
        if ok and spell and endTime and endTime > 0 then
            return convertCastInfo(caster, spell, icon, startTime, endTime, true, notInterruptible)
        end
    end

    return nil
end

function SPELLCASTINGCOREgetBuffs(name, unit)
    if not unit or not UnitExists(unit) then return nil end
    local list = {}

    for i = 1, 40 do
        local bName, bRank, bIcon, bCount, bDebuffType, bDuration, bExpirationTime = UnitBuff(unit, i)
        if not bName then break end
        table.insert(list, {
            spell    = bName,
            icon     = bIcon,
            stacks   = bCount or 1,
            timeEnd  = bExpirationTime,
            duration = bDuration,
            type     = 'buff',
        })
    end

    for i = 1, 40 do
        local dName, dRank, dIcon, dCount, dDebuffType, dDuration, dExpirationTime = UnitDebuff(unit, i)
        if not dName then break end
        table.insert(list, {
            spell    = dName,
            icon     = dIcon,
            stacks   = dCount or 1,
            timeEnd  = dExpirationTime,
            duration = dDuration,
            type     = dDebuffType or 'none',
        })
    end

    return list
end

