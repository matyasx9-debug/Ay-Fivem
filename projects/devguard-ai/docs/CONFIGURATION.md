# Configuration

DevGuard requires no configuration for local scanning.

## Environment variables

| Variable | Required | Description |
|---|---|---|
| OPENAI_API_KEY | Only with --ai | API credential for the selected provider |
| DEVGUARD_MODEL | No | Model name; defaults to gpt-4.1-mini |
| DEVGUARD_BASE_URL | No | OpenAI-compatible API base URL |

Example:

```bash
export OPENAI_API_KEY="your-key"
export DEVGUARD_MODEL="gpt-4.1-mini"
python -m devguard scan examples/sample.log --ai
```

## Security

Never commit API keys to Git.

Review logs before enabling --ai because the selected log excerpt can be transmitted to an external provider.
