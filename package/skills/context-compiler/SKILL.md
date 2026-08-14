---
name: context-compiler
description: Build compact persisted context bundles for stage work. Use when asked to gather, compile, hydrate, or prepare context for a skill/stage/record, especially before implementation, review, validation, architecture, planning, or reconciliation work.
argument-hint: target skill/stage and record, e.g. implement WO-015
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
context: fork
---

# /context-compiler - Persisted Context Bundles

- Build a focused markdown context bundle at `context/<area>/<record>.md` and pass only that file reference to the next stage/agent.
- Optional pre-work. Other skills must remain usable without depending on it.

## Purpose

- Give the target stage enough context to work safely without flooding the prompt with low-relevance excerpts.
- Normal information flow still applies: `requirements → blueprints → Work Orders → implementation → validation coverage`.
- Use active repo `AGENTS.md` for concrete requirements, blueprint, Work Order, status, and validation paths.

## Inputs

- `$ARGUMENTS`: target skill/stage plus record id, implementation-plan path, issue, PR, validation failure, or drift note.
- Active source docs: `docs/requirements/` (`FRD-*`, `TRD-*`); `docs/architecture/{foundation,feature,system}/` and `docs/architecture/ADR/`; `docs/development/ROADMAP.md`, `plans/`, `workorders/`, `issues/`, `debt/`, `feedback/`; coverage under `docs/validation/`.

## Output

- Write one markdown file: `context/<area>/<record>.md`.
- Examples: `context/implement/wo-015.md`; `context/architect/req-014.md`; `context/reconcile/iss-019.md`.
- Return only the bundle path plus any size warning or blocker. Do not transit the full bundle through the orchestrator prompt when a file reference suffices.

## Core Rules

- Output is for the next working agent, not an audit of the compiler. Keep internal process instructions out of the bundle.
- Avoid filler boilerplate ("not source of truth", "no size warning", threshold explanations) unless there is an actual warning/blocker.
- Use one reference section. Do not duplicate the same paths under both direct refs and related indexes.
- Do not add a generic "Completeness and Risks" section when the implementation plan already has `Risks`; add only concrete missing-context gaps or blockers.
- Do not use arbitrary line budgets. Include the directly scoped contract when correctness needs it.
- Estimate bundle size after assembly. If it exceeds about 20k tokens, add a warning and recommend splitting by target skill or keeping related items indexed until opened on demand.
- Hydrate scoped `REQ`/`AC`/`TR`/`TRC` text from the owning `FRD`/`TRD`, since Work Orders only cross-reference requirements by id.
- Do not bulk-hydrate related artifacts by keyword grep. Prefer a high-level related-items index.
- Preserve authority levels: requirements and blueprints are normative; Work Orders are execution contracts; issues, tech debt, status, and validation are feedback/evidence.
- Do not let downstream status or validation evidence rewrite upstream requirements, blueprints, or Work Order scope. Route conflicts through `$reconcile`.
- Do not edit source artifacts unless the user explicitly asks for that stage update.

## Workflow

### 1. Resolve target

- Identify:
  - target area: `spec`, `architect`, `planner`, `implement`, `validate`, `reconcile`, `orchestrate`, or another explicit skill area;
  - record slug: prefer immutable ids such as `wo-015`, `req-014`, `iss-019`;
  - active contract: Work Order, requirement, blueprint, issue, validation finding, or PR note.
- If multiple plausible active contracts exist and the choice changes source-of-truth, ask one concise question. Otherwise proceed and state the assumption in the bundle.

### 2. Hydrate direct contract

- For a Work Order bundle, include:
  - the WO document and its implementation-plan path when present;
  - summary, current status, in scope, out of scope, `dependsOn`, blueprint refs, test plan;
  - the full scoped requirements text — every referenced `REQ`/`AC`/`TR`/`TRC` hydrated from the owning `FRD`/`TRD`;
  - the governing blueprints and applicable ADRs.
- For non-WO targets, hydrate the direct source artifact and the minimum upstream contract needed to understand it.

### 3. Check cross-referenced requirements

- For each `REQ`/`AC`/`TR`/`TRC` id the Work Order cross-references:
  - confirm the id resolves in `docs/requirements/`, and hydrate its current text into the bundle (full text lives only here, pulled fresh — never copied into the WO);
  - flag any id that no longer exists, or whose brief description in the WO misleads versus source;
  - do not silently rewrite the Work Order unless asked.

### 4. Build related-items index

- Replace broad grep excerpts with index rows. Each row includes:
  - path;
  - authority/relation type (`normative upstream`, `execution predecessor`, `downstream consumer`, `feedback`, `evidence`, `status checkpoint`);
  - relevant ids;
  - why it matters;
  - when to open it.
- Open indexed files only when the target record requires details from that file.

### 5. Handle large derived indexes carefully

- Treat these as large queryable indexes, not context documents:
  - `docs/development/WORKORDERS.md` — the full Work Order table across every Phase;
  - `docs/development/{ISSUES,TECH_DEBT,FEEDBACK}.md` — the feedback indexes;
  - `docs/requirements/REQUIREMENTS.md` — every `REQ`/`TR` row;
  - `docs/development/status/STATUS.md` — the derived rollup;
  - `docs/validation/**` — accumulated coverage documents;
  - `docs/archive/development/**` — closed and decommissioned history;
  - any other large status/evidence index documented by the active repo.
- Rules:
  - Do not paste them wholesale.
  - Do not list them as generic "open this if needed" items.
  - Do not encourage agents to read the entire file.
  - Treat status as a last referential checkpoint, not ground truth. It may be stale.
  - Extract only the rows matching scoped ids already present in the bundle (`REQ-*`, `AC-*`, `TR-*`, `TRC-*`, `FBP-*`, `ADR-*`, `WO-*`, `ISS-*`, `REG-*`, `TD-*`, `FB-*`).
  - Expose only compact filtered rows/fields needed for the target record (id, current status, implementation summary/drift, evidence pointer, stale warning).
  - If no filtered status/evidence extract is needed, include only a warning that the index exists and must be read by scoped ids.

### 6. Estimate size

- Estimate tokens with a conservative approximation such as `characters / 4` when no tokenizer is available.
- Add size as one terse line near the top:

```md
Size: active contract ~N tokens; bundle ~N tokens.
```

- If the bundle exceeds about 20k tokens, add one explicit warning line. Otherwise do not mention thresholds or "no warning." Do not truncate solely to satisfy a target size; split by target skill or move low-authority related content back to the index.

## Bundle Template

```md
# Context Pack: <area> / <record>

Generated: <timestamp>
Target use: <stage/record>

Sources: `<source paths>`
Size: active contract ~N tokens; bundle ~N tokens.

## Active Contract

## Requirements

## Reference Index

## Plan / Execution Digest

## Filtered Status / Validation Checkpoints

Only include rows pre-filtered by scoped ids. Otherwise state: "Not read; use only as a last referential checkpoint."

## Missing Context / Blockers
```

## Validation Checklist

- [ ] Bundle is written under `context/<area>/<record>.md`.
- [ ] Direct contract is hydrated enough for the target stage.
- [ ] Referenced `REQ`/`AC`/`TR`/`TRC` plaintext is hydrated from the owning `FRD`/`TRD` when applicable.
- [ ] Related items are indexed, not pasted by broad keyword grep.
- [ ] Large status/validation indexes are not included wholesale and are only pre-filtered by scoped ids when needed.
- [ ] Size estimate is a terse line; the warning appears only when the bundle exceeds about 20k tokens.
- [ ] The bundle has one non-duplicative reference section.
- [ ] Internal compiler instructions and generic boilerplate are absent from the resulting context.
- [ ] Authority levels and upstream/downstream flow are explicit where they affect which file to open next.
