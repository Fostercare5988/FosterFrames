
-- FosterFrames - Spell Casting & Aura Core
-- Enhanced 1.12.1 Engine Stack (ClassicAPI / SuperWoW Native Cast & Aura Queries)

if not (CLASSIC_API_VERSION and SUPERWOW_VERSION) then
    return
end

local castInfoCache = {}
local borderClrInterrupt = { 0.1, 0.1, 0.1 }
local borderClrUninterrupt = { 0.3, 0.3, 0.3 }

local function fillCastInfo(caster, spellName, icon, startTime, endTime, isChannel, interrupt)
    local info = castInfoCache[caster]
    if not info then
        info = {}
        castInfoCache[caster] = info
    end
    info.caster    = caster
    info.spell     = spellName
    info.icon      = icon
    info.timeStart = (startTime or 0) / 1000
    info.timeEnd   = (endTime or 0) / 1000
    info.inverse   = isChannel
    info.borderClr = (interrupt == false) and borderClrUninterrupt or borderClrInterrupt
    return info
end

function SPELLCASTINGCOREgetCast(caster, unit)
    if not caster or not unit or not UnitExists(unit) then return nil end

    if UnitCastingInfo then
        local ok, name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = pcall(UnitCastingInfo, unit)
        if ok and name and endTime and endTime > 0 then
            return fillCastInfo(caster, name, texture, startTime, endTime, false, notInterruptible)
        end
    end

    if UnitChannelInfo then
        local ok, name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = pcall(UnitChannelInfo, unit)
        if ok and name and endTime and endTime > 0 then
            return fillCastInfo(caster, name, texture, startTime, endTime, true, notInterruptible)
        end
    end

    return nil
end

local auraListBuffer = {}
local auraEntryPool = {}

local function getAuraEntry(idx)
    local entry = auraEntryPool[idx]
    if not entry then
        entry = {}
        auraEntryPool[idx] = entry
    end
    return entry
end

function SPELLCASTINGCOREgetBuffs(name, unit)
    if not unit or not UnitExists(unit) then return nil end
    table.wipe(auraListBuffer)
    local count = 0

    if C_UnitAuras and C_UnitAuras.GetAuraSlots and C_UnitAuras.GetAuraDataBySlot then
        local helpfulSlots = C_UnitAuras.GetAuraSlots(unit, "HELPFUL")
        if helpfulSlots then
            local n = #helpfulSlots
            for i = 1, n do
                local aura = C_UnitAuras.GetAuraDataBySlot(unit, helpfulSlots[i])
                if aura then
                    count = count + 1
                    local entry = getAuraEntry(count)
                    entry.spell = aura.name
                    entry.icon = aura.icon
                    entry.stacks = aura.applications or 1
                    entry.timeEnd = aura.expirationTime
                    entry.duration = aura.duration
                    entry.type = 'buff'
                    auraListBuffer[count] = entry
                end
            end
        end

        local harmfulSlots = C_UnitAuras.GetAuraSlots(unit, "HARMFUL")
        if harmfulSlots then
            local n = #harmfulSlots
            for i = 1, n do
                local aura = C_UnitAuras.GetAuraDataBySlot(unit, harmfulSlots[i])
                if aura then
                    count = count + 1
                    local entry = getAuraEntry(count)
                    entry.spell = aura.name
                    entry.icon = aura.icon
                    entry.stacks = aura.applications or 1
                    entry.timeEnd = aura.expirationTime
                    entry.duration = aura.duration
                    entry.type = aura.dispelName or 'none'
                    auraListBuffer[count] = entry
                end
            end
        end
    elseif C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        for i = 1, 40 do
            local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, "HELPFUL")
            if not aura then break end
            count = count + 1
            local entry = getAuraEntry(count)
            entry.spell = aura.name
            entry.icon = aura.icon
            entry.stacks = aura.applications or 1
            entry.timeEnd = aura.expirationTime
            entry.duration = aura.duration
            entry.type = 'buff'
            auraListBuffer[count] = entry
        end

        for i = 1, 40 do
            local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, "HARMFUL")
            if not aura then break end
            count = count + 1
            local entry = getAuraEntry(count)
            entry.spell = aura.name
            entry.icon = aura.icon
            entry.stacks = aura.applications or 1
            entry.timeEnd = aura.expirationTime
            entry.duration = aura.duration
            entry.type = aura.dispelName or 'none'
            auraListBuffer[count] = entry
        end
    end

    table.setn(auraListBuffer, count)
    return auraListBuffer
end

