from devguard.analyzer import analyze_text


def test_detects_http_500():
    findings = analyze_text("GET /api/orders HTTP 500")
    assert findings[0].severity == "CRITICAL"
    assert findings[0].category == "http"


def test_detects_timeout():
    findings = analyze_text("database connection timeout")
    assert findings[0].severity == "WARNING"
    assert findings[0].category == "network"


def test_ignores_normal_log():
    assert analyze_text("INFO server started successfully") == []


def test_line_numbers_are_preserved():
    findings = analyze_text("INFO ok\nERROR database failed")
    assert findings[0].line == 2
