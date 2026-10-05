# Changelog

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
