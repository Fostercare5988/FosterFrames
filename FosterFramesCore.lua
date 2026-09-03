-- FosterFrames - Core Logic Engine
-- Enhanced 1.12.1 Engine Stack (ClassicAPI, SuperWoW, NamPower, UnitXP SP3, DXVK)

-- Mandatory Engine Dependency Guard
if not (CLASSIC_API_VERSION and SUPERWOW_VERSION) then
    DEFAULT_CHAT_FRAME:AddMessage("|cffff2020[Fatal Error]|r FosterFrames requires ClassicAPI.dll & SuperWoW! Please ensure ClassicAPI.dll and SuperWoW are loaded.", 1, 0.2, 0.2)
    return
end

local playerFaction
local insideBG = false
local currentZone = ""

local bgs = {
    ['Warsong Gulch']    = 10,
    ['Arathi Basin']     = 15,
    ['Blood Ring']       = 10,
    ['Lordaeron Arena']  = 10,
    ['Sunstrider Court'] = 10,
    ['Thorn Gorge']      = 15,
    ['Alterac Valley']   = 40,
}

-- Static Pre-Allocated Unit Tables (Zero GC Churn)
local RAID_UNITS, RAID_TARGET_UNITS = {}, {}
local PARTY_UNITS, PARTY_TARGET_UNITS = {}, {}
for i = 1, 40 do
    RAID_UNITS[i] = "raid" .. i
    RAID_TARGET_UNITS[i] = "raid" .. i .. "target"
end
for i = 1, 4 do
    PARTY_UNITS[i] = "party" .. i
    PARTY_TARGET_UNITS[i] = "party" .. i .. "target"
end

-- State Tables
local playerList = {}
local prioMembers = {}
local cachedRaidTargets = {}
local currentFlagCarriers = {}
local trinketTimers = {}
local activeCC = nil

-- Timers & Intervals
local playerListInterval = 30
local playerListRefresh = 0
local enemyNearbyInterval = 0.25
local enemyNearbyRefresh = 0
local globalNearbyCheckTimer = 8
local globalNearbyCheckNext = 0
local nextPlayerCheck = 6
local playerOutdoorLastseen = 60
local raidMemberIndex = 1
local maxUnitsDisplayed = 40
local refreshUnits = true

local f = CreateFrame('Frame', 'fosterFramesCore', UIParent)

-- Helper: Query exact distance via UnitXP SP3 or SuperWoW UnitPosition 3D
local function getExactDistance(unit)
    if not unit or unit == "" then return nil end

    -- 1. UnitXP SP3 Native C++ Euclidean Distance
    if UnitXP then
        local ok, dist = pcall(UnitXP, "distance", unit)
        if ok and type(dist) == "number" and dist >= 0 and dist < 9999 then
            return math.floor(dist + 0.5)
        end
    end

    -- 2. SuperWoW 3D World Space Euclidean Distance (UnitPosition)
    if UnitPosition then
        local okP, px, py, pz = pcall(UnitPosition, "player")
        local okU, ux, uy, uz = pcall(UnitPosition, unit)
        if okP and okU and px and py and ux and uy and type(px) == "number" and type(ux) == "number" then
            local dx = px - ux
            local dy = py - uy
            local dz = (pz and uz and type(pz) == "number" and type(uz) == "number") and (pz - uz) or 0
            local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
            if dist >= 0 and dist < 9999 then
                return math.floor(dist + 0.5)
            end
        end
    end

    return nil
end

-- Helper: Query exact health via UnitXP SP3 or UnitHealth
local function getExactHealth(unit)
    local ok, h, mh
    if UnitXP then
        ok, h = pcall(UnitXP, "health", unit)
        if not (ok and type(h) == "number") then h = UnitHealth(unit) or 100 end
        ok, mh = pcall(UnitXP, "maxhealth", unit)
        if not (ok and type(mh) == "number") then mh = UnitHealthMax(unit) or 100 end
    else
        h = UnitHealth(unit) or 100
        mh = UnitHealthMax(unit) or 100
    end
    return h, mh
end

-- Helper: Trigger Spy Alerts for new hostile players
local function triggerSpyAlerts(name, class)
    if not FOSTERFRAMESPLAYERDATA or not FOSTERFRAMESPLAYERDATA['openWorldScanning'] then return end
    if insideBG then return end
    if not name or name == "" or name == "Unknown" then return end

    if FOSTERFRAMESPLAYERDATA['spySoundAlert'] then
        PlaySound("RaidWarning")
    end

    if FOSTERFRAMESPLAYERDATA['spyFlashTaskbar'] then
        if FlashClientIcon then
            FlashClientIcon()
        else
            pcall(UnitXP, "notify", "taskbarIcon")
        end
    end

    local clr = RAID_CLASS_COLORS[class] or { r = 1, g = 0.2, b = 0.2 }
    DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffae7cee[Spy]|r Hostile detected: |cff%02x%02x%02x%s|r (%s)", clr.r * 255, clr.g * 255, clr.b * 255, name, class or "Unknown"))

    if FOSTERFRAMESPLAYERDATA['spyAnnounceNearby'] then
        local msg = "[FosterFrames Spy] Hostile nearby: " .. name .. " (" .. (class or "Unknown") .. ")"
        if GetNumRaidMembers() > 0 then
            SendChatMessage(msg, "RAID")
        elseif GetNumPartyMembers() > 0 then
            SendChatMessage(msg, "PARTY")
        end
    end
end

-- Apply / update hostile nearby player without table churn
local function updatePlayerData(p, class, h, mh, mana, maxmana, powerType, guid, now, nextCheck)
    if h then p.health = h end
    if mh then p.maxhealth = mh end
    if mana then p.mana = mana end
    if maxmana then p.maxmana = maxmana end
    if guid then p.guid = guid end
    if class then p.class = class end

    if powerType then
        p.powerType = powerType
    elseif not p.powerType then
        p.powerType = (p.class == 'WARRIOR' and 'rage') or (p.class == 'ROGUE' and 'energy') or 'mana'
    end

    if now > enemyNearbyRefresh then
        p.targetcount = (p.targetcount or 0) + 1
    end

    p.nextCheck = nextCheck
    p.nearby = true
end

local function applyNearbyPlayer(v, now, nextCheck)
    local id = v.name
    if not id or id == "" or id:sub(1, 7) == "Unknown" then
        return
    end

    -- If another entry exists with the exact same GUID, remove it
    if v.guid and v.guid ~= "" then
        for oldId, oldPlayer in pairs(playerList) do
            if oldId ~= id and oldPlayer.guid == v.guid then
                playerList[oldId] = nil
            end
        end
    end

    local p = playerList[id]
    if not p then
        p = {
            name      = id,
            class     = v.class or 'WARRIOR',
            guid      = v.guid or id,
            nearby    = true,
            maxhealth = v.maxhealth or 100,
        }
        playerList[id] = p
        refreshUnits = true
        if not insideBG then
            triggerSpyAlerts(id, v.class)
        end
    end

    updatePlayerData(p, v.class, v.health, v.maxhealth, v.mana, v.maxmana, v.powerType, v.guid, now, nextCheck)
end

local function updateUnitDistance(p, unit)
    if not p or not unit then return end
    local dist = getExactDistance(unit)
    if dist then
        p.distance = dist
    end
end

local function verifyUnitInfo(unit, now)
    now = now or GetTime()
    if UnitExists(unit) and UnitIsPlayer(unit) and UnitFactionGroup(unit) ~= playerFaction then
        local name = UnitName(unit)
        if not name or name == "" or name:sub(1, 7) == "Unknown" then return false end

        local _, class = UnitClass(unit)
        local h, mh = getExactHealth(unit)
        local power = UnitPowerType(unit)
        local powerType = (power == 3 and 'energy') or (power == 1 and 'rage') or 'mana'
        local guid = UnitGUID(unit) or name
        local nextCheck = now + nextPlayerCheck

        local p = playerList[name]
        if not p then
            p = {
                name      = name,
                class     = class or 'WARRIOR',
                guid      = guid,
                nearby    = true,
                maxhealth = mh or 100,
            }
            playerList[name] = p
            refreshUnits = true
            if not insideBG then
                triggerSpyAlerts(name, class)
            end
        end

        updatePlayerData(p, class, h, mh, UnitMana(unit), UnitManaMax(unit), powerType, guid, now, nextCheck)
        updateUnitDistance(p, unit)

        if p.fc and WSGUIupdateFChealth then
            WSGUIupdateFChealth(unit)
        end
        return true
    end
    return false
end

local function broadcastSpottedEnemy(name, class, guid)
    if not (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['openWorldScanning']) then return end
    if not UnitInRaid('player') and GetNumPartyMembers() == 0 and not insideBG then return end

    local d = name .. '/' .. (class or ' ') .. '/' .. (guid or ' ')
    sendMSG('SCAN', d, nil, insideBG)
end

local function processCombatUnit(guid, name, flags, now, nextCheck)
    if not guid or guid == "" or not name or name == "" or name:sub(1, 7) == "Unknown" then return end
    local isEnemy = bit.band(flags or 0, 64) ~= 0

    local isPlayer = bit.band(flags or 0, 1024) ~= 0

    if isPlayer and isEnemy then
        local p = playerList[name]
        local isNew = (p == nil)
        if isNew then
            p = {
                name      = name,
                guid      = guid,
                class     = 'WARRIOR',
                nearby    = true,
                maxhealth = 100,
                nextCheck = nextCheck,
            }
            playerList[name] = p
            refreshUnits = true
            if not insideBG then
                triggerSpyAlerts(name, nil)
            end
            broadcastSpottedEnemy(name, nil, guid)
        else
            p.guid = guid
            p.nearby = true
            p.nextCheck = nextCheck
        end
    end
end

local function scanCombatLog(now)
    if not (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['openWorldScanning']) then return end
    if not arg1 then return end

    local _, event, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags = arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10

    local nextCheck = now + nextPlayerCheck
    processCombatUnit(sourceGUID, sourceName, sourceFlags, now, nextCheck)
    processCombatUnit(destGUID, destName, destFlags, now, nextCheck)

    -- Stealth Action Watcher
    if FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['spyStealthAlert'] and not insideBG then
        if event == "SPELL_AURA_APPLIED" or event == "SPELL_CAST_SUCCESS" then
            local spellName = arg13
            if spellName == "Stealth" or spellName == "Prowl" or spellName == "Vanish" or spellName == "Shadowmeld" then
                local isEnemy = bit.band(sourceFlags or 0, 64) ~= 0
                if isEnemy then
                    DEFAULT_CHAT_FRAME:AddMessage("|cffff2020[Spy Stealth Alert]|r Hostile " .. (sourceName or "Enemy") .. " used " .. spellName .. "!")
                    if FOSTERFRAMESPLAYERDATA['spySoundAlert'] then
                        PlaySound("RaidWarning")
                    end
                end
            end
        end
    end

    -- Trinket cooldown detection
    if event == "SPELL_CAST_SUCCESS" then
        local spellName = arg13
        if spellName == "Insignia of the Horde" or spellName == "Insignia of the Alliance" or spellName == "Champion's Insignia" then
            if sourceGUID and sourceGUID ~= "" then
                trinketTimers[sourceGUID] = {
                    start = now,
                    ['end'] = now + 180,
                    icon = [[Interface\Icons\inv_jewelry_trinketpvp_01]],
                }
            end
        end
    end
end

function FOSTERFRAMECOREGetTrinketCooldown(guid)
    if guid and trinketTimers[guid] then
        local t = trinketTimers[guid]
        if GetTime() < t['end'] then
            return t
        else
            trinketTimers[guid] = nil
        end
    end
    return nil
end

local function checkPrioMembers(now)
    for k, v in pairs(prioMembers) do
        if not verifyUnitInfo(v, now) then
            prioMembers[k] = nil
        end
    end
end

local function cacheRaidTargets()
    table.wipe(cachedRaidTargets)
    local isRaid = UnitInRaid('player')
    local numMembers = isRaid and GetNumRaidMembers() or GetNumPartyMembers()
    if numMembers == 0 then return end

    local unitsTable = isRaid and RAID_TARGET_UNITS or PARTY_TARGET_UNITS
    for i = 1, numMembers do
        local rTarget = unitsTable[i]
        if rTarget and UnitExists(rTarget) then
            local name = UnitName(rTarget)
            if name then
                cachedRaidTargets[name] = rTarget
            end
        end
    end
end

local function getRaidMembersTarget(now)
    local isRaid = UnitInRaid('player')
    local numMembers = isRaid and GetNumRaidMembers() or GetNumPartyMembers()
    if numMembers == 0 then return end

    local unitsTable = isRaid and RAID_TARGET_UNITS or PARTY_TARGET_UNITS
    local targetUnit = unitsTable[raidMemberIndex]
    if targetUnit and verifyUnitInfo(targetUnit, now) then
        prioMembers[raidMemberIndex] = targetUnit
    end

    raidMemberIndex = (raidMemberIndex < numMembers) and (raidMemberIndex + 1) or 1
end

local function updatePlayerListInfo(now)
    now = now or GetTime()
    local nextCheck = now + nextPlayerCheck

    for k, v in pairs(playerList) do
        local unitID = (UnitExists('target') and v.guid == UnitGUID('target') and 'target')
            or (UnitExists('mouseover') and v.guid == UnitGUID('mouseover') and 'mouseover')
            or cachedRaidTargets[v.name]
            or nil

        -- Exact distance query via unitID, name, or guid (UnitXP SP3)
        local dist = (unitID and getExactDistance(unitID)) or getExactDistance(v.name) or (v.guid and getExactDistance(v.guid))
        if dist then
            v.distance = dist
            local isNearby = (dist <= 80)
            if v.nearby ~= isNearby then
                v.nearby = isNearby
                refreshUnits = true
            end
            v.nextCheck = nextCheck
        else
            v.distance = 999
        end

        v.castinfo = SPELLCASTINGCOREgetCast(v.name, unitID)
        local buffList = SPELLCASTINGCOREgetBuffs(v.name, unitID)

        if v.castinfo or (buffList and table.getn(buffList) > 0) then
            v.nextCheck = nextCheck
            if v.nearby == false then
                v.health = v.maxhealth or 100
                v.mana = v.maxmana or 100
                refreshUnits = true
            end
            v.nearby = true
        end

        if not insideBG and not v.nearby and v.lastSeen and now > v.lastSeen then
            playerList[k] = nil
            refreshUnits = true
        end
    end
end

local function calculateEFCDistance(now)
    if not (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['efcDistanceTracking']) then return end

    local enemyFaction = (playerFaction == 'Alliance') and 'Horde' or 'Alliance'
    local efcName = currentFlagCarriers[enemyFaction]
    if not efcName or efcName == " " then return end

    local efcUnit = nil
    if UnitExists('target') and UnitName('target') == efcName then
        efcUnit = 'target'
    elseif UnitExists('mouseover') and UnitName('mouseover') == efcName then
        efcUnit = 'mouseover'
    else
        for i = 1, 40 do
            local rTarget = RAID_TARGET_UNITS[i]
            if UnitExists(rTarget) and UnitName(rTarget) == efcName then
                efcUnit = rTarget
                break
            end
        end
    end

    if efcUnit then
        local dist = getExactDistance(efcUnit)
        local distanceStr = dist and ("< " .. dist .. "yd") or "unknown"
        if playerList[efcName] then
            playerList[efcName].efcDistance = distanceStr
            playerList[efcName].distance = dist or playerList[efcName].distance
        end
    end
end

local function globalNearbyMaintenance(now)
    now = now or GetTime()
    local nextSeen = now + playerOutdoorLastseen
    for k, v in pairs(playerList) do
        if v.nextCheck and v.nearby and now > v.nextCheck then
            refreshUnits = true
            v.nearby = false
            v.health = v.maxhealth or 100
            v.mana = (v.class == 'WARRIOR' and 0) or v.maxmana or 100
            if not insideBG then v.lastSeen = nextSeen end
        end
    end
end

local CLASS_STABLE_SORT_ORDER = {
    ['DRUID']   = 1,
    ['HUNTER']  = 2,
    ['MAGE']    = 3,
    ['PALADIN'] = 4,
    ['PRIEST']  = 5,
    ['ROGUE']   = 6,
    ['SHAMAN']  = 7,
    ['WARLOCK'] = 8,
    ['WARRIOR'] = 9,
}

local sortBuffer = {}
local outputBuffer = {}

local function stableSortComparator(a, b)
    local aOrder = CLASS_STABLE_SORT_ORDER[a.class] or 10
    local bOrder = CLASS_STABLE_SORT_ORDER[b.class] or 10
    if aOrder ~= bOrder then
        return aOrder < bOrder
    end
    return (a.name or '') < (b.name or '')
end

local function orderUnitsforOutput()
    table.wipe(sortBuffer)
    local count = 0
    for _, v in pairs(playerList) do
        if v.name and v.name ~= "" and v.name:sub(1, 7) ~= "Unknown" then
            count = count + 1
            sortBuffer[count] = v
        end
    end
    table.setn(sortBuffer, count)

    table.sort(sortBuffer, stableSortComparator)

    table.wipe(outputBuffer)
    local displayCount = math.min(count, maxUnitsDisplayed)
    for i = 1, displayCount do
        outputBuffer[i] = sortBuffer[i]
    end
    table.setn(outputBuffer, displayCount)
    return outputBuffer
end


local function resetTargetCount()
    for _, v in pairs(playerList) do
        v.targetcount = 0
    end
end

local function getPlayerGUIDByName(name)
    for guid, p in pairs(playerList) do
        if p.name == name then return guid end
    end
    return nil
end

--- Global Access APIs ---

function FOSTERFRAMECOREgetPlayer(nameOrGuid)
    return playerList[nameOrGuid] or playerList[getPlayerGUIDByName(nameOrGuid)]
end

function FOSTERFRAMECOREgetPlayerList()
    return playerList
end

function FOSTERFRAMECOREGetEFCDistance()
    local enemyFaction = (playerFaction == 'Alliance') and 'Horde' or 'Alliance'
    local efcName = currentFlagCarriers[enemyFaction]
    if not efcName or efcName == " " then return nil end

    if playerList[efcName] and playerList[efcName].efcDistance then
        return efcName, playerList[efcName].efcDistance
    end
    return efcName, 'unknown'
end

function FOSTERFRAMECOREAddSpottedUnit(u)
    if not (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['openWorldScanning']) then return end
    if not u or not u.name or u.name == "" or u.name:sub(1, 7) == "Unknown" then return end
    local id = u.guid or u.name

    local isNew = (playerList[id] == nil)

    u.nearby = true
    applyNearbyPlayer(u, GetTime(), GetTime() + nextPlayerCheck)

    local p = playerList[id]
    if isNew and p and p.class then
        broadcastSpottedEnemy(p.name, p.class, p.guid)
    end
end


function FOSTERFRAMECOREUpdateFlagCarriers(fc)
    currentFlagCarriers = fc or {}
    for _, v in pairs(playerList) do
        local oldFC = v.fc
        if not fc[playerFaction] then
            v.fc = false
        else
            v.fc = (v.name == fc[playerFaction])
        end
        v.refresh = (oldFC ~= v.fc)
    end

    refreshUnits = true
    if TARGETFRAMEsetFC then TARGETFRAMEsetFC(fc) end
    if WSGUIupdateFC then WSGUIupdateFC(fc) end
    if WSGHANDLERsetFlagCarriers then WSGHANDLERsetFlagCarriers(fc) end
end

function FOSTERFRAMECORESetPlayersData(list)
    local nextCheck = GetTime() + nextPlayerCheck
    for k, v in pairs(list) do
        if playerList[k] then
            playerList[k].health = v.health
            playerList[k].maxhealth = v.maxhealth
            playerList[k].nextCheck = nextCheck
            playerList[k].nearby = true
            refreshUnits = true
        end
    end
end

function FOSTERFRAMECOREIsInsideBG()
    return insideBG
end

local function fosterFramesCoreOnUpdate()
    local now = GetTime()

    if insideBG and now > playerListRefresh then
        RequestBattlefieldScoreData()
        playerListRefresh = now + playerListInterval
    end

    verifyUnitInfo('target', now)
    verifyUnitInfo('mouseover', now)

    if now > enemyNearbyRefresh then
        resetTargetCount()
        cacheRaidTargets()
        getRaidMembersTarget(now)
        checkPrioMembers(now)
        enemyNearbyRefresh = now + enemyNearbyInterval
        refreshUnits = true
    end

    updatePlayerListInfo(now)

    if insideBG and currentZone == 'Warsong Gulch' then
        calculateEFCDistance(now)
    end

    if now > globalNearbyCheckNext then
        globalNearbyMaintenance(now)
        globalNearbyCheckNext = now + globalNearbyCheckTimer
    end

    if FOSTERFRAMESPLAYERDATA then
        if refreshUnits then
            refreshUnits = false
            FOSTERFRAMESUpdatePlayers(orderUnitsforOutput())
        end

        if fosterFrameDisplay then
            if FOSTERFRAMES_DEBUG or (fosterFramesSettings and fosterFramesSettings:IsShown()) then
                fosterFrameDisplay:Show()
            elseif FOSTERFRAMESPLAYERDATA['enableFrames'] then
                if insideBG and next(playerList) == nil then
                    fosterFrameDisplay:Hide()
                else
                    fosterFrameDisplay:Show()
                end
            else
                fosterFrameDisplay:Hide()
            end
        end
    end
end

local function initializeValues()
    playerFaction = UnitFactionGroup('player')
    currentZone = GetZoneText()
    insideBG = (bgs[currentZone] ~= nil)
    maxUnitsDisplayed = bgs[currentZone] or 40

    if insideBG then
        f:RegisterEvent('UPDATE_BATTLEFIELD_SCORE')
        RequestBattlefieldScoreData()
    else
        f:UnregisterEvent('UPDATE_BATTLEFIELD_SCORE')
    end

    if currentZone == 'Alterac Valley' and FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['smartDistanceSorting'] == nil then
        FOSTERFRAMESPLAYERDATA['smartDistanceSorting'] = true
    end

    table.wipe(playerList)
    table.wipe(prioMembers)
    playerListRefresh = 0

    f:SetScript('OnUpdate', fosterFramesCoreOnUpdate)
    FOSTERFRAMESInitialize(maxUnitsDisplayed, insideBG)
    if bindingsInit then bindingsInit() end
    if WSGUIinit then WSGUIinit(insideBG) end

    refreshUnits = true
end

local function checkPlayerCC()
    if not (FOSTERFRAMESPLAYERDATA and FOSTERFRAMESPLAYERDATA['ccAnnounce']) then return end

    local watchedCCs = {
        ['Interface\\Icons\\Ability_Sap']            = 'Sapped!',
        ['Interface\\Icons\\Spell_Nature_Polymorph'] = 'Sheeped!',
    }

    local foundCC = nil
    for i = 1, 16 do
        local debuff = UnitDebuff('player', i)
        if not debuff then break end
        if watchedCCs[debuff] then
            foundCC = watchedCCs[debuff]
            break
        end
    end

    if foundCC and activeCC ~= foundCC then
        activeCC = foundCC
        SendChatMessage(foundCC, 'SAY')
        if insideBG then
            SendChatMessage(foundCC, 'BATTLEGROUND')
        end
    elseif not foundCC then
        activeCC = nil
    end
end

local function eventHandler()
    local evt = event
    local now = GetTime()

    if evt == 'PLAYER_ENTERING_WORLD' or evt == 'ZONE_CHANGED_NEW_AREA' or evt == 'ZONE_CHANGED' then
        initializeValues()
    elseif evt == 'COMBAT_LOG_EVENT_UNFILTERED' then
        scanCombatLog(now)
    elseif evt == 'UNIT_AURA' and arg1 == 'player' then
        checkPlayerCC()
    elseif evt == 'UPDATE_BATTLEFIELD_SCORE' then
        local numScores = GetNumBattlefieldScores()
        local currentEnemies = {}
        local enemyFactionID = (playerFaction == 'Alliance') and 0 or 1

        for i = 1, numScores do
            local name, kb, hk, deaths, honor, faction, race, class, classToken = GetBattlefieldScore(i)
            if faction == enemyFactionID and name and name ~= "" and name:sub(1, 7) ~= "Unknown" then
                currentEnemies[name] = true
                if not playerList[name] then


                    playerList[name] = {
                        name      = name,
                        class     = string.upper(classToken or class or 'WARRIOR'),
                        guid      = name,
                        nearby    = false,
                        health    = nil,
                        maxhealth = 100,
                    }
                    refreshUnits = true
                end
            end
        end

        for name, _ in pairs(playerList) do
            if insideBG and not currentEnemies[name] then
                playerList[name] = nil
                refreshUnits = true
            end
        end
    elseif evt == 'UNIT_HEALTH' or evt == 'UNIT_PVP_UPDATE' then
        if WSGUIupdateFChealth then WSGUIupdateFChealth(arg1) end
        verifyUnitInfo(arg1, now)
    end
end

f:RegisterEvent('PLAYER_ENTERING_WORLD')
f:RegisterEvent('ZONE_CHANGED_NEW_AREA')
f:RegisterEvent('ZONE_CHANGED')
f:RegisterEvent('UPDATE_BATTLEFIELD_SCORE')
f:RegisterEvent('UNIT_HEALTH')
f:RegisterEvent('UNIT_PVP_UPDATE')
f:RegisterEvent('UNIT_AURA')
f:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
f:SetScript('OnEvent', eventHandler)

SLASH_FOSTERFRAMECORE1 = '/ffc'
SLASH_FOSTERFRAMECORE2 = '/fostercore'
SlashCmdList["FOSTERFRAMECORE"] = function(msg)
    if msg == 'deps' then
        if FOSTERFRAMESPrintDependencyStatus then
            FOSTERFRAMESPrintDependencyStatus()
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffae7cee[FosterFrames]|r Tracked Enemies (" .. (insideBG and "Battleground" or "Open World") .. "):")
        for k, v in pairs(playerList) do
            local status = v.nearby and "|cff00ff00Nearby|r" or "|cff808080Inactive|r"
            local dist = v.distance and (" (" .. v.distance .. "yd)") or ""
            DEFAULT_CHAT_FRAME:AddMessage("  " .. v.name .. " [" .. (v.class or "?") .. "] - " .. status .. dist)
        end
    end
end

