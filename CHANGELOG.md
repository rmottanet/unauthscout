# Changelog

All notable changes to this project will be documented in this file.

The format follows **Keep a Changelog** and adheres to **Semantic Versioning**.

---

## [v0.1.0] — Initial MVP Release

### Added
- Unauthenticated GitHub user reconnaissance
- Unauthenticated GitLab user reconnaissance
- Provider-based modular architecture
- CLI entry point with explicit orchestration layer
- `--raw` flag to output unprocessed API responses
- Normalized JSON output via explicit schemas
- GitHub user schema (`schemas/github_user.json`)
- GitLab user schema (`schemas/gitlab_user.json`)
- Core helpers for logging and dependency validation

### Documentation
- Comprehensive `README.md` with scope, usage, and design principles
- OSINT flow and mental model documentation
- API raw → normalized field mappings for GitHub and GitLab
- Setup and troubleshooting guide
- Security policy and responsible disclosure guidelines

### Design Notes
- No authentication support by design
- Schemas act as authoritative output contracts
- Clear separation between data retrieval, parsing, and orchestration

### Known Limitations
- Unauthenticated rate limits apply
- Limited to public user endpoints
- No persistence or data enrichment

---

[v0.1.0]: https://github.com/rmottanet/unauthscout/releases/tag/v0.1.0
