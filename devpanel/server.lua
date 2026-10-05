local AdminController = { players = {} }

local function getLocale()
    return Config.Locales[Config.Language] or Config.Locales.hu
end

local function t(key, ...)
    local locale = getLocale()
    local text = locale[key] or key
    for i, value in ipairs({ ... }) do
        text = text:gsub('{' .. (i - 1) .. '}', tostring(value))
    end
    return text
end

local function getMaxRank()
    local maxRank = 0
    for rank in pairs(Config.Ranks or {}) do
        rank = tonumber(rank)
        if rank and rank > 0 and Config.Ranks[rank] then
            maxRank = math.max(maxRank, math.floor(rank))
        end
    end
    return maxRank
end

local function getRankLabel(rank)
    local def = Config.Ranks[rank]
    return def and def.name or ('Admin %s'):format(rank)
end

local function isDeveloper(rank)
    return Config.Ranks[rank] and Config.Ranks[rank].developer == true
end

local function canManageAdmins(rank)
    return Config.Ranks[rank] and Config.Ranks[rank].canManageAdmins == true
end

local function clamp(value, minValue, maxValue)
    value = tonumber(value)
    if not value then return minValue end
    return math.max(minValue, math.min(maxValue, value))
end

local function isValidWeather(weather)
    if type(weather) ~= 'string' then return false end
    for _, allowed in ipairs(Config.WeatherTypes or {}) do
        if allowed == weather then return true end
    end
    return false
end

local function trim(value)
    value = tostring(value or '')
    return value:gsub('^%s+', ''):gsub('%s+$', '')
end

local function normalizeRank(rank)
    rank = tonumber(rank)
    if not rank then return nil end
    rank = math.floor(rank)
    if rank < 0 then return nil end
    if rank > 0 and not Config.Ranks[rank] then return nil end
    return rank
end

local function logToDiscord(message)
    if not Config.EnableWebhookLogs or Config.WebhookUrl == '' then return end

    PerformHttpRequest(Config.WebhookUrl, function() end, 'POST', json.encode({
        username = 'AY Panel',
        embeds = {{
            title = 'AY Panel Action',
            description = message,
            color = 3447003,
            footer = { text = os.date('%Y-%m-%d %H:%M:%S') }
        }}
    }), { ['Content-Type'] = 'application/json' })
end

local function getRankFromIdentifiers(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        local rank = normalizeRank(Config.AdminRanks[id])
        if rank and rank > 0 then
            return rank
        end
    end

    if Config.UseAceFallback then
        for rank = getMaxRank(), 1, -1 do
            local ace = Config.Ranks[rank] and Config.Ranks[rank].ace
            if ace and IsPlayerAceAllowed(src, ace) then
                return rank
            end
        end
    end

    return 0
end

local function hasPanelAce(src)
    if not Config.RequiredAce or Config.RequiredAce == '' then return true end
    return IsPlayerAceAllowed(src, Config.RequiredAce)
end

local function ensureAdminState(src)
    if not AdminController.players[src] then
        AdminController.players[src] = {
            rank = getRankFromIdentifiers(src),
            duty = false
        }
    end
    return AdminController.players[src]
end

local function hasActionAccess(src, action, requiresDuty)
    local state = ensureAdminState(src)
    local minRank = tonumber(Config.ActionRanks[action])

    if not minRank then
        return false, state
    end

    if not hasPanelAce(src) or state.rank < minRank then
        return false, state
    end

    if requiresDuty and action ~= 'duty' and not state.duty then
        return false, state
    end

    return true, state
end

local function syncState(src)
    local state = ensureAdminState(src)

    TriggerClientEvent('ay_devpanel:adminState', src, {
        rank = state.rank,
        rankName = getRankLabel(state.rank),
        duty = state.duty,
        actionRanks = Config.ActionRanks,
        ranks = Config.Ranks,
        isDeveloper = isDeveloper(state.rank),
        localeUi = getLocale().ui,
        branding = Config.Branding
    })
end

local function setDuty(src, value)
    local state = ensureAdminState(src)
    state.duty = value == true
    syncState(src)
    TriggerClientEvent('ay_devpanel:setDutyClient', src, state.duty, state.rank, Config.DutyOutfits[state.rank])
end

local function notify(src, msg)
    TriggerClientEvent('chat:addMessage', src, {
        color = { 80, 200, 120 },
        args = { 'AY', msg }
    })
end

local function getPlayerTarget(id)
    id = tonumber(id)
    if not id or id < 1 then return nil end
    if not GetPlayerName(id) then return nil end
    return id
end

RegisterNetEvent('ay_devpanel:requestOpen', function()
    local src = source
    local state = ensureAdminState(src)
    local allowed = state.rank > 0 and hasPanelAce(src)

    TriggerClientEvent('ay_devpanel:setPermission', src, allowed)
    if allowed then syncState(src) end
end)

RegisterNetEvent('ay_devpanel:toggleDuty', function()
    local src = source
    local allowed, state = hasActionAccess(src, 'duty', false)

    if not allowed then
        notify(src, t('notAllowedDuty'))
        return
    end

    setDuty(src, not state.duty)
    notify(src, t('dutyStatus', state.duty and t('on') or t('off')))
    logToDiscord(('**%s** -> duty [%s]'):format(GetPlayerName(src) or ('ID %s'):format(src), tostring(state.duty)))
end)

RegisterNetEvent('ay_devpanel:serverAction', function(action, payload)
    local src = source
    action = tostring(action or '')

    local allowed, state = hasActionAccess(src, action, true)
    if not allowed then
        notify(src, t('notAllowedAction'))
        return
    end

    if action == 'setWeather' then
        if not isValidWeather(payload) then return end
        TriggerClientEvent('ay_devpanel:setWeatherClient', -1, payload)

    elseif action == 'setTime' then
        if type(payload) ~= 'table' then return end
        local hour = math.floor(clamp(payload.hour, 0, 23))
        local minute = math.floor(clamp(payload.minute, 0, 59))
        TriggerClientEvent('ay_devpanel:setTimeClient', -1, hour, minute)

    elseif action == 'announce' then
        local message = trim(payload)
        local maxLength = tonumber(Config.MaxAnnounceLength) or 300
        if message == '' then return end
        if #message > maxLength then message = message:sub(1, maxLength) end

        TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 80, 80 },
            multiline = true,
            args = { ('AY %s'):format(getRankLabel(state.rank)), message }
        })

    elseif action == 'setBlackout' then
        if type(payload) ~= 'boolean' then return end
        TriggerClientEvent('ay_devpanel:setBlackoutClient', -1, payload)

    elseif action == 'tpToPlayer' or action == 'bringPlayer' then
        if type(payload) ~= 'table' then return end

        local targetId = getPlayerTarget(payload.targetId)
        if not targetId or targetId == src then return end

        if action == 'tpToPlayer' then
            local targetPed = GetPlayerPed(targetId)
            if targetPed and targetPed > 0 then
                local c = GetEntityCoords(targetPed)
                TriggerClientEvent('ay_devpanel:setCoordsClient', src, c.x, c.y, c.z + 1.0)
            end
        else
            local srcPed = GetPlayerPed(src)
            if srcPed and srcPed > 0 then
                local c = GetEntityCoords(srcPed)
                TriggerClientEvent('ay_devpanel:setCoordsClient', targetId, c.x, c.y, c.z + 1.0)
            end
        end

    elseif action == 'kickPlayer' then
        if type(payload) ~= 'table' then return end

        local targetId = getPlayerTarget(payload.targetId)
        if not targetId or targetId == src then return end

        local reason = trim(payload.reason)
        local maxLength = tonumber(Config.MaxKickReasonLength) or 160
        if reason == '' then reason = 'Kicked by admin panel' end
        if #reason > maxLength then reason = reason:sub(1, maxLength) end

        DropPlayer(targetId, reason)

    else
        return
    end

    logToDiscord(('**%s** -> [%s]'):format(
        GetPlayerName(src) or ('ID %s'):format(src),
        action
    ))
end)

RegisterCommand(Config.OpenCommand, function(src)
    if src == 0 then
        print('This command can only be used in-game.')
        return
    end

    if not hasPanelAce(src) then
        notify(src, t('notAllowedAction'))
        return
    end

    TriggerClientEvent('ay_devpanel:togglePanel', src)
end, false)

RegisterCommand(Config.DutyCommand, function(src)
    if src == 0 then
        print('This command can only be used in-game.')
        return
    end

    local allowed, state = hasActionAccess(src, 'duty', false)
    if not allowed then
        notify(src, t('notAllowedDuty'))
        return
    end

    setDuty(src, not state.duty)
    notify(src, t('dutyStatus', state.duty and t('on') or t('off')))
end, false)

RegisterCommand('setadminay', function(src, args)
    if src ~= 0 and not canManageAdmins(ensureAdminState(src).rank) then
        notify(src, t('controllerOnly'))
        return
    end

    local target = getPlayerTarget(args[1])
    local rank = normalizeRank(args[2])

    if not target or rank == nil then
        if src == 0 then
            print('Usage: setadminay <id> <rank> (rank must exist in Config.Ranks)')
        else
            notify(src, t('invalidTarget'))
        end
        return
    end

    local targetState = ensureAdminState(target)
    targetState.rank = rank

    if rank == 0 and targetState.duty then
        targetState.duty = false
        TriggerClientEvent('ay_devpanel:setDutyClient', target, false, rank, nil)
    end

    syncState(target)
    notify(target, t('rankUpdated', getRankLabel(rank)))

    if src ~= 0 then
        notify(src, t('setRankDone', GetPlayerName(target) or ('ID %s'):format(target), getRankLabel(rank)))
    end

    logToDiscord(('**%s** -> set rank of **%s** to [%s]'):format(
        GetPlayerName(src) or 'CONSOLE',
        GetPlayerName(target) or ('ID %s'):format(target),
        rank
    ))
end, false)

AddEventHandler('playerDropped', function()
    AdminController.players[source] = nil
end)

AddEventHandler('playerJoining', function()
    AdminController.players[source] = nil
end)

CreateThread(function()
    print(('[AY Panel] v%s loaded.'):format(GetResourceMetadata(GetCurrentResourceName(), 'version', 0) or 'unknown'))
end)
