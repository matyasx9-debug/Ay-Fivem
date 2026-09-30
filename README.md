# AY Developer Panel — FiveM

A modern NUI-based admin and developer panel for FiveM servers.

## Features

- Rank-based admin permission system with ACE support
- Duty system with rank-specific outfits
- Player tools: God Mode, Heal, Armor, Revive, Invisible, Noclip, Super Jump and Fast Run
- Teleport tools: Waypoint, Presets, Coordinates, Teleport to Player and Bring Player
- Vehicle tools: Spawn, Delete, Repair, Full Fuel, Flip, Max Upgrade and Force Engine
- World controls: Weather, Time, Freeze Time, Blackout and Area Clear
- Player moderation: Kick and Global Announcement
- Developer tools: Ped/Object spawning, Entity Debug, Delete Aimed Entity and No Ragdoll
- `/copycoords` with Vec3 and Vec4 output
- Hungarian and English UI support
- Optional Discord webhook audit logging
- Server-side permission and input validation
- GitHub Actions CI for Lua, JavaScript, HTML and resource validation

## Installation

### 1. Download the resource

Place the `devpanel` folder inside your FiveM server's `resources` directory.

Example:

```text
resources/
└── ay_devpanel/
    ├── client.lua
    ├── config.lua
    ├── fxmanifest.lua
    ├── server.lua
    └── html/
        ├── app.js
        ├── index.html
        └── style.css
```

### 2. Add it to server.cfg

Add:

```cfg
ensure ay_devpanel
```

### 3. Configure ACE permissions

The default panel permission is:

```cfg
add_ace group.admin aydevpanel.use allow
```

Then assign your admin group:

```cfg
add_principal identifier.license:YOUR_LICENSE group.admin
```

Replace `YOUR_LICENSE` with the player's actual FiveM license identifier.

You can also use the rank-specific ACE permissions defined in `config.lua`, for example:

```cfg
add_ace group.admin devpanel.rank1 allow
add_ace group.admin devpanel.rank2 allow
add_ace group.admin devpanel.rank3 allow
add_ace group.admin devpanel.rank4 allow
add_ace group.admin devpanel.controller allow
add_ace group.developer devpanel.developer allow
```

### 4. Start/restart the resource

From the server console:

```text
ensure ay_devpanel
```

After changing the resource while the server is running:

```text
restart ay_devpanel
```

## How to Use

### Open the panel

You can open the panel in either of these ways:

- Press **F10**
- Use `/devpanel` in chat

The key can be changed in `config.lua`:

```lua
Config.ToggleKeybind = 'F10'
```

### Duty system

Before using most admin tools, you must be on duty.

Use:

```text
/dutyay
```

Or open the panel and use the Duty control.

When duty is enabled, the configured rank outfit is applied. When duty is disabled, the previous player appearance is restored.

### Admin ranks

Ranks are configured in:

```text
devpanel/config.lua
```

Default ranks:

| Rank | Name | Purpose |
|---:|---|---|
| 1 | Admin I | Basic admin tools |
| 2 | Admin II | Advanced player tools |
| 3 | Admin III | Higher-level admin tools |
| 4 | Admin IV | World/moderation tools |
| 5 | Admin Controller | Admin management |
| 6 | Developer | Developer-only tools |

The required rank for each action is controlled by:

```lua
Config.ActionRanks
```

### Set an admin rank

Admin Controller or the server console can use:

```text
/setadminay [player_id] [rank]
```

Examples:

```text
/setadminay 12 3
/setadminay 12 0
```

Rank `0` removes the panel admin rank and disables duty.

### Player tools

The Player section includes:

- **God Mode** — Makes the player invincible.
- **Invisible** — Hides the player.
- **Noclip** — Fly/free movement mode.
- **Freeze Position** — Locks the player in place.
- **Coordinate HUD** — Displays X/Y/Z/heading.
- **Super Jump** — Enables higher jumps.
- **Fast Run** — Increases running speed.
- **Clean Ped** — Removes blood/dirt effects.
- **Kill Self** — Kills the local player.
- **Noclip Speed** — Changes noclip movement speed.
- **Give Weapon** — Gives a valid GTA weapon.

### Teleport tools

The Teleport section supports:

- **Teleport Waypoint** — Teleports to the current map waypoint.
- **Preset TP** — Uses coordinates from `Config.TeleportPresets`.
- **Teleport XYZ** — Enter X, Y and Z coordinates manually.
- **TP To Player** — Teleports yourself to another player.
- **Bring Player** — Teleports another player to you.

### Vehicle tools

The Vehicle section supports:

- **Spawn Vehicle** — Enter a vehicle model name, such as `sultanrs`.
- **Delete Vehicle** — Deletes the vehicle you are currently inside.
- **Fix Vehicle** — Repairs the current vehicle.
- **Full Fuel** — Sets fuel to 100%.
- **Flip Vehicle** — Flips the current vehicle upright.
- **Max Upgrade** — Applies the highest available vehicle mods.
- **Force Engine ON** — Keeps the current vehicle engine running.

### World controls

The World section includes:

- **Set Weather** — Select an allowed weather type.
- **Set Time** — Set hour and minute.
- **Freeze Time** — Keeps the current game time.
- **Blackout** — Controls artificial street/vehicle lighting.
- **Clear Area** — Removes vehicles, peds and objects in the selected radius.

### Player moderation

The Admin / Players section provides:

- **TP To Player**
- **Bring Player**
- **Kick Player**

The Kick action accepts a reason and the server limits its length.

### Announcements

Enter a message in the Communication section and press **Send Announcement**.

The announcement is sent to all players through the FiveM chat system.

The server limits announcement length to prevent oversized input.

### Developer tools

The Developer section is only available to ranks configured with:

```lua
developer = true
```

Available tools include:

- Print Coordinates
- Set Ped Model
- Spawn Object
- Delete Aimed Entity
- No Ragdoll
- Entity Debug Overlay

### Copy coordinates

Use:

```text
/copycoords
```

This outputs/copies a Vec4 coordinate by default.

For Vec3:

```text
/copycoords vec3
```

For Vec4:

```text
/copycoords vec4
```

Clipboard support uses `lib.setClipboard` when available. Without it, the coordinate is shown and printed to the client console.

## Configuration

The main configuration file is:

```text
devpanel/config.lua
```

You can configure:

- Panel name and logo
- Language
- Admin ranks
- Identifier-based admin ranks
- ACE fallback
- Required panel ACE
- Open command
- Duty command
- Copy-coordinates command
- Toggle key
- Default weather/time
- Allowed weather types
- Teleport presets
- Webhook logging
- Required rank for every action
- Duty outfits
- Input safety limits

Example:

```lua
Config.Language = 'en'
Config.OpenCommand = 'devpanel'
Config.DutyCommand = 'dutyay'
Config.ToggleKeybind = 'F10'
```

## Discord Webhook Logging

Webhook logging is optional.

Enable it in `config.lua`:

```lua
Config.EnableWebhookLogs = true
Config.WebhookUrl = 'YOUR_WEBHOOK_URL'
```

Do not publish a private Discord webhook URL in a public repository.

## Security

The NUI is not treated as a security boundary.

Sensitive network actions are validated again on the server, including:

- Panel ACE permission
- Admin rank
- Duty status
- Target player IDs
- Allowed weather values
- Time ranges
- Announcement length
- Kick reason length
- Unknown server actions

Client-side permission checks are only for UI/UX. The server-side checks are the actual authorization layer.

## Update — Version 2.0.0

Version 2.0.0 includes a security, stability and maintenance update.

### Security improvements

- Added stronger server-side action validation.
- Unknown server actions are rejected.
- Weather changes are restricted to configured weather types.
- Time values are clamped to valid GTA/FiveM ranges.
- Target player IDs are validated before teleport, bring and kick operations.
- Players cannot use the panel to target themselves with TP/Bring/Kick actions.
- Announcement messages have a configurable maximum length.
- Kick reasons have a configurable maximum length.
- Server-side rank, ACE and duty checks remain authoritative.

### Client improvements

- Model loading now has a timeout instead of waiting forever.
- Vehicle and object spawning handles failed model loading more safely.
- NUI requests now include basic error handling.
- Noclip speed uses configurable minimum and maximum values.
- Added mobile viewport metadata to the NUI.

### CI improvements

The old Jekyll workflow was replaced with an AY Panel validation workflow.

GitHub Actions now checks:

- Required resource files
- Lua syntax
- JavaScript syntax
- Basic HTML/resource references

### Documentation

- README rewritten in English.
- Added installation instructions.
- Added complete usage instructions.
- Added command documentation.
- Added rank and ACE configuration examples.
- Added security documentation.
- Added Version 2.0.0 update notes.

## Development

The project uses:

- Lua for FiveM client/server logic
- HTML/CSS/JavaScript for the NUI
- FiveM resource manifest via `fxmanifest.lua`
- GitHub Actions for automated validation

## File Structure

```text
devpanel/
├── client.lua
├── config.lua
├── fxmanifest.lua
├── server.lua
└── html/
    ├── app.js
    ├── index.html
    └── style.css
```

## Version

Current version: **2.0.0**
