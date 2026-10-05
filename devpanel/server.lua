local AdminController = { players = {} }
local FrozenPlayers = {}

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

local DiscordQueue = {}
local DiscordSending = false

local function getDiscordConfig()
    local d = Config.Discord or {}
    if d.enabled == true and d.webhook and d.webhook ~= '' then
        return d
    end
    if Config.EnableWebhookLogs and Config.WebhookUrl and Config.WebhookUrl ~= '' then
        return {
            enabled = true,
            webhook = Config.WebhookUrl,
            username = 'AY Panel',
            colors = { info = 3447003, success = 5763719, warning = 16776960, danger = 15158332, purple = 10181046 }
        }
    end
    return nil
end

local function discordEscape(value)
    value = tostring(value or '')
    value = value:gsub('@everyone', '@ everyone'):gsub('@here', '@ here')
    return value:sub(1, 1024)
end

local function getPlayerIdentifiersSafe(src)
    if not src or src == 0 then return {} end
    local result = {}
    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        result[#result + 1] = identifier
    end
    return result
end

local function sendDiscordQueue()
    if DiscordSending or #DiscordQueue == 0 then return end
    local cfg = getDiscordConfig()
    if not cfg then DiscordQueue = {}; return end

    DiscordSending = true
    local item = table.remove(DiscordQueue, 1)

    PerformHttpRequest(cfg.webhook, function(statusCode)
        if (statusCode < 200 or statusCode >= 300) and item.retries < (tonumber(cfg.retryCount) or 2) then
            item.retries = item.retries + 1
            table.insert(DiscordQueue, 1, item)
        end
        DiscordSending = false
        SetTimeout(250, sendDiscordQueue)
    end, 'POST', json.encode({
        username = cfg.username or 'AY Panel',
        avatar_url = cfg.avatarUrl or nil,
        embeds = { item.embed },
        allowed_mentions = { parse = {} }
    }), { ['Content-Type'] = 'application/json' })
end

local function discordLog(title, description, color, fields)
    local cfg = getDiscordConfig()
    if not cfg then return end
    local maxQueue = tonumber(cfg.maxQueueSize) or 50
    if #DiscordQueue >= maxQueue then return end

    table.insert(DiscordQueue, {
        retries = 0,
        embed = {
            title = ('🛡️ %s'):format(discordEscape(title)),
            description = discordEscape(description),
            color = color or ((cfg.colors or {}).info or 3447003),
            fields = fields or {},
            footer = { text = ('AY Panel • %s'):format(os.date('%Y-%m-%d %H:%M:%S')) },
            timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
        }
    })
    sendDiscordQueue()
end

local function logToDiscord(message)
    local cfg = getDiscordConfig()
    if not cfg or cfg.logAdminActions == false then return end
    discordLog('AY Panel Action', message, 3447003)
end

local function logPlayerEvent(title, src, color, extra)
    local cfg = getDiscordConfig()
    if not cfg then return end
    if (title == 'Admin duty ON' or title == 'Admin duty OFF') and cfg.logDutyChanges == false then return end
    if (title == 'Admin rank changed') and cfg.logRankChanges == false then return end
    if (title == 'Player joining' or title == 'Player left') and cfg.logPlayerJoinLeave == false then return end

    local name = GetPlayerName(src) or ('ID %s'):format(src)
    local fields = {
        { name = 'Player', value = ('%s (#%s)'):format(discordEscape(name), src), inline = true }
    }

    if extra then
        fields[#fields + 1] = { name = 'Details', value = discordEscape(extra), inline = true }
    end

    if cfg.includeIdentifiers then
        local ids = getPlayerIdentifiersSafe(src)
        fields[#fields + 1] = {
            name = 'Identifiers',
            value = discordEscape(table.concat(ids, '\n')):sub(1, 1024),
            inline = false
        }
    end

    discordLog(title, ('%s • %s'):format(discordEscape(name), title), color, fields)
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
    logPlayerEvent(state.duty and 'Admin duty ON' or 'Admin duty OFF', src, state.duty and ((Config.Discord or {}).colors or {}).success or ((Config.Discord or {}).colors or {}).warning, ('Rank: %s'):format(getRankLabel(state.rank)))
end)

local function sendPlayerList(src)
    local players = {}
    for _, playerId in ipairs(GetPlayers()) do
        local id = tonumber(playerId)
        if id then
            local state = ensureAdminState(id)
            players[#players + 1] = {
                id = id,
                name = GetPlayerName(id) or ('ID %s'):format(id),
                ping = GetPlayerPing(id) or 0,
                rank = state.rank or 0,
                rankName = getRankLabel(state.rank or 0),
                duty = state.duty == true
            }
        end
    end
    table.sort(players, function(a, b) return a.id < b.id end)
    TriggerClientEvent('ay_devpanel:playerList', src, players)
end

RegisterNetEvent('ay_devpanel:requestPlayers', function()
    local src = source
    local allowed = hasActionAccess(src, 'viewPlayers', false)
    if not allowed then return end
    sendPlayerList(src)
end)

RegisterNetEvent('ay_devpanel:playerAction', function(action, payload)
    local src = source
    action = tostring(action or '')
    payload = type(payload) == 'table' and payload or {}
    local allowed = hasActionAccess(src, action, true)
    if not allowed then notify(src, t('notAllowedAction')); return end
    local targetId = getPlayerTarget(payload.targetId)
    if not targetId or targetId == src then return end

    if action == 'playerSpectate' then
        TriggerClientEvent('ay_devpanel:startSpectate', src, targetId)
    elseif action == 'playerFreeze' then
        FrozenPlayers[targetId] = not FrozenPlayers[targetId]
        TriggerClientEvent('ay_devpanel:setPlayerFrozen', targetId, FrozenPlayers[targetId] == true)
    elseif action == 'playerHeal' then
        TriggerClientEvent('ay_devpanel:playerHeal', targetId)
    elseif action == 'playerRevive' then
        TriggerClientEvent('ay_devpanel:playerRevive', targetId)
    elseif action == 'playerKill' then
        TriggerClientEvent('ay_devpanel:playerKill', targetId)
    elseif action == 'playerGoto' then
        local targetPed = GetPlayerPed(targetId)
        if targetPed and targetPed > 0 then
            local c = GetEntityCoords(targetPed)
            TriggerClientEvent('ay_devpanel:setCoordsClient', src, c.x, c.y, c.z + 1.0)
        end
    elseif action == 'playerBring' then
        local srcPed = GetPlayerPed(src)
        if srcPed and srcPed > 0 then
            local c = GetEntityCoords(srcPed)
            TriggerClientEvent('ay_devpanel:setCoordsClient', targetId, c.x, c.y, c.z + 1.0)
        end
    elseif action == 'playerKick' then
        local reason = trim(payload.reason)
        local maxLength = tonumber(Config.MaxKickReasonLength) or 160
        if reason == '' then reason = 'Kicked by AY Panel' end
        if #reason > maxLength then reason = reason:sub(1, maxLength) end
        DropPlayer(targetId, reason)
    end
    discordLog('Player action', ('%s used %s on %s'):format(GetPlayerName(src) or ('ID %s'):format(src), action, GetPlayerName(targetId) or ('ID %s'):format(targetId)), ((Config.Discord or {}).colors or {}).danger, {{ name = 'Admin', value = ('%s (#%s)'):format(GetPlayerName(src) or 'Unknown', src), inline = true }, { name = 'Target', value = ('%s (#%s)'):format(GetPlayerName(targetId) or 'Unknown', targetId), inline = true }, { name = 'Action', value = action, inline = true }})
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

    discordLog('Server action', ('%s used %s'):format(GetPlayerName(src) or ('ID %s'):format(src), action), ((Config.Discord or {}).colors or {}).info, {{ name = 'Admin', value = ('%s (#%s)'):format(GetPlayerName(src) or 'Unknown', src), inline = true }, { name = 'Action', value = action, inline = true }})
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

    if (Config.Discord or {}).logRankChanges ~= false then
        discordLog('Admin rank changed', ('%s changed %s to rank %s'):format(GetPlayerName(src) or 'CONSOLE', GetPlayerName(target) or ('ID %s'):format(target), rank), ((Config.Discord or {}).colors or {}).purple, {
            { name = 'Actor', value = ('%s (#%s)'):format(GetPlayerName(src) or 'CONSOLE', src), inline = true },
            { name = 'Target', value = ('%s (#%s)'):format(GetPlayerName(target) or 'Unknown', target), inline = true },
            { name = 'New rank', value = ('%s — %s'):format(rank, getRankLabel(rank)), inline = true }
        })
    end
end, false)

AddEventHandler('playerJoining', function()
    local src = source
    if (Config.Discord or {}).logPlayerJoinLeave then
        logPlayerEvent('Player joining', src, ((Config.Discord or {}).colors or {}).success, 'Connection started')
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    if (Config.Discord or {}).logPlayerJoinLeave then
        logPlayerEvent('Player left', src, ((Config.Discord or {}).colors or {}).warning, ('Reason: %s'):format(reason or 'Unknown'))
    end
    AdminController.players[src] = nil
    FrozenPlayers[src] = nil
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    if (Config.Discord or {}).logServerLifecycle ~= false then
        discordLog('AY Panel started', 'The AY Developer Panel resource is now online.', ((Config.Discord or {}).colors or {}).success)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    if (Config.Discord or {}).logServerLifecycle ~= false then
        discordLog('AY Panel stopped', 'The AY Developer Panel resource is shutting down.', ((Config.Discord or {}).colors or {}).danger)
    end
end)

AddEventHandler('playerDropped', function()
    AdminController.players[source] = nil
    FrozenPlayers[source] = nil
end)

AddEventHandler('playerJoining', function()
    AdminController.players[source] = nil
end)

CreateThread(function()
    print(('[AY Panel] v%s loaded.'):format(GetResourceMetadata(GetCurrentResourceName(), 'version', 0) or 'unknown'))
end)
