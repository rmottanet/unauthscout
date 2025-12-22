# Changelog

All notable changes to this project will be documented in this file.

The format follows **Keep a Changelog** and adheres to **Semantic Versioning**.

---

## [v0.2.0] — Repository Enumeration Release

### Added
- **Public repository enumeration for GitHub** – Unauthenticated repository listing via `/users/{username}/repos`
- **Public project enumeration for GitLab** – Unauthenticated project listing via `/users/{username}/projects`
- **New CLI flag `--repos`** – Opt-in repository/project enumeration after successful user reconnaissance
- **Repository output schemas** – Normalized contracts for cross-provider consistency:
  - `schemas/github_user_repos.json`
  - `schemas/gitlab_user_repos.json`
- **Enhanced provider orchestration** – Combined user and repository flows with explicit scope control
- **Integration test suites** – Live API validation for repository endpoints across both providers

### Enhanced
- **CLI interface** – Extended with repository-specific execution paths while maintaining backward compatibility
- **OSINT flow documentation** – Updated mental model to include asset surface discovery phase
- **API field mapping documentation** – Comprehensive raw-to-normalized mappings for repository responses
- **Setup and usage guides** – Examples and troubleshooting for new enumeration capabilities

### Design Notes
- Repository enumeration is **explicit and opt-in** (`--repos` flag required)
- No authentication logic or rate-limit evasion mechanisms introduced
- Raw provider responses remain inspectable via `--raw` flag
- Schemas act as authoritative output contracts; code conforms to contracts
- Strict separation between user reconnaissance and asset enumeration phases
- No implicit scope expansion or recursive traversal

### Documentation
- Extended API field mappings for GitHub repositories and GitLab projects
- Updated OSINT flow to include conditional repository enumeration step
- Enhanced setup guide with new flag usage, examples, and edge cases
- All documentation references upstream provider APIs as authoritative sources

### Known Limitations
- Subject to unauthenticated API rate limits (stricter for repository endpoints)
- Limited to publicly accessible repositories/projects
- No cross-provider correlation or deduplication logic
- No repository content analysis or metadata enrichment
- Pagination not implemented (first page only)

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

[v0.2.0]: https://github.com/rmottanet/unauthscout/releases/tag/v0.2.0
[v0.1.0]: https://github.com/rmottanet/unauthscout/releases/tag/v0.1.0
