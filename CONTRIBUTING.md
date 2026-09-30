# Contributing to AY Developer Panel

Thanks for contributing to AY Developer Panel.

## Development workflow

1. Fork or create a feature branch from `main`.
2. Make one focused change at a time.
3. Keep client, server, NUI, and configuration changes clearly separated when practical.
4. Update the README when user-facing behavior changes.
5. Run the repository CI checks before opening a pull request.
6. Open a pull request with a clear title and description.

## Pull requests

A useful pull request should explain:
- What changed
- Why it changed
- How it was tested
- Any configuration or migration steps

Keep unrelated formatting changes out of feature PRs.

## FiveM safety

Sensitive server actions must remain protected by server-side authorization. Never trust NUI/client input for permissions.

Do not commit:
- Discord webhook URLs
- API tokens
- passwords
- server credentials
- personal data

## Code style

Prefer small, readable functions and descriptive names. Preserve the existing project structure unless there is a clear reason to change it.
