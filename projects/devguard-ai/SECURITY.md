# Security Policy

## Supported versions

| Version | Supported |
|---|---|
| 0.1.x | Yes |

## Reporting a vulnerability

Do **not** publish exploitable security vulnerabilities in a public issue.

Use GitHub's private vulnerability reporting/security advisory features when available. If private reporting is unavailable, contact the repository maintainer through GitHub before public disclosure.

Include the affected version, description, reproduction steps, impact and relevant sanitized evidence.

## Sensitive data

Never include API keys, passwords, access tokens or private customer data in public issues, pull requests or examples.

AI mode may transmit selected log content to the configured provider. Review and sanitize logs before using it.

## Security design

The core analyzer is local. Network access is only needed when the optional --ai feature is explicitly requested.
