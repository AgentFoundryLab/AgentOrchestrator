---
name: anneal
description: Audit code scopes for complexity, duplication, contradictions, weak requirements, unsafe abstractions, source-of-truth drift, caller-side patches, dead-looking surface, and simplification opportunities. Use when asked to anneal, purge inconsistencies, reduce vibe-coded duplication, challenge implicit requirements, simplify modules, identify architectural/design drift, or plan safe removal/refactoring without maintaining custom static-analysis rules.
---

# Anneal

- Turn messy implementation areas into a ranked simplification plan.
- Default: audit and plan; do not edit code unless the user explicitly asks for implementation after the plan.

## Principles

- Model the domain before judging code: name concepts, ownership, lifecycle/status, source of truth, invariants, allowed interfaces.
- Best part is no part: prefer deletion or consolidation over new machinery.
- Refactor first: prefer changing, deleting, moving, or consolidating existing owners before adding files, helpers, wrappers, flags, mappings, fixtures, or parallel flows.
- Good signs: compact representation, clear boundaries, small interfaces. Smells: bloated overlay code, duplicate mappings, fallback chains, caller-side patches.
- Explicit user-confirmed requirements are the main drivers.
- Challenge implicit, weak, stale, or decorative requirements.
- Treat complicated design as a symptom to investigate.
- Keep abstractions only when they simplify callers, behavior, or validation.
- Fix behavior at the source of truth; do not preserve complexity by recommending duplicate normalization, query, rendering, validation, dedup, or fallback logic at callers.
- Preserve critical paths: identify blast radius before recommending removal.

## Minimal Tool Baseline

Use without custom repo rules or maintained analyzer configs:

1. `codebase-memory-mcp` for structural navigation, callers/callees, related symbols, blast-radius checks.
2. `jscpd` for duplicated TypeScript/JavaScript code and vibe-coded clone clusters.
3. `lizard` for cyclomatic complexity, long functions, dense functions.
4. LLM judgement for contradictions, unnecessary abstractions, weak requirements, and whether a simplification is actually safer.

- Do not add dependency-cruiser, custom lint rules, ast-grep rule packs, Vale styles, or SonarJS as default baseline. For deeper dead-code/cycle analysis on request, recommend an explicit second pass rather than expanding the baseline silently.

## Workflow

1. **Confirm scope from the request.** Accept path, changed files, feature area, route, module, or task id. If scope is broad, start with candidate heavy modules instead of reading the whole repo.
2. **Map domain and structure first.** Identify relevant concepts, canonical owners, lifecycle/status states, source of truth, invariants, allowed interfaces. Use `codebase-memory-mcp cli ...` before broad grep/read:
   ```bash
   codebase-memory-mcp cli list_projects '{}'
   codebase-memory-mcp cli search_graph '{"project":"<project>","name_pattern":".*Target.*"}'
   codebase-memory-mcp cli trace_path '{"project":"<project>","function_name":"Target","direction":"both","depth":3}'
   ```
   Locate existing owners before recommending any new module, helper, component, fixture, schema, mapping, or data shape. Re-index or report staleness if graph and source disagree. Source/tests remain authoritative.
3. **Collect quantitative metrics.** Prefer the bundled helper:
   ```bash
   node scripts/collect_anneal_metrics.mjs <paths...>
   ```
   Run from this skill directory or resolve `scripts/collect_anneal_metrics.mjs` relative to this `SKILL.md`. Add `--allow-ephemeral-tools` only when the user allows `npx`/`uvx` downloads for missing tools.
4. **Read exact source slices.** Inspect top duplicate spans, high-CCN functions, and their callers before judging.
5. **Cluster issues.** Group by domain concept, owner/module, function, and call path, not by tool output. Identify repeated behavior, repeated query shapes, duplicated mappings, fallback chains, caller-side patches, branching hotspots, state/lifecycle contradictions, over-general abstractions.
6. **Rank recommendations.** Score qualitatively by severity, confidence, blast radius, critical-path risk, simplification potential. Prefer owner-level deletion, merge, move, or source-of-truth fixes over caller overlays.
7. **Output an annealing plan.** For each cluster name the owner/source of truth and choose one action: `drop`, `merge`, `simplify`, `isolate`, `defer`, `block pending requirement clarification`, or `block pending architecture review`.

## Judgement Rules

- A duplicated block is not automatically wrong; first check whether it is one concept split by accident.
- A high-complexity function is not automatically a refactor target if splitting would hide invariants or multiply call paths.
- A helper abstraction is suspect when it increases indirection without reducing branches, parameters, or caller knowledge.
- New code is justified only when it clarifies a boundary/interface or removes/replaces more complexity than it adds.
- If source of truth or abstraction boundary is unclear, block pending Architect / architecture review; do not recommend overlay code.
- When replacing behavior, remove the superseded path in the same scoped change unless requirements demand temporary coexistence; then name the removal trigger.
- Prefer extending canonical tests and fixtures over cloned scenarios.
- Dead-looking exports require blast-radius checks and tests before deletion; mark them as candidates, not facts.
- If code implements a weak/implicit requirement, call that out instead of preserving complexity around it.
- If a simplification could affect auth, billing, data lifecycle, migrations, or user-visible critical paths, mark it high-risk and require targeted validation.

## Reporting Format

Report concise findings first:

```markdown
## Anneal Findings

1. <cluster name> — <severity/confidence>
   Domain/owner: <concept, source of truth, invariant/interface, uncertainty>.
   Evidence: <file:line>, metric summary, callers/blast radius.
   Why it matters: <duplication/complexity/contradiction/source-of-truth drift>.
   Plan: <drop|merge|simplify|isolate|defer|block>; <superseded path/removal trigger if applicable>.
   Validation: <focused canonical tests/checks needed>.

## Metrics Coverage
- jscpd: <ran/skipped, summary>
- lizard: <ran/skipped, summary>
- codebase-memory-mcp: <used/stale/skipped>

## Residual Risks
- <unknowns, missing tools, unvalidated assumptions>
```

- Keep the report dense. Do not paste full tool output unless the user asks.

## Relationship to Docs

- `anneal` may flag contradictions between code and docs, but must not compress documentation.
- Route doc bloat, managerial prose, and context-preserving condensation to `$distill` using the BMAD lossless distillation baseline.
