Config = {}

-- Main language for messages and NUI labels: 'hu' or 'en'
Config.Language = 'hu'

-- Panel branding (fully editable)
Config.Branding = {
    panelName = 'AY Panel',
    panelLogo = 'AY', -- text logo shown before title; can be any short text/icon
}

-- Rank config is editable (not hardcoded 1-5)
-- canManageAdmins: can use /setadminay
-- developer: can see Developer section
Config.Ranks = {
    [1] = { name = 'Admin I', ace = 'devpanel.rank1' },
    [2] = { name = 'Admin II', ace = 'devpanel.rank2' },
    [3] = { name = 'Admin III', ace = 'devpanel.rank3' },
    [4] = { name = 'Admin IV', ace = 'devpanel.rank4' },
    [5] = { name = 'Admin Controller', ace = 'devpanel.controller', canManageAdmins = true },
    [6] = { name = 'Developer', ace = 'devpanel.developer', developer = true }
}

Config.AdminRanks = {
    -- ['license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'] = 5,
    -- ['license:yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy'] = 6,
}

Config.UseAceFallback = true
Config.RequiredAce = 'aydevpanel.use'

Config.OpenCommand = 'devpanel'
Config.DutyCommand = 'dutyay'
Config.CopyCoordsCommand = 'copycoords'
Config.ToggleKeybind = 'F10'

Config.DefaultWeather = 'EXTRASUNNY'
Config.DefaultTime = { hour = 12, minute = 0 }
Config.WeatherTypes = {
    'EXTRASUNNY', 'CLEAR', 'CLOUDS', 'OVERCAST', 'RAIN', 'THUNDER', 'FOGGY', 'XMAS'
}
Config.TeleportPresets = {
    { label = 'Legion Square', x = 215.76, y = -810.12, z = 30.73 },
    { label = 'Sandy Airfield', x = 1738.1, y = 3298.98, z = 41.15 },
    { label = 'Paleto Bay', x = -445.11, y = 6011.84, z = 31.72 }
}

Config.EnableWebhookLogs = false
Config.WebhookUrl = ''

Config.ActionRanks = {
    duty = 1,
    godmode = 2,
    heal = 1,
    setArmor = 1,
    revive = 2,
    killSelf = 2,
    invisible = 2,
    noclip = 2,
    setNoclipSpeed = 2,
    coords = 1,
    superJump = 3,
    fastRun = 2,
    cleanPed = 1,
    tpWaypoint = 2,
    tpPreset = 2,
    tpCoords = 3,
    freezePosition = 2,
    giveWeapon = 3,

    spawnVehicle = 2,
    deleteVehicle = 2,
    fixVehicle = 1,
    fullFuel = 1,
    flipVehicle = 1,
    maxVehicle = 3,
    forceEngine = 1,

    setWeather = 4,
    setTime = 4,
    freezeTime = 4,
    blackout = 5,
    clearArea = 4,
    announce = 2,
    tpToPlayer = 3,
    bringPlayer = 3,
    kickPlayer = 4,
    reviveTarget = 3,

    esxGiveItem = 3,
    esxRemoveItem = 3,
    esxGiveMoney = 3,
    esxSetJob = 4,

    -- Developer-only block
    printCoords = 6,
    setPedModel = 6,
    spawnObject = 6,
    deleteAimedEntity = 6,
    noRagdoll = 6,
    devEntityDebug = 6
}

Config.DutyOutfits = {
    [1] = {
        label = 'Admin I', model = 'mp_m_freemode_01',
        components = {
            [3] = { drawable = 0, texture = 0 }, [4] = { drawable = 25, texture = 2 }, [6] = { drawable = 25, texture = 2 },
            [8] = { drawable = 15, texture = 0 }, [11] = { drawable = 287, texture = 2 }
        }
    },
    [2] = {
        label = 'Admin II', model = 'mp_m_freemode_01',
        components = {
            [3] = { drawable = 0, texture = 0 }, [4] = { drawable = 25, texture = 5 }, [6] = { drawable = 25, texture = 5 },
            [8] = { drawable = 15, texture = 0 }, [11] = { drawable = 287, texture = 5 }
        }
    },
    [3] = {
        label = 'Admin III', model = 'mp_m_freemode_01',
        components = {
            [3] = { drawable = 0, texture = 0 }, [4] = { drawable = 25, texture = 9 }, [6] = { drawable = 25, texture = 9 },
            [8] = { drawable = 15, texture = 0 }, [11] = { drawable = 287, texture = 9 }
        }
    },
    [4] = {
        label = 'Admin IV', model = 'mp_m_freemode_01',
        components = {
            [3] = { drawable = 0, texture = 0 }, [4] = { drawable = 25, texture = 11 }, [6] = { drawable = 25, texture = 11 },
            [8] = { drawable = 15, texture = 0 }, [11] = { drawable = 287, texture = 11 }
        }
    },
    [5] = {
        label = 'Admin Controller', model = 'mp_m_freemode_01',
        components = {
            [3] = { drawable = 0, texture = 0 }, [4] = { drawable = 25, texture = 14 }, [6] = { drawable = 25, texture = 14 },
            [8] = { drawable = 15, texture = 0 }, [11] = { drawable = 287, texture = 14 }
        }
    },
    [6] = {
        label = 'Developer', model = 'mp_m_freemode_01',
        components = {
            [3] = { drawable = 0, texture = 0 }, [4] = { drawable = 25, texture = 0 }, [6] = { drawable = 25, texture = 0 },
            [8] = { drawable = 15, texture = 0 }, [11] = { drawable = 287, texture = 0 }
        }
    }
}

Config.Locales = {
    hu = {
        notAllowedDuty = '^1Nincs jogosultságod a duty rendszerhez.',
        notAllowedAction = '^1Nincs rang vagy duty jogosultság ehhez a művelethez.',
        dutyStatus = 'Duty: {0}',
        on = '^2ON',
        off = '^1OFF',
        rankUpdated = '^3Admin rangod frissült: ^2{0}',
        setRankDone = '^2Beállítva: {0} -> {1}',
        invalidTarget = '^1Hibás target ID vagy rang.',
        controllerOnly = '^1Csak Admin Controller állíthat rangot.',
        ui = {
            panelName = 'AY Panel',
            rank = 'Rang', duty = 'Duty',
            dutyInfo = 'Admin Controller tud rangot állítani: /setadminay [id] [rank]',
            sectionDeveloper = 'Developer szekció',
            developerHint = 'Ezt csak a Developer rang látja.',
            announcePlaceholder = 'globál üzenet'
        }
    },
    en = {
        notAllowedDuty = '^1You are not allowed to use duty.',
        notAllowedAction = '^1You do not have rank or duty permission for this action.',
        dutyStatus = 'Duty: {0}',
        on = '^2ON',
        off = '^1OFF',
        rankUpdated = '^3Your admin rank has been updated: ^2{0}',
        setRankDone = '^2Updated: {0} -> {1}',
        invalidTarget = '^1Invalid target ID or rank.',
        controllerOnly = '^1Only Admin Controller can set admin ranks.',
        ui = {
            panelName = 'AY Panel',
            rank = 'Rank', duty = 'Duty',
            dutyInfo = 'Admin Controller can set ranks: /setadminay [id] [rank]',
            sectionDeveloper = 'Developer Section',
            developerHint = 'Only Developer rank can see this section.',
            announcePlaceholder = 'global message'
        }
    }
}
