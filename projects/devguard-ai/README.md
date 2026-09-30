# 🛡️ DevGuard AI

[![CI](https://github.com/matyasx9-debug/Ay-Fivem/actions/workflows/devguard-ai.yml/badge.svg)](https://github.com/matyasx9-debug/Ay-Fivem/actions/workflows/devguard-ai.yml)
[![Python](https://img.shields.io/badge/python-3.11%2B-blue.svg)](https://www.python.org/)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](../../LICENSE)

**AI-assisted IT incident triage from the terminal.**

DevGuard AI turns raw application and server logs into structured findings. It works locally without an AI provider and can optionally generate an incident summary through an OpenAI-compatible API.

> **Status:** Early-stage open-source project. The rule engine is usable now; the AI layer is intentionally optional.

## ✨ Features

- 🔎 Local log analysis with no API key required
- 🚨 Detects HTTP 5xx responses, failed authentication, crashes, timeouts and permission errors
- 🧭 Classifies findings by severity
- 📦 JSON output for scripts and automation
- 🤖 Optional LLM-powered incident summaries
- 🔐 AI mode is opt-in
- 🧪 Automated unit tests
- ⚙️ GitHub Actions CI
- 🐍 Python 3.11+ with a lightweight standard-library core

## 🎯 Use cases

- Developers debugging an application
- Students learning IT/SRE concepts
- Homelab and self-hosted services
- Small server environments
- Incident-triage experiments
- CI/CD log inspection

DevGuard is **not** a replacement for a SIEM, EDR, observability platform or human security investigation.

## 🚀 Quick start

### Requirements

- Python 3.11+
- pip

```bash
git clone https://github.com/matyasx9-debug/Ay-Fivem.git
cd Ay-Fivem/projects/devguard-ai
python -m pip install -e ".[dev]"
```

Run the sample:

```bash
python -m devguard scan examples/sample.log
```

Example:

```text
WARNING  network     line 2: Network or dependency connectivity problem detected
WARNING  application line 3: Application error detected
CRITICAL http        line 4: Server returned an HTTP 5xx response
CRITICAL security    line 5: Authentication failure detected
```

## 📦 CLI

### Scan a log

```bash
python -m devguard scan path/to/server.log
```

### JSON output

```bash
python -m devguard scan path/to/server.log --json
```

### Optional AI summary

```bash
export OPENAI_API_KEY="your-key"
export DEVGUARD_MODEL="gpt-4.1-mini"
python -m devguard scan examples/sample.log --ai
```

For an OpenAI-compatible provider:

```bash
export DEVGUARD_BASE_URL="https://your-provider.example/v1"
export OPENAI_API_KEY="your-key"
export DEVGUARD_MODEL="your-model"
```

The core analyzer does not require an AI provider.

## 🧠 How it works

```text
Log file
   │
   ▼
Local parser
   │
   ▼
Detection rules
   │
   ├── HTTP errors
   ├── Authentication failures
   ├── Runtime crashes
   ├── Network failures
   ├── Permission errors
   └── Application errors
   │
   ▼
Structured findings
   ├── Terminal output
   ├── JSON output
   └── Optional AI summary
```

The rule engine runs locally first. The LLM is only contacted when `--ai` is supplied.

## 🏗️ Project structure

```text
devguard-ai/
├── devguard/
│   ├── __init__.py
│   ├── analyzer.py
│   ├── cli.py
│   ├── llm.py
│   └── rules.py
├── examples/
├── tests/
├── docs/
│   ├── ARCHITECTURE.md
│   └── CONFIGURATION.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── SECURITY.md
├── LICENSE
├── .gitignore
└── pyproject.toml
```

## 🔐 Security and privacy

Logs can contain credentials, tokens, IP addresses and personal data.

Before using AI mode:

1. Review the log.
2. Remove secrets and sensitive information.
3. Confirm that sending the data to your selected provider is allowed.
4. Use a provider and model appropriate for your environment.

AI mode is never required for local detection.

See [SECURITY.md](SECURITY.md) for vulnerability reporting.

## 🧪 Development

```bash
python -m pytest -q
python -m devguard scan examples/sample.log
```

GitHub Actions runs the test suite and sample CLI check for changes under `projects/devguard-ai/`.

## 🗺️ Roadmap

- [x] Local rule-based analyzer
- [x] JSON output
- [x] Optional LLM summaries
- [x] Unit tests
- [x] GitHub Actions CI
- [ ] Secret redaction before AI requests
- [ ] YAML/TOML rule configuration
- [ ] Docker image
- [ ] Web dashboard
- [ ] Streaming log input
- [ ] Pluggable alert integrations
- [ ] PyPI release

Roadmap items are goals, not guarantees.

## 🤝 Contributing

Contributions are welcome.

Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening an issue or pull request.

Good first contributions include detection rules, tests, documentation, additional log parsers, JSON improvements and safe redaction logic.

## 📜 License

DevGuard AI is released under the [Apache License 2.0](../../LICENSE).

## 👤 Maintainer

Built and maintained by **matyasx9-debug** as an open-source AI/IT project.

Main repository: https://github.com/matyasx9-debug/Ay-Fivem
