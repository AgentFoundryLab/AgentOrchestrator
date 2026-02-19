---
name: hitl
description: Internal shared protocol for human-in-the-loop escalation between sub-agents and orchestrator
user-invocable: false
disable-model-invocation: true
allowed-tools:
  - Read
---

# HITL Escalation Protocol (Shared)

Single source of truth for escalation when an agent needs user input.

## Core Rule

Sub-agents MUST NOT call `AskUserQuestion` directly.
When blocked by missing user input, return a structured QUESTIONS block.

## Required Output Format

```markdown
## QUESTIONS FOR USER

Q1: [Question] *(Required before proceeding)*
- Option A: [description]
- Option B: [description]

Q2: [Question] *(Optional — default: [default])*
- Option A: [description]
- Option B: [description]
```

## Question Rules

- Prefer 1 question; never exceed 3.
- Include clear option trade-offs.
- Mark blocking vs optional explicitly.
- If optional, provide a default.
- Do not continue implementation until blocking questions are answered.

## Orchestrator Relay Contract

When orchestrator receives a QUESTIONS block, it must:
1. Relay each question via `AskUserQuestion`.
2. Collect answers.
3. Re-invoke the same agent with answers prepended to the prompt.
4. Repeat until no QUESTIONS block remains.
