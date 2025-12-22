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


## Core Assumptions

- Public APIs expose meaningful reconnaissance data without authentication
- This data is sufficient for early-stage OSINT and profiling
- Normalization is required to make data comparable across providers
- Contracts must reflect **observable reality**, not theoretical API capability


## High-Level Flow

```txt
Target
↓
Provider Selection
↓
Unauthenticated API Request
↓
Raw Response
↓
Normalization (Schema)
↓
Structured Output
````

Each step has a **single responsibility** and a clearly defined boundary.

## Step-by-Step Breakdown

### 1. Target Identification

The user provides a target identifier (e.g. username).

UnauthScout does not:

* Guess identities
* Correlate across platforms
* Perform enrichment at this stage

The target is treated as an opaque identifier passed to the provider.

### 2. Provider Selection

The CLI determines which provider module to invoke (e.g. GitHub, GitLab).

Responsibilities:

* Routing
* Flag handling (`--raw`, `--repos`)
* Error propagation

The entry point **does not implement reconnaissance logic**.

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

Raw output is intended for **analysis and development**, not automation.

### 5. Normalization

Normalization transforms raw responses into a **stable, minimal contract**.

Principles:

* Only include fields that are consistently available
* Avoid volatile or provider-internal fields
* Prefer identifiers and public-facing attributes

Normalization is implemented via dedicated parser functions and documented
schemas under `schemas/`.

### 6. Structured Output

The final output:

* Is deterministic
* Conforms to a documented schema
* Is suitable for scripting, storage, and downstream tooling

This output is the **primary interface** of UnauthScout.

## Repository / Project Enumeration

Repository (GitHub) and project (GitLab) enumeration is a **conditional extension**
of the core OSINT flow, activated explicitly via the `--repos` flag.

This phase follows the **same mental model** as profile reconnaissance and does
not introduce a new class of behavior.

### Trigger Condition

Enumeration occurs only when:

* A valid user/profile is observed on a provider
* The user explicitly requests repository listing (`--repos`)

This avoids:

* Unnecessary API calls
* Accidental rate-limit exhaustion
* Implicit scope expansion

### Enumeration Flow

```txt
Normalized User Identified
↓
Public Repository / Project Request
↓
Raw Repository Response
↓
Repository Normalization (Schema)
↓
Structured Repository Output
```

Each repository/project is treated as an **independent observable entity**.

### Enumeration Principles

* Only public repositories/projects are queried
* Enumeration is scoped per provider
* No cross-provider correlation is performed
* No recursive traversal (issues, commits, contributors)

The goal is **surface mapping**, not deep inspection.

### Normalization and Contracts

Repositories and projects are normalized into provider-specific but semantically
aligned schemas:

* `schemas/github_user_repos.json`
* `schemas/gitlab_user_repos.json`

Field selection prioritizes:

* Identifiers
* Public URLs
* Popularity and activity signals
* Cross-provider comparability

Detailed field mappings are documented under:

* `docs/api_maps/github_repo_map.md`
* `docs/api_maps/gitlab_repo_map.md`

### Output Characteristics

Repository enumeration output:

* Is emitted as a stream of normalized objects
* Preserves ordering as returned by the provider
* Can be consumed incrementally by downstream tooling

Raw output (`--raw`) remains available for inspection and schema evolution.

## Why Schemas Matter

Schemas serve as:

* A contract between providers and consumers
* Documentation of observable behavior
* A guardrail against silent breaking changes

Schemas are authoritative.
Code adapts to schemas, not the other way around.

## What This Flow Does Not Cover

UnauthScout intentionally excludes:

* Authenticated reconnaissance
* Rate-limit handling
* Cross-platform correlation
* Behavioral analysis
* Historical tracking
* Deep repository inspection (issues, commits, CI)

These concerns belong to higher-level systems built *on top of* this tool.

## Evolution Strategy

Future extensions follow the same flow:

* New provider → new module
* New endpoint → new schema
* New output format → CLI-level concern

The OSINT flow remains stable.

## Summary

UnauthScout is designed as a **primitive**:

* Small
* Predictable
* Composable

Its value lies not in the volume of data collected, but in the **clarity and
reliability** of the data it emits.

