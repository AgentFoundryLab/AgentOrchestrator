# AgentOrchestrator Vision

**Version**: 0.2.0
**Updated**: 2026-08-14

---

## Problem

AI coding assistants operate in single-turn mode: no persistent memory, no structured workflows, no self-validation. Users bear the orchestration burden.

## Vision

**"From assistant to orchestrator"**

Orchestrator turns a single-turn coding assistant into an autonomous software engineering
orchestrator that:
- Coordinates specialized agents through defined workflows, on any of five runtimes
- Gates its own work at a validation stage the implementing agent does not own
- Learns from what actually happened, by reading its own session transcripts
- Persists knowledge across sessions as versioned files

## Technical Architecture Vision

True multi-agent system with independent, observable agents coordinated through workflow orchestration. Strands Agents framework with L1 Workflow, L2 Graph, and L3 Swarm coordination. Subscription-based authentication via custom Claude SDK provider and CLI wrappers for other providers.

**Architecture Pillars**:
- **MCP**: Agent ↔ Tools/Resources (client-server)
- **A2A**: Orchestrator ↔ Agent (task-based coordination)
- **Strands Framework**: L1 Sequential/DAG, L2 Conditional routing, L3 Autonomous mesh

## Target Users

Solo developers and small teams who want AI-assisted development with standardized processes and built-in validation.

## OKRs

**Objective**: Transform Claude Code into a self-orchestrating development partner by v0.1.0

**Key Results**:
1. Context setup overhead → -50%
2. End-to-end workflow completion → >80%
3. Same-class error recurrence → -70%

**Initiatives**:
- Multi-agent orchestration with specialized roles
- Hook-based validation at workflow boundaries
- Session-transcript-driven error pattern learning

## Principles

1. **Minimal** - Ship the smallest useful system (9 agents, 23 skills)
2. **Self-contained** - No external services beyond MCPs
3. **Self-validating** - Delivery always passes through validation and a security gate, owned by
   agents that cannot edit the code they judge. Hooks remind; they do not enforce (`ADR-FND-001`).
4. **Self-learning** - Failures are read back from session transcripts and turned into instruction
   changes, applied only on approval

---

See: [BLUEPRINT.md](BLUEPRINT.md) | [REQUIREMENTS.md](../requirements/REQUIREMENTS.md) | [ROADMAP.md](../development/ROADMAP.md)
