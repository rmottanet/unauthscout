# OSINT Flow

This document describes the **mental model and operational flow** behind
UnauthScout. It explains *how* and *why* the tool performs reconnaissance,
independent of any specific provider implementation.


## Purpose

UnauthScout is designed to perform **unauthenticated reconnaissance** on public
developer platforms in a predictable, auditable, and automation-friendly way.

The goal is not data exhaustion, but **signal extraction**:
- Does an entity exist?
- Where is it exposed publicly?
- What is the observable surface without credentials?
- **v0.3.0 Enhancement:** What are the aggregated intelligence signals (top languages, total stars, activity patterns)?


## Core Assumptions

- Public APIs expose meaningful reconnaissance data without authentication
- This data is sufficient for early-stage OSINT and profiling
- Normalization is required to make data comparable across providers
- Contracts must reflect **observable reality**, not theoretical API capability
- **v0.3.0 Enhancement:** Unified intelligence schemas enable cross-provider analysis and summarization


## High-Level Flow

```txt
Target
↓
Provider Selection & CLI Orchestration
↓
Unauthenticated API Request
↓
Raw Response
↓
Normalization → Unified Schema
↓
Structured Output OR Intelligence Summary
```

Each step has a **single responsibility** and a clearly defined boundary.

## Step-by-Step Breakdown

### 1. Target Identification

The user provides a target identifier (e.g. username).

UnauthScout does not:

* Guess identities
* Correlate across platforms
* Perform enrichment at this stage

The target is treated as an opaque identifier passed to the provider.

### 2. Provider Selection & CLI Orchestration

The CLI determines which provider module to invoke (e.g., GitHub, GitLab) and orchestrates the intelligence flow.

**Updated Responsibilities (v0.3.0):**
* Routing
* Flag handling (`--raw`, `--repos`, `--summarize`, `--pretty`)
* Output mode selection (raw JSON, formatted report, intelligence summary)
* Error propagation

The entry point **does not implement reconnaissance logic**, but now manages the presentation layer via the integrated report module.

### 3. Unauthenticated API Request

Each provider module performs:

* A direct request to the public API
* Without authentication
* Without retries or rate-limit evasion

This guarantees:

* Ethical use
* Reproducibility
* Clear trust boundaries

### 4. Raw Response Handling

The raw API response represents **ground truth**.

UnauthScout supports a `--raw` mode to:

* Inspect available fields
* Validate assumptions
* Aid schema evolution

**v0.3.0 Enhancement:** The `--pretty` flag formats raw JSON for human readability. Raw output is intended for **analysis and development**, not automation.

### 5. Normalization to Unified Schema

Normalization transforms raw provider responses into a **stable, unified intelligence contract**.

**Updated Principles (v0.3.0):**
* Transform provider-specific data into the unified schema (`unified_user.json`, `unified_repo.json`)
* Only include fields that are consistently available or can be nulled
* Avoid volatile or provider-internal fields
* Prefer identifiers and public-facing attributes
* Map similar concepts to the same unified field names across platforms

Normalization is implemented via dedicated `normalize_*` functions in provider modules, conforming to the authoritative schemas under `schemas/`.

### 6. Structured Output & Intelligence Presentation

The final output adapts based on user flags, offering multiple interfaces:

* **`--raw` (Default):** Compact, unified JSON for scripting and downstream tooling.
* **`--raw --pretty`:** Indented JSON for human analysis.
* **Default (no --raw):** Formatted terminal reports via `lib/report.sh`:
    * Platform-specific user profiles
    * Unified repository listings
* **`--summarize` (requires `--repos`):** Generates an **intelligence summary** aggregating data across enumerated repositories (total stars, top languages, latest activity).

This output remains deterministic and schema-conformant, with the new summary providing **analytical value** beyond raw data listing.

## Repository / Project Enumeration & Intelligence

Repository (GitHub) and project (GitLab) enumeration is a **conditional extension** of the core OSINT flow, activated explicitly via the `--repos` flag.

The introduction of `--summarize` adds an **intelligence layer** on top of enumeration, transforming listed data into actionable insights.

### Trigger Condition

Enumeration occurs only when:

* A valid user/profile is observed on a provider
* The user explicitly requests repository listing (`--repos`)

Intelligence summarization occurs only when:
* Repository enumeration is active (`--repos`)
* The user explicitly requests it (`--summarize`)

This avoids:

* Unnecessary API calls
* Accidental rate-limit exhaustion
* Implicit scope expansion
* Unrequested computational analysis

### Enumeration & Intelligence Flow

```txt
Normalized User Identified
↓
Public Repository / Project Request
↓
Raw Repository Response
↓
Repository Normalization (Unified Schema)
↓
Structured Repository Output
↓
[ Conditional: Intelligence Summarization & Report ]
```

Each repository/project is treated as an **independent observable entity**. The summarization step treats the **entire collection** as a dataset for analysis.

### Enumeration & Intelligence Principles

* Only public repositories/projects are queried.
* Enumeration and summarization are scoped per provider execution.
* No cross-provider correlation is performed automatically.
* No recursive traversal (issues, commits, contributors).
* Intelligence summaries are derived solely from normalized repository data.

The goal evolves from **surface mapping** to **pattern recognition** within the mapped surface.

### Normalization and Contracts

**Updated for v0.3.0:** Repositories and projects are normalized into the **unified repository schema** (`schemas/unified_repo.json`).

Field selection prioritizes:

* Identifiers
* Public URLs
* Popularity and activity signals
* **Cross-provider comparability** (e.g., `stars`, `updated_at`)
* Fields enabling intelligence (e.g., `language`, `topics`)

Detailed field mappings for the unified schemas are documented under:
* `docs/api_maps/unified-user-map.md`
* `docs/api_maps/unified-repo-map.md`

### Output Characteristics

**Updated for v0.3.0:** Repository enumeration output:

* Is emitted as a unified JSON array or a formatted list.
* Preserves ordering as returned by the provider.
* **New:** Can be analyzed to produce a terminal-based intelligence summary.
* Raw unified output (`--raw`) remains available for inspection.

## Why Schemas Matter

Schemas serve as:

* A contract between providers, normalization, and intelligence layers.
* Documentation of observable behavior.
* A guardrail against silent breaking changes.
* **v0.3.0 Role:** The **unified schemas** are the single source of truth for the intelligence layer, enabling reliable cross-provider analysis.

Schemas are authoritative. Code adapts to schemas, not the other way around.

## The Intelligence Layer (v0.3.0)

A new layer has been introduced, implemented in `lib/report.sh`. Its responsibilities are strictly separated:

1.  **Presentation:** Formatting normalized data for terminal output (`render_user_report`, `render_repos_list`).
2.  **Analysis:** Aggregating normalized repository data to answer specific OSINT questions (`render_intel_summary`).

This layer does not fetch data, handle errors, or manage schemas. It transforms structured data into human-readable reports and insights.

## What This Flow Does Not Cover

UnauthScout intentionally excludes:

* Authenticated reconnaissance
* Rate-limit handling
* **Automatic** cross-platform correlation (summary is per-provider)
* Behavioral analysis beyond static repository metadata
* Historical tracking
* Deep repository inspection (issues, commits, CI)

These concerns belong to higher-level systems built *on top of* this tool.

## Evolution Strategy

Future extensions follow the same flow:

* New provider → new module → normalization to **unified schema**
* New endpoint → new schema
* New output format or intelligence → CLI & report layer concern

The OSINT flow remains stable; the intelligence layer extends it without alteration.

## Summary

UnauthScout is designed as a **primitive**:

* Small
* Predictable
* Composable

With v0.3.0, its value is enhanced: it provides not only **clarity and reliability** of the collected data but also **actionable intelligence** derived from that data through a structured, schema-driven pipeline.
