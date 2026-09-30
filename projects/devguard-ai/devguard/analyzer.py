from pathlib import Path
from .rules import Finding, analyze_line


def analyze_text(text: str) -> list[Finding]:
    findings: list[Finding] = []
    for number, line in enumerate(text.splitlines(), start=1):
        findings.extend(analyze_line(line, number))
    return findings


def analyze_file(path: str) -> tuple[str, list[Finding]]:
    content = Path(path).read_text(encoding="utf-8", errors="replace")
    return content, analyze_text(content)
