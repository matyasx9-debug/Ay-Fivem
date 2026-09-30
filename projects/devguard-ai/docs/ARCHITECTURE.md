# Architecture

## Overview

DevGuard follows a small pipeline:

```text
Input
  ↓
Analyzer
  ↓
Rules
  ↓
Findings
  ↓
CLI / JSON
  ↓
Optional LLM summary
```

## Components

### analyzer.py

Reads text or a file and passes each line through the detection engine. Line numbers are preserved so findings can be traced back to the original log.

### rules.py

Contains the detection rules and the immutable Finding data model.

Current rule groups:

- HTTP 5xx
- authentication failures
- runtime crashes
- network failures
- permission failures
- generic application errors

### cli.py

Provides:

- scan <file>
- --json
- --ai

### llm.py

Contains the optional LLM integration. Provider configuration is read from environment variables.

## Design principles

1. **Local first** — core detection works without a network connection.
2. **AI optional** — users explicitly opt in with --ai.
3. **Small dependencies** — the core uses Python's standard library.
4. **Machine-readable output** — JSON supports automation.
5. **Testable logic** — detection is separated from CLI and network code.

Future features should remain optional layers around the core analyzer.
