# Changelog

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
