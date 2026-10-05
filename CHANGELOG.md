# Changelog

## 2.4.0 — 2026-10-05

### Added
- In-panel server-side Audit Log with the latest 100 admin actions.
- Audit entries include timestamp, actor, actor ID, action, target and details.
- Audit log search and category filters.
- Server-side permission checks before audit history is returned.
- Automatic audit records for player actions, server actions, duty changes and admin rank changes.
- Manual Audit Log refresh button.

## 2.3.0 — 2026-10-05

### Discord Integration
- Expanded Discord webhook integration into a structured audit logger.
- Added rich Discord embeds with event titles, colors, fields and timestamps.
- Added player join and leave logging.
- Added AY Panel resource start/stop lifecycle logging.
- Added detailed admin/player action logging with actor, target and action fields.
- Added duty ON/OFF logging with admin rank.
- Added admin rank change logging.
- Added optional identifier logging.
- Added queued webhook delivery with configurable retry count and queue size.
- Disabled Discord mentions by default in webhook payloads.
- Preserved the legacy Config.EnableWebhookLogs / Config.WebhookUrl configuration as a fallback.

### Security
- Discord webhook configuration remains opt-in.
- Player identifiers are not logged unless includeIdentifiers = true.
- Webhook URLs must stay private and should not be committed to the public repository.

## 2.2.0 - Live Player Management
- Added live online player list with ID, ping and staff/duty status.
- Added search and staff filtering.
- Added Spectate, Go To, Bring, Freeze, Heal, Revive, Kill and Kick.
- Added server-side authorization for player actions.
- Added automatic refresh while the panel is open.

## 2.1.0 — 2026-10-05

### Changed
- Bumped AY Panel resource version to 2.1.0.
- Refreshed README installation, permissions, configuration and security documentation.
- Clarified that /setadminay assignments are session-based.

### Security
- Added strict rank normalization and validation.
- Invalid or undefined ranks are rejected before they can enter admin state.
- Identifier-based ranks are now validated against the configured rank table.

### Scope
- AY-FiveM remains completely independent from DevGuard AI.
