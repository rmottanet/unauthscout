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

```

Each step has a **single responsibility** and a clearly defined boundary.


## Step-by-Step Breakdown

### 1. Target Identification

The user provides a target identifier (e.g. username).

UnauthScout does not:
- Guess identities
- Correlate across platforms
- Perform enrichment at this stage

The target is treated as an opaque identifier passed to the provider.


### 2. Provider Selection

The CLI determines which provider module to invoke (e.g. GitHub, GitLab).

Responsibilities:
- Routing
- Flag handling (`--raw`, future output modes)
- Error propagation

The entry point **does not implement reconnaissance logic**.


### 3. Unauthenticated API Request

Each provider module performs:
- A direct request to the public API
- Without authentication
- Without retries or rate-limit evasion

This guarantees:
- Ethical use
- Reproducibility
- Clear trust boundaries


### 4. Raw Response Handling

The raw API response represents **ground truth**.

UnauthScout supports a `--raw` mode to:
- Inspect available fields
- Validate assumptions
- Aid schema evolution

Raw output is intended for **analysis and development**, not automation.


### 5. Normalization

Normalization transforms raw responses into a **stable, minimal contract**.

Principles:
- Only include fields that are consistently available
- Avoid volatile or provider-internal fields
- Prefer identifiers and public-facing attributes

Normalization is implemented via dedicated parser functions and documented
schemas under `schemas/`.


### 6. Structured Output

The final output:
- Is deterministic
- Conforms to a documented schema
- Is suitable for scripting, storage, and downstream tooling

This output is the **primary interface** of UnauthScout.


## Why Schemas Matter

Schemas serve as:
- A contract between providers and consumers
- Documentation of observable behavior
- A guardrail against silent breaking changes

Schemas are authoritative.
Code adapts to schemas, not the other way around.


## What This Flow Does Not Cover

UnauthScout intentionally excludes:
- Authenticated reconnaissance
- Rate-limit handling
- Cross-platform correlation
- Behavioral analysis
- Historical tracking

These concerns belong to higher-level systems built *on top of* this tool.


## Evolution Strategy

Future extensions follow the same flow:
- New provider → new module
- New endpoint → new schema
- New output format → CLI-level concern

The OSINT flow remains unchanged.


## Summary

UnauthScout is designed as a **primitive**:
- Small
- Predictable
- Composable

Its value lies not in the volume of data collected, but in the **clarity and
reliability** of the data it emits.
