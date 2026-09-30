from dataclasses import dataclass
import re


@dataclass(frozen=True)
class Finding:
    severity: str
    category: str
    message: str
    line: int


RULES = [
    ("CRITICAL", "http", re.compile(r"\b5\d\d\b|HTTP[/ ]5\d\d", re.I), "Server returned an HTTP 5xx response"),
    ("CRITICAL", "security", re.compile(r"(failed|invalid) (ssh )?login|authentication failed|unauthorized", re.I), "Authentication failure detected"),
    ("CRITICAL", "runtime", re.compile(r"traceback|panic:|fatal error", re.I), "Application/runtime crash signal detected"),
    ("WARNING", "network", re.compile(r"timeout|timed out|connection reset|connection refused", re.I), "Network or dependency connectivity problem detected"),
    ("WARNING", "filesystem", re.compile(r"permission denied|access denied|read-only file system", re.I), "Filesystem permission/access problem detected"),
    ("WARNING", "application", re.compile(r"\berror\b|exception|failed", re.I), "Application error detected"),
]


def analyze_line(line: str, line_number: int) -> list[Finding]:
    findings = []
    for severity, category, pattern, message in RULES:
        if pattern.search(line):
            findings.append(Finding(severity, category, message, line_number))
            break
    return findings
