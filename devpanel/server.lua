local AdminController = { players = {} }

local function getLocale()
    return Config.Locales[Config.Language] or Config.Locales.hu
end

local function t(key, ...)
    local locale = getLocale()
    local text = locale[key] or key
    local args = { ... }
    for i, value in ipairs(args) do
        text = text:gsub('{' .. (i - 1) .. '}', tostring(value))
    end
    return text
end

local function getMaxRank()
    local maxRank = 0
    for rank in pairs(Config.Ranks or {}) do
        maxRank = math.max(maxRank, tonumber(rank) or 0)
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
        local rank = Config.AdminRanks[id]
        if rank then
            return math.max(0, math.floor(tonumber(rank) or 0))
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

local function ensureAdminState(src)
    AdminController.players[src] = AdminController.players[src] or {
        rank = getRankFromIdentifiers(src),
        duty = false
    }
    return AdminController.players[src]
end

local function hasActionAccess(src, action, requiresDuty)
    local state = ensureAdminState(src)
    local minRank = Config.ActionRanks[action] or 999
    if state.rank < minRank then return false, state end
    if requiresDuty and action ~= 'duty' and not state.duty then return false, state end
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
        branding = Config.Branding,
        dutyOutfit = Config.DutyOutfits[state.rank]
    })
end

local function setDuty(src, value)
    local state = ensureAdminState(src)
    state.duty = value
    syncState(src)
    TriggerClientEvent('ay_devpanel:setDutyClient', src, value, state.rank, Config.DutyOutfits[state.rank])
end

local function notify(src, msg)
    TriggerClientEvent('chat:addMessage', src, { color = { 80, 200, 120 }, args = { 'AY', msg } })
end

RegisterNetEvent('ay_devpanel:requestOpen', function()
    local src = source
    local state = ensureAdminState(src)
    TriggerClientEvent('ay_devpanel:setPermission', src, state.rank > 0)
    syncState(src)
end)

RegisterNetEvent('ay_devpanel:toggleDuty', function()
    local src = source
    local allowed, state = hasActionAccess(src, 'duty', false)
    if not allowed then notify(src, t('notAllowedDuty')); return end
    setDuty(src, not state.duty)
    notify(src, t('dutyStatus', state.duty and t('on') or t('off')))
end)

RegisterNetEvent('ay_devpanel:serverAction', function(action, payload)
    local src = source
    local allowed = hasActionAccess(src, action, true)
    if not allowed then notify(src, t('notAllowedAction')); return end

    if action == 'setWeather' and type(payload) == 'string' then
        TriggerClientEvent('ay_devpanel:setWeatherClient', -1, payload)
    elseif action == 'setTime' and type(payload) == 'table' then
        TriggerClientEvent('ay_devpanel:setTimeClient', -1, tonumber(payload.hour) or 12, tonumber(payload.minute) or 0)
    elseif action == 'announce' and type(payload) == 'string' and payload ~= '' then
        local st = ensureAdminState(src)
        TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 80, 80 },
            multiline = true,
            args = { ('AY %s'):format(getRankLabel(st.rank)), payload }
        })
    elseif action == 'setBlackout' and type(payload) == 'boolean' then
        TriggerClientEvent('ay_devpanel:setBlackoutClient', -1, payload)
    end

    logToDiscord(('**%s** -> `%s`'):format(GetPlayerName(src) or ('ID %s'):format(src), action))
end)

RegisterCommand(Config.OpenCommand, function(src)
    if src == 0 then print('This command can only be used in-game.'); return end
    TriggerClientEvent('ay_devpanel:togglePanel', src)
end, false)

RegisterCommand(Config.DutyCommand, function(src)
    if src == 0 then print('This command can only be used in-game.'); return end
    local allowed, state = hasActionAccess(src, 'duty', false)
    if not allowed then notify(src, t('notAllowedDuty')); return end
    setDuty(src, not state.duty)
    notify(src, t('dutyStatus', state.duty and t('on') or t('off')))
end, false)

RegisterCommand('setadminay', function(src, args)
    if src ~= 0 and not canManageAdmins(ensureAdminState(src).rank) then
        notify(src, t('controllerOnly'))
        return
    end

    local target = tonumber(args[1] or '')
    local rank = math.max(0, math.floor(tonumber(args[2] or '') or -1))
    if not target or not GetPlayerName(target) or (rank > 0 and not Config.Ranks[rank]) then
        if src == 0 then
            print('Usage: setadminay <id> <rank> (rank must exist in Config.Ranks)')
        else
            notify(src, t('invalidTarget'))
        end
        return
    end

    local st = ensureAdminState(target)
    st.rank = rank
    if rank == 0 and st.duty then
        st.duty = false
        TriggerClientEvent('ay_devpanel:setDutyClient', target, false, rank, nil)
    end

    syncState(target)
    notify(target, t('rankUpdated', getRankLabel(rank)))

    if src ~= 0 then
        notify(src, t('setRankDone', GetPlayerName(target) or ('ID %s'):format(target), getRankLabel(rank)))
    end
end, true)

AddEventHandler('playerDropped', function() AdminController.players[source] = nil end)
