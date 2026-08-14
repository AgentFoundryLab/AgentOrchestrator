# Feature Requirements: Session Context and Memory

## Overview

Agents lose everything between sessions unless something writes it down. This feature covers what the runtime injects at session start, where session evidence lands, and what survives as durable project knowledge.

The distinction that matters is between evidence and knowledge. Session transcripts and logs are evidence — read-only, never committed, occasionally huge. Project knowledge is authored, versioned, and small. Conflating them produces a repository full of transcripts and a knowledge base full of noise.

## Terminology

- **Session evidence**: transcripts and hook logs under the runtime's own session directories and `logs/`. Read-only, never committed.
- **Project knowledge**: authored documents under `docs/knowledge/` — domain, patterns, runbooks, and TDR decisions.
- **Memory store**: the optional project-scoped store an MCP memory provider supplies.

## Requirements

### REQ-005: Session context injection and durable project knowledge

**User Story:** As an agent, I want the session's identity and the project's accumulated knowledge available at start, so that I do not re-derive context that was already established.

**Acceptance Criteria:**

- **AC-005.1:** `$meta-learn` shall write durable findings to versioned memos under `docs/analysis/`, and may additionally write to a project memory store when one is configured.
- **AC-005.2:** On `SessionStart` the system shall make relevant project knowledge discoverable to the session.
- **AC-005.3:** On `Stop` the system shall prompt for session-level learning, able to invoke a skill.
- **AC-005.4:** On `SessionStart` the system shall inject `PROJECT_NAME`, derived from the working directory as a path slug.
- **AC-005.5:** Session evidence shall be located under the active runtime's own session directory, and shall never be copied into the repository.
- **AC-005.6:** On `SessionStart` the system shall inject the session identifier for skills to reference.
- **AC-005.7:** `$meta-learn` shall locate and read the session transcript from that identifier.
- **AC-005.8:** The agent identifier shall be recoverable from the runtime's own logs, and sub-agent transcripts shall be attributable to their parent session.
- **AC-005.9:** On `SessionEnd` the system shall capture session state for later analysis, non-blocking.
