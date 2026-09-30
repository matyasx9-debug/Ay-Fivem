import argparse
import json
from .analyzer import analyze_file
from .llm import summarize


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="devguard",
        description="AI-assisted IT incident triage",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    scan = sub.add_parser("scan", help="Analyze a log file")
    scan.add_argument("file")
    scan.add_argument("--json", action="store_true", help="Output machine-readable JSON")
    scan.add_argument("--ai", action="store_true", help="Generate an optional AI summary")

    args = parser.parse_args()

    if args.command == "scan":
        content, findings = analyze_file(args.file)

        if args.json:
            print(json.dumps([f.__dict__ for f in findings], indent=2))
        else:
            if not findings:
                print("No known incident signals detected.")
            for item in findings:
                print(f"{item.severity:<8} {item.category:<10} line {item.line}: {item.message}")

        if args.ai:
            print("\n--- AI INCIDENT SUMMARY ---")
            print(summarize(findings, content))


if __name__ == "__main__":
    main()
