# Feature Requirements: Skill Interface

## Overview

Skills are the procedural layer: each one encodes how a stage of work is actually done, so the instruction lives in a versioned file rather than in a prompt someone retypes. A skill is invocable by the user directly and, where it owns an artifact, forks into the agent that owns that role.

The interface matters more than the catalogue. A skill declares its tools, whether a user can invoke it, whether it forks, and which agent it forks into — and the installer transforms that declaration into each runtime's native format. That is what lets one authored skill run on five runtimes without a per-runtime copy.

## Terminology

- **Agent-backed skill**: declares `agent:` and `context: fork`, so invoking it runs the named agent with the skill as its task.
- **Inline skill**: no `agent:`, so it runs in the calling session. Retrieval, audit, and orchestration skills are inline because forking would lose the caller's context or its ability to spawn.
- **Frontmatter transform**: the installer's per-runtime rewrite of skill frontmatter, dropping keys a runtime does not understand and mapping tool names.

## Requirements

### REQ-002: Runtime-portable skill interface

**User Story:** As an operator, I want skills authored once and installed to any supported runtime, so that switching runtime does not mean rewriting the workflow.

**Acceptance Criteria:**

- **AC-002.1:** Skills are defined as `package/skills/<name>/SKILL.md` with frontmatter declaring at minimum `name` and `description`, and install to every supported runtime root.
- **AC-002.2:** A skill's `name` shall match its directory name, so invocation and location never diverge.
- **AC-002.3:** When installing to a runtime that does not support a frontmatter key, the installer shall strip that key rather than emit an unparseable file.
- **AC-002.4:** When a skill declares `agent:`, that agent shall exist in the installed set; when an agent declares a skill, that skill shall exist.
- **AC-002.5:** A skill that owns an artifact shall declare the agent that owns that role; a skill that must retain the caller's session or spawn sub-agents shall run inline.
- **AC-002.6:** Skills shall bundle their own scripts and references, and read shared artifact templates from the runtime root's `templates/` directory.
