local panelOpen = false
local hasAccess = false

local adminRank = 0
local adminRankName = 'N/A'
local isOnDuty = false
local isDeveloper = false
local actionRanks = {}
local ranks = {}
local localeUi = {}
local branding = {}

local godMode, noclip, showCoords = false, false, false
local frozenTime, blackoutEnabled, invisible = false, false, false
local superJump, fastRun, engineForcedOn = false, false, false
local noRagdoll, devEntityDebug = false, false
local freezePosition = false
local noClipSpeed = 1.5

local savedAppearance = nil

local function notify(msg)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, false)
end

local function loadModel(modelName)
    local model = type(modelName) == 'string' and joaat(modelName) or modelName
    if not IsModelInCdimage(model) then return false end
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)
    return true
end

local function captureAppearance(ped)
    local data = { model = GetEntityModel(ped), components = {}, props = {} }
    for i = 0, 11 do
        data.components[i] = {
            drawable = GetPedDrawableVariation(ped, i),
            texture = GetPedTextureVariation(ped, i),
            palette = GetPedPaletteVariation(ped, i)
        }
    end
    for i = 0, 7 do
        data.props[i] = { index = GetPedPropIndex(ped, i), texture = GetPedPropTextureIndex(ped, i) }
    end
    return data
end

local function applyAppearance(data)
    if not data then return end
    if data.model then loadModel(data.model) end
    local ped = PlayerPedId()
    for i = 0, 11 do
        local c = data.components[i]
        if c then SetPedComponentVariation(ped, i, c.drawable, c.texture, c.palette or 0) end
    end
    ClearAllPedProps(ped)
    for i = 0, 7 do
        local p = data.props[i]
        if p and p.index and p.index >= 0 then SetPedPropIndex(ped, i, p.index, p.texture or 0, true) end
    end
end

local function applyDutyOutfit(rank, outfit)
    local ped = PlayerPedId()
    if not savedAppearance then savedAppearance = captureAppearance(ped) end
    if outfit and outfit.model then loadModel(outfit.model); ped = PlayerPedId() end
    if outfit and outfit.components then
        for compId, comp in pairs(outfit.components) do
            SetPedComponentVariation(ped, tonumber(compId), comp.drawable, comp.texture or 0, comp.palette or 0)
        end
    end
    notify(('~g~Duty ON | %s'):format(adminRankName or ('Admin ' .. rank)))
end

local function clearDutyOutfit()
    if savedAppearance then applyAppearance(savedAppearance); savedAppearance = nil end
    notify('~r~Duty OFF | Előző kinézet visszaállítva')
end

local function hasActionPermission(action)
    local required = tonumber(actionRanks[action]) or 99
    if adminRank < required then
        notify(('~r~Ehhez legalább %s rang kell.'):format(required))
        return false
    end
    if action ~= 'duty' and not isOnDuty then
        notify('~r~Előbb duty-ba kell lépned (/dutyay)!')
        return false
    end
    return true
end

local function getForwardVector(rot)
    local z, x = math.rad(rot.z), math.rad(rot.x)
    local num = math.abs(math.cos(x))
    return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

local function getCamDirection()
    local rot = GetGameplayCamRot(2)
    local pitch, yaw = math.rad(rot.x), math.rad(rot.z)
    return vector3(-math.sin(yaw) * math.cos(pitch), math.cos(yaw) * math.cos(pitch), math.sin(pitch))
end

local function raycastFromCamera(distance)
    local camPos, dir = GetGameplayCamCoord(), getCamDirection()
    local dest = camPos + (dir * distance)
    local ray = StartShapeTestRay(camPos.x, camPos.y, camPos.z, dest.x, dest.y, dest.z, -1, PlayerPedId(), 0)
    local _, hit, endPos, _, entity = GetShapeTestResult(ray)
    return hit == 1, endPos, entity
end

local function sendAdminStateToUi()
    SendNUIMessage({
        action = 'adminState',
        admin = {
            rank = adminRank,
            rankName = adminRankName,
            duty = isOnDuty,
            isDeveloper = isDeveloper,
            actionRanks = actionRanks,
            ranks = ranks,
            localeUi = localeUi,
            branding = branding
        }
    })
end

local function setPanel(state)
    panelOpen = state
    SetNuiFocus(state, state)
    SendNUIMessage({
        action = 'toggle',
        state = state,
        defaults = { weather = Config.DefaultWeather, hour = Config.DefaultTime.hour, minute = Config.DefaultTime.minute, noclipSpeed = noClipSpeed },
        weatherTypes = Config.WeatherTypes or {},
        teleportPresets = Config.TeleportPresets or {},
        admin = {
            rank = adminRank,
            rankName = adminRankName,
            duty = isOnDuty,
            isDeveloper = isDeveloper,
            actionRanks = actionRanks,
            ranks = ranks,
            localeUi = localeUi,
            branding = branding
        }
    })
end

RegisterNetEvent('ay_devpanel:togglePanel', function()
    TriggerServerEvent('ay_devpanel:requestOpen')
    Wait(100)
    if not hasAccess then notify('~r~Nincs jogosultságod a panelhez.'); return end
    setPanel(not panelOpen)
end)

RegisterNetEvent('ay_devpanel:setPermission', function(state) hasAccess = state end)

RegisterNetEvent('ay_devpanel:adminState', function(state)
    adminRank = tonumber(state.rank) or 0
    adminRankName = state.rankName or ('Admin ' .. adminRank)
    isOnDuty = state.duty == true
    isDeveloper = state.isDeveloper == true
    actionRanks = state.actionRanks or {}
    ranks = state.ranks or {}
    localeUi = state.localeUi or {}
    branding = state.branding or {}
    sendAdminStateToUi()
end)

RegisterNetEvent('ay_devpanel:setDutyClient', function(state, rank, outfit)
    isOnDuty = state == true
    adminRank = tonumber(rank) or adminRank
    if isOnDuty then applyDutyOutfit(adminRank, outfit) else clearDutyOutfit() end
    sendAdminStateToUi()
end)

RegisterNUICallback('close', function(_, cb) setPanel(false); cb('ok') end)

RegisterNetEvent('ay_devpanel:setWeatherClient', function(weather)
    SetWeatherTypeOverTime(weather, 3.0); Wait(3000); SetWeatherTypeNowPersist(weather)
end)
RegisterNetEvent('ay_devpanel:setTimeClient', function(hour, minute) NetworkOverrideClockTime(hour, minute, 0) end)
RegisterNetEvent('ay_devpanel:setBlackoutClient', function(state)
    blackoutEnabled = state
    SetArtificialLightsState(state)
    SetArtificialLightsStateAffectsVehicles(false)
end)

RegisterNetEvent('ay_devpanel:setCoordsClient', function(x, y, z)
    local ped = PlayerPedId()
    SetPedCoordsKeepVehicle(ped, tonumber(x) or 0.0, tonumber(y) or 0.0, tonumber(z) or 0.0)
end)

RegisterNUICallback('action', function(data, cb)
    local action, ped = data.action, PlayerPedId()

    if action == 'duty' then TriggerServerEvent('ay_devpanel:toggleDuty'); cb('ok'); return end
    if not hasActionPermission(action) then cb('ok'); return end

    if action == 'godmode' then
        godMode = data.state
        SetEntityInvincible(ped, data.state)
        SetPlayerInvincible(PlayerId(), data.state)
    elseif action == 'heal' then
        SetEntityHealth(ped, GetEntityMaxHealth(ped)); SetPedArmour(ped, 100)
    elseif action == 'setArmor' then
        SetPedArmour(ped, 100)
    elseif action == 'revive' then
        local c = GetEntityCoords(ped)
        NetworkResurrectLocalPlayer(c.x, c.y, c.z, GetEntityHeading(ped), true, false)
        SetEntityHealth(ped, GetEntityMaxHealth(ped))
    elseif action == 'killSelf' then
        SetEntityHealth(ped, 0)
    elseif action == 'invisible' then
        invisible = data.state
        SetEntityVisible(ped, not data.state, false)
    elseif action == 'noclip' then
        noclip = data.state
        SetEntityCollision(ped, not data.state, not data.state)
        FreezeEntityPosition(ped, data.state)
    elseif action == 'setNoclipSpeed' then
        noClipSpeed = math.max(0.5, math.min(15.0, tonumber(data.value) or 1.5))
    elseif action == 'coords' then
        showCoords = data.state
    elseif action == 'superJump' then
        superJump = data.state
    elseif action == 'fastRun' then
        fastRun = data.state
    elseif action == 'cleanPed' then
        ClearPedBloodDamage(ped); ResetPedVisibleDamage(ped); ClearPedEnvDirt(ped)
    elseif action == 'tpWaypoint' then
        local blip = GetFirstBlipInfoId(8)
        if DoesBlipExist(blip) then
            local x, y, z = table.unpack(GetBlipInfoIdCoord(blip))
            SetPedCoordsKeepVehicle(ped, x, y, z + 1.0)
        end
    elseif action == 'tpCoords' then
        if tonumber(data.x) and tonumber(data.y) and tonumber(data.z) then
            SetPedCoordsKeepVehicle(ped, tonumber(data.x), tonumber(data.y), tonumber(data.z))
        end
    elseif action == 'tpPreset' then
        local preset = data.preset
        if type(preset) == 'table' and tonumber(preset.x) and tonumber(preset.y) and tonumber(preset.z) then
            SetPedCoordsKeepVehicle(ped, tonumber(preset.x), tonumber(preset.y), tonumber(preset.z))
        end
    elseif action == 'freezePosition' then
        freezePosition = data.state == true
        FreezeEntityPosition(ped, freezePosition)
    elseif action == 'giveWeapon' then
        local weaponName = tostring(data.weapon or ''):upper()
        if weaponName ~= '' then
            local hash = joaat(weaponName)
            if IsWeaponValid(hash) then GiveWeaponToPed(ped, hash, 250, false, true) end
        end
    elseif action == 'spawnVehicle' then
        local modelName, model = (data.model or ''):lower(), joaat((data.model or ''):lower())
        if modelName ~= '' and IsModelInCdimage(model) and IsModelAVehicle(model) then
            RequestModel(model)
            while not HasModelLoaded(model) do Wait(0) end
            local c, h = GetEntityCoords(ped), GetEntityHeading(ped)
            local v = CreateVehicle(model, c.x, c.y, c.z, h, true, false)
            SetPedIntoVehicle(ped, v, -1)
            SetVehicleOnGroundProperly(v)
            SetModelAsNoLongerNeeded(model)
        end
    elseif action == 'deleteVehicle' then
        local v = GetVehiclePedIsIn(ped, false)
        if v ~= 0 then DeleteEntity(v) end
    elseif action == 'fixVehicle' then
        local v = GetVehiclePedIsIn(ped, false)
        if v ~= 0 then SetVehicleFixed(v); SetVehicleDeformationFixed(v); SetVehicleDirtLevel(v, 0.0) end
    elseif action == 'fullFuel' then
        local v = GetVehiclePedIsIn(ped, false)
        if v ~= 0 then SetVehicleFuelLevel(v, 100.0) end
    elseif action == 'flipVehicle' then
        local v = GetVehiclePedIsIn(ped, false)
        if v ~= 0 then
            local c = GetEntityCoords(v)
            SetEntityRotation(v, 0.0, 0.0, GetEntityHeading(v), 2, true)
            SetEntityCoordsNoOffset(v, c.x, c.y, c.z + 1.0, false, false, false)
        end
    elseif action == 'maxVehicle' then
        local v = GetVehiclePedIsIn(ped, false)
        if v ~= 0 then
            SetVehicleModKit(v, 0)
            for modType = 0, 16 do
                local count = GetNumVehicleMods(v, modType)
                if count > 0 then SetVehicleMod(v, modType, count - 1, false) end
            end
        end
    elseif action == 'forceEngine' then
        engineForcedOn = data.state
    elseif action == 'setWeather' then
        TriggerServerEvent('ay_devpanel:serverAction', 'setWeather', data.weather)
    elseif action == 'setTime' then
        TriggerServerEvent('ay_devpanel:serverAction', 'setTime', { hour = data.hour, minute = data.minute })
    elseif action == 'freezeTime' then
        frozenTime = data.state
    elseif action == 'blackout' then
        TriggerServerEvent('ay_devpanel:serverAction', 'setBlackout', data.state)
    elseif action == 'clearArea' then
        local radius = math.max(5.0, math.min(500.0, tonumber(data.radius) or 50.0))
        local c = GetEntityCoords(ped)
        ClearAreaOfVehicles(c.x, c.y, c.z, radius, false, false, false, false, false)
        ClearAreaOfPeds(c.x, c.y, c.z, radius, 1)
        ClearAreaOfObjects(c.x, c.y, c.z, radius, 0)
    elseif action == 'announce' then
        TriggerServerEvent('ay_devpanel:serverAction', 'announce', data.message)
    elseif action == 'tpToPlayer' then
        TriggerServerEvent('ay_devpanel:serverAction', 'tpToPlayer', { targetId = tonumber(data.targetId) or 0 })
    elseif action == 'bringPlayer' then
        TriggerServerEvent('ay_devpanel:serverAction', 'bringPlayer', { targetId = tonumber(data.targetId) or 0 })
    elseif action == 'kickPlayer' then
        TriggerServerEvent('ay_devpanel:serverAction', 'kickPlayer', { targetId = tonumber(data.targetId) or 0, reason = tostring(data.reason or '') })
    elseif action == 'printCoords' then
        local c, h = GetEntityCoords(ped), GetEntityHeading(ped)
        notify(('~g~X: %.2f Y: %.2f Z: %.2f H: %.2f'):format(c.x, c.y, c.z, h))
    elseif action == 'setPedModel' then
        if tostring(data.model or '') ~= '' then loadModel(data.model) end
    elseif action == 'spawnObject' then
        local objName, hash = tostring(data.object or ''), joaat(tostring(data.object or ''))
        if objName ~= '' and IsModelInCdimage(hash) then
            RequestModel(hash)
            while not HasModelLoaded(hash) do Wait(0) end
            local c, f = GetEntityCoords(ped), GetEntityForwardVector(ped)
            local obj = CreateObject(hash, c.x + f.x * 2.0, c.y + f.y * 2.0, c.z, true, true, false)
            PlaceObjectOnGroundProperly(obj)
            SetEntityAsMissionEntity(obj, true, true)
            SetModelAsNoLongerNeeded(hash)
        end
    elseif action == 'deleteAimedEntity' then
        local hit, _, entity = raycastFromCamera(300.0)
        if hit and entity and entity ~= 0 and DoesEntityExist(entity) then
            SetEntityAsMissionEntity(entity, true, true)
            DeleteEntity(entity)
        end
    elseif action == 'noRagdoll' then
        noRagdoll = data.state == true
    elseif action == 'devEntityDebug' then
        devEntityDebug = data.state == true
    end

    cb('ok')
end)

RegisterCommand(Config.CopyCoordsCommand or 'copycoords', function(_, args)
    local ped = PlayerPedId()
    local c, h = GetEntityCoords(ped), GetEntityHeading(ped)
    local mode = string.lower(tostring(args[1] or 'vec4'))
    local output

    if mode == 'vec3' then
        output = ('vec3(%.2f, %.2f, %.2f)'):format(c.x, c.y, c.z)
    else
        output = ('vec4(%.2f, %.2f, %.2f, %.2f)'):format(c.x, c.y, c.z, h)
    end

    if type(lib) == 'table' and type(lib.setClipboard) == 'function' then
        lib.setClipboard(output)
        notify(('~g~Koordináta másolva: %s'):format(output))
    else
        notify(('~y~Clipboard nem elérhető, koordináta: %s'):format(output))
        print(output)
    end
end, false)

CreateThread(function()
    RegisterKeyMapping('+ay_devpanel', 'Open AY Panel', 'keyboard', Config.ToggleKeybind)
    RegisterCommand('+ay_devpanel', function() TriggerEvent('ay_devpanel:togglePanel') end, false)
    RegisterCommand('-ay_devpanel', function() end, false)
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()

        if noclip then
            sleep = 0
            local coords, rot = GetEntityCoords(ped), GetGameplayCamRot(2)
            local forward, camRight = getForwardVector(rot), GetEntityRightVector(ped)
            if IsControlPressed(0, 32) then coords = coords + (forward * noClipSpeed) end
            if IsControlPressed(0, 33) then coords = coords - (forward * noClipSpeed) end
            if IsControlPressed(0, 34) then coords = coords - (camRight * noClipSpeed) end
            if IsControlPressed(0, 35) then coords = coords + (camRight * noClipSpeed) end
            if IsControlPressed(0, 44) then coords = coords + vector3(0.0, 0.0, noClipSpeed) end
            if IsControlPressed(0, 38) then coords = coords - vector3(0.0, 0.0, noClipSpeed) end
            SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, true, true, true)
            SetEntityRotation(ped, 0.0, 0.0, rot.z, 2, true)
        end

        if godMode then SetPlayerInvincible(PlayerId(), true); SetEntityInvincible(ped, true) end
        if invisible then SetEntityVisible(ped, false, false) end

        if superJump then sleep = 0; SetSuperJumpThisFrame(PlayerId()) end
        if fastRun then sleep = 0; SetRunSprintMultiplierForPlayer(PlayerId(), 1.49) else SetRunSprintMultiplierForPlayer(PlayerId(), 1.0) end

        if showCoords then
            sleep = 0
            local c, h = GetEntityCoords(ped), GetEntityHeading(ped)
            SetTextFont(4); SetTextProportional(0); SetTextScale(0.35, 0.35); SetTextColour(255, 255, 255, 220)
            SetTextEntry('STRING'); SetTextOutline()
            AddTextComponentString(string.format('X: %.2f | Y: %.2f | Z: %.2f | H: %.2f', c.x, c.y, c.z, h))
            DrawText(0.015, 0.76)
        end

        if frozenTime then NetworkOverrideClockTime(GetClockHours(), GetClockMinutes(), 0) end
        if blackoutEnabled then SetArtificialLightsState(true); SetArtificialLightsStateAffectsVehicles(false) end

        if engineForcedOn then
            local v = GetVehiclePedIsIn(ped, false)
            if v ~= 0 then SetVehicleEngineOn(v, true, true, true) end
        end

        if noRagdoll then sleep = 0; SetPedCanRagdoll(ped, false) else SetPedCanRagdoll(ped, true) end

        if freezePosition then
            sleep = 0
            FreezeEntityPosition(ped, true)
        end

        if devEntityDebug then
            sleep = 0
            local hit, pos, entity = raycastFromCamera(300.0)
            local msg = 'No entity'
            if hit and entity and entity ~= 0 and DoesEntityExist(entity) then
                msg = ('Entity: %s | Model: %s | Pos: %.2f %.2f %.2f'):format(entity, GetEntityModel(entity), pos.x, pos.y, pos.z)
            end
            SetTextFont(4); SetTextProportional(0); SetTextScale(0.33, 0.33); SetTextColour(120, 255, 120, 220)
            SetTextEntry('STRING'); SetTextOutline(); AddTextComponentString(msg); DrawText(0.015, 0.79)
        end

        Wait(sleep)
    end
end)
