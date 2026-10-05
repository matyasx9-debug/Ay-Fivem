# AY Developer Panel — FiveM

A standalone, modern NUI admin and developer panel for FiveM servers.

**Current release: `2.4.0`**

## Features

- Rank-based admin permission system with ACE support
- Duty system with rank-specific outfits
- Player tools: God Mode, Heal, Armor, Revive, Invisible, Noclip, Freeze Position, Super Jump and Fast Run
- Teleport tools: Waypoint, Presets, Coordinates, Teleport to Player and Bring Player
- Vehicle tools: Spawn, Delete, Repair, Full Fuel, Flip, Max Upgrade and Force Engine
- World controls: Weather, Time, Freeze Time, Blackout and Area Clear
- Player moderation: Kick and Global Announcement
- Developer tools: Ped/Object spawning, Entity Debug, Delete Aimed Entity and No Ragdoll
- `/copycoords` with Vec3 and Vec4 output
- Hungarian and English UI support
- Advanced Discord audit logging with embeds, event categories, queue/retry handling, player join/leave and server lifecycle events
- In-panel Admin Audit Log with search and action filters
- Server-side permission and input validation
- GitHub Actions CI

## Installation

1. Put the `devpanel` folder inside your FiveM server's `resources` directory.
2. Add this to `server.cfg`:

```cfg
ensure ay_devpanel
```

3. Configure ACE permissions:

```cfg
add_ace group.admin aydevpanel.use allow
add_ace group.admin devpanel.rank1 allow
add_ace group.admin devpanel.rank2 allow
add_ace group.admin devpanel.rank3 allow
add_ace group.admin devpanel.rank4 allow
add_ace group.admin devpanel.controller allow
add_ace group.developer devpanel.developer allow
```

Assign a player to a group:

```cfg
add_principal identifier.license:YOUR_LICENSE group.admin
```

Replace `YOUR_LICENSE` with the actual FiveM license identifier.

4. Restart the resource:

```text
restart ay_devpanel
```

## Usage

### Open the panel

- Press **F10**
- Or use `/devpanel`

The key can be changed with:

```lua
Config.ToggleKeybind = 'F10'
```

### Duty

Use `/dutyay` or the Duty button. Most actions require the configured minimum rank **and** active duty.

### Admin ranks

Ranks are configured in `devpanel/config.lua`.

| Rank | Name | Purpose |
|---:|---|---|
| 1 | Admin I | Basic admin tools |
| 2 | Admin II | Advanced player tools |
| 3 | Admin III | Advanced admin tools |
| 4 | Admin IV | World/moderation tools |
| 5 | Admin Controller | Admin management |
| 6 | Developer | Developer-only tools |

Required ranks are controlled by `Config.ActionRanks`.

### Set an admin rank

Admin Controller or the server console:

```text
/setadminay [player_id] [rank]
```

Examples:

```text
/setadminay 12 3
/setadminay 12 0
```

**Note:** ranks assigned with `/setadminay` are currently session-based and reset when the player leaves. For persistent permissions, configure `Config.AdminRanks` or use ACE.

## Configuration

Edit `devpanel/config.lua` to configure:

- Panel name and logo
- Language
- Admin ranks
- Identifier-based ranks
- ACE fallback
- Required panel ACE
- Commands and keybind
- Default weather/time
- Allowed weather types
- Teleport presets
- Webhook logging
- Discord audit logging
- Admin Audit Log
- Minimum rank per action
- Duty outfits
- Input limits

Example:

```lua
Config.Language = 'en'
Config.OpenCommand = 'devpanel'
Config.DutyCommand = 'dutyay'
Config.ToggleKeybind = 'F10'
```

## Discord Webhook Logging

Webhook logging is disabled by default.

Enable it only if required:

```lua
Config.EnableWebhookLogs = true
Config.WebhookUrl = 'YOUR_WEBHOOK_URL'

-- New Discord integration
Config.Discord = {
    enabled = true,
    webhook = 'YOUR_WEBHOOK_URL',
    username = 'AY Panel',
    logPlayerJoinLeave = true,
    logAdminActions = true,
    logDutyChanges = true,
    logRankChanges = true,
    logServerLifecycle = true,
    includeIdentifiers = false,
    includeCoordinates = false,
    retryCount = 2,
    maxQueueSize = 50
}
```

Never commit a real Discord webhook URL to a public repository.

Discord logs now include structured embeds for admin/player actions, duty changes, rank changes, player joins/leaves and resource lifecycle events. Webhook requests are queued and retried to reduce log loss during short Discord/network interruptions. Identifier logging is opt-in.

## Admin Audit Log

The in-panel Audit Log records the latest **100 admin actions** and provides:

- Admin/action/target details
- Player, server, rank and duty event categories
- Search
- Action filters
- Server-side permission protection

## Copy coordinates

```text
/copycoords
/copycoords vec3
/copycoords vec4
```

Clipboard support uses `lib.setClipboard` when available. Without it, the coordinate is printed to the client console.

## Security notes

- Server-side actions validate rank, ACE permission, duty state and payloads.
- Player IDs and kick reasons are validated server-side.
- Weather and time values are constrained to configured ranges.
- Rank assignments are limited to ranks actually defined in `Config.Ranks`.
- Keep webhook URLs private.
- Do not treat client-side tools as an anti-cheat boundary; FiveM clients are not trusted.

## Troubleshooting

1. Confirm the folder is named `devpanel`.
2. Confirm `ensure ay_devpanel` is present in `server.cfg`.
3. Check the FXServer console for `[AY Panel]` messages.
4. Restart the resource after changes.

## License

See the repository license file.

## 2.2.0 — Live Player Management

- Live online player list with automatic refresh
- Search by player name or server ID
- Ping and staff/duty indicators
- Spectate, Go To, Bring, Freeze, Heal, Revive, Kill and Kick
- Server-side rank and duty validation for player actions

## In-game Preview / Review

Current **AY Panel v2.4.0** visual preview in a FiveM-style in-game environment:

![AY Panel v2.4.0 In-game Preview](docs/ay-panel-preview.svg)

> Preview is a **2560×1440 high-resolution visual mockup** of the current NUI layout and features; actual player/server data is populated live in FiveM.
