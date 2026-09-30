# Contributing to DevGuard AI

Thanks for contributing.

## Development setup

```bash
cd projects/devguard-ai
python -m pip install -e ".[dev]"
python -m pytest -q
```

Python 3.11 or newer is required.

## Workflow

1. Create a topic branch.
2. Make a focused change.
3. Add or update tests.
4. Run the test suite.
5. Update documentation when behavior changes.
6. Open a pull request.

## Code guidelines

- Prefer small, readable functions.
- Keep the core dependency-light.
- Never hard-code secrets.
- Keep AI functionality optional.
- Avoid sending sensitive data unnecessarily.
- Add regression tests for bug fixes.

## Pull requests

Explain what changed, why it changed, how it was tested, and any security/privacy implications.

## New detection rules

1. Add the rule to devguard/rules.py.
2. Add a test.
3. Include a representative example.
4. Document user-visible behavior.

Remove credentials, tokens and private information from logs before posting them.
