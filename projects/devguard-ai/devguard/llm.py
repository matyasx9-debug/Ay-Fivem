import json
import os
import urllib.request


def summarize(findings, log_text: str) -> str:
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError("OPENAI_API_KEY is required for --ai")

    base_url = os.getenv("DEVGUARD_BASE_URL", "https://api.openai.com/v1").rstrip("/")
    model = os.getenv("DEVGUARD_MODEL", "gpt-4.1-mini")

    finding_text = "\n".join(
        f"- {item.severity}: {item.category}: {item.message} (line {item.line})"
        for item in findings
    )

    prompt = (
        "You are an IT incident triage assistant. Based only on these findings "
        "and log excerpt, return: likely cause, evidence, immediate checks, and "
        "safe next steps. Do not invent facts.\n\n"
        f"Findings:\n{finding_text}\n\n"
        f"Log excerpt:\n{log_text[-12000:]}"
    )

    payload = json.dumps({
        "model": model,
        "messages": [
            {"role": "system", "content": "Be concise, factual and security-conscious."},
            {"role": "user", "content": prompt},
        ],
        "temperature": 0.1,
    }).encode()

    request = urllib.request.Request(
        f"{base_url}/chat/completions",
        data=payload,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}",
        },
        method="POST",
    )

    with urllib.request.urlopen(request, timeout=30) as response:
        data = json.load(response)

    return data["choices"][0]["message"]["content"].strip()
