# Feature Requirements: Agent System

## Overview

AgentOrchestrator turns a single-turn assistant into an orchestrated multi-agent system by shipping named agents with explicit role boundaries. Each agent owns one stage of the delivery workflow, produces a typed artifact, and refuses work that belongs to a neighbouring role — so a request that spans requirements, design, and implementation is decomposed across agents rather than answered in one undifferentiated pass.

Agents are source artifacts in this repository, installed into whichever runtime roots the operator selects. The value is not the agent count but the boundaries: an agent that cannot write code cannot quietly redesign the architecture, and an agent that cannot set status cannot declare its own work validated.

## Terminology

- **Agent**: an installed role definition with a name, description, tool allowance, and skill list. Invoked through the host runtime's sub-agent primitive.
- **Role boundary**: the explicit will/won't contract in an agent profile. A boundary is enforceable only if the agent's tool allowance matches it.
- **Delivery agent**: an agent that changes product code — currently only Developer.

## Requirements

### REQ-001: Installable agents with enforced role boundaries

**User Story:** As an operator, I want named agents with explicit boundaries, so that each stage of delivery is owned by one role that cannot silently absorb another's work.

**Acceptance Criteria:**

- **AC-001.1:** Agents are defined as source artifacts under `package/agents/` and install to every supported runtime root.
- **AC-001.2:** When the host runtime provides a sub-agent primitive, the system shall invoke an agent through it by the agent's declared name.
- **AC-001.3:** Every agent profile shall declare explicit will/won't boundaries, and its tool allowance shall be consistent with them — an agent whose boundary forbids editing shall not be granted an edit tool.
- **AC-001.4:** Every agent shall produce a typed artifact, or return a report, and never both silently.
- **AC-001.5:** An agent shall invoke its corresponding skill, and may invoke additional skills and tools its allowance permits.
- **AC-001.6:** Only `$status-update` shall set a record's status; every other agent's profile shall forbid it.
- **AC-001.7:** When an agent is spawned as a delegated sub-agent, it shall execute only the assigned slice and return changed artifacts, blockers, skipped scope, and residual risk.
