from devguard.llm import redact_sensitive_text


def test_redacts_key_value_secrets():
    text = "password=supersecret api_key=abc123 token=my-token"
    redacted = redact_sensitive_text(text)
    assert "supersecret" not in redacted
    assert "abc123" not in redacted
    assert "my-token" not in redacted
    assert "[REDACTED]" in redacted


def test_redacts_bearer_and_openai_style_keys():
    text = "Authorization: Bearer abc.def.ghi sk-abcdefghijklmnopqrstuvwxyz"
    redacted = redact_sensitive_text(text)
    assert "abc.def.ghi" not in redacted
    assert "sk-abcdefghijklmnopqrstuvwxyz" not in redacted
    assert "[REDACTED]" in redacted or "[REDACTED_OPENAI_KEY]" in redacted
