# DevGuard AI

AI-assisted IT incident triage from the terminal.

DevGuard AI scans application/server logs, detects common operational and security signals, produces structured findings, and can optionally ask an OpenAI-compatible LLM for a concise incident summary.

## Why this project?

AI developer tooling and production-focused Python are major open-source trends. DevGuard combines both with a practical IT/SRE use case.

## Features

- Fast local log scanning with no AI/API required
- Detects errors, HTTP 5xx responses, timeouts, failed logins, permission errors, tracebacks and panics
- Severity classification: INFO / WARNING / CRITICAL
- JSON output for automation
- Optional LLM incident summary
- Safe-by-default: log contents are never sent to an LLM unless `--ai` is explicitly used
- Standard-library Python implementation
- Unit tests

## Quick start

```bash
python -m devguard scan examples/sample.log
python -m devguard scan examples/sample.log --json
```

Optional AI summary:

```bash
export OPENAI_API_KEY="your-key"
export DEVGUARD_MODEL="gpt-4.1-mini"
python -m devguard scan examples/sample.log --ai
```

For OpenAI-compatible providers, set `DEVGUARD_BASE_URL`.

## Example

```text
CRITICAL  Failed SSH login from 203.0.113.42
CRITICAL  HTTP 500 /api/orders
WARNING   Connection timeout to database
```

DevGuard turns raw logs into actionable findings without replacing human investigation.

## Project structure

```text
devguard-ai/
├── devguard/
│   ├── analyzer.py
│   ├── cli.py
│   ├── llm.py
│   └── rules.py
├── examples/
├── tests/
└── pyproject.toml
```

## Security

Do not paste secrets, access tokens, private keys or personal data into logs.

AI mode is opt-in. Review logs before sending them to an external provider.

## License

MIT
