---
name: security-review
description: Post-validation security gate — adversarial vulnerability assessment against a delivered task before status update
argument-hint: task id or implementation handoff
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - WebSearch
  - AskUserQuestion
context: fork
agent: security
---

# /security-review — Security Gate Procedure

Follows the global policy loaded from the active runtime root's `policy/` directory (`PRINCIPLES.md`, `RULES.md`). Active repo `AGENTS.md` defines local paths, commands, CI gates, and delivery requirements.

## Purpose

Perform an adversarial security review of the assigned task's delivered code by:
- checking all changed files against the vulnerability checklist below;
- classifying each finding by severity with exploitability evidence and blast radius;
- determining a verdict: PASS | FAIL | FINDINGS;
- recording Critical/High findings as `ISS`/`REG` records so they re-enter the workflow via `$reconcile`.

## OWASP Top 10 2025 Gate

Run this checklist first — it maps to the project's own CI security gate, whose workflow file and required checks come from the active repo `AGENTS.md`. Every item must be explicitly assessed (PASS / N/A / finding):

- [ ] **A01 Broken Access Control** — IDOR, missing server-side authz, privilege escalation, CORS misconfiguration
- [ ] **A02 Security Misconfiguration** — default credentials, unnecessary features enabled, missing security headers, verbose errors in production
- [ ] **A03 Software Supply Chain Failures** — unpinned deps, known CVEs, typosquatting, missing SRI hashes, unverified package integrity
- [ ] **A04 Cryptographic Failures** — weak algorithms, plaintext sensitive data, improper key management, no TLS enforcement
- [ ] **A05 Injection** — SQL, NoSQL, command, template, LDAP, XPath — any user input reaching an interpreter
- [ ] **A06 Insecure Design** — missing threat model for new features, no rate limiting, insecure design patterns that no implementation can fix
- [ ] **A07 Authentication Failures** — weak passwords, missing MFA, session fixation, JWT algorithm confusion, credential stuffing exposure
- [ ] **A08 Software or Data Integrity Failures** — unsigned updates, insecure deserialization, CI/CD pipeline integrity, unsigned commits
- [ ] **A09 Security Logging and Alerting Failures** — missing audit logs, no alerting on auth failures, sensitive data in logs, log injection
- [ ] **A10 Mishandling of Exceptional Conditions** — errors revealing internals, uncaught exceptions crashing the service, unsafe fallback behavior

## OWASP LLM Top 10 2025 Gate (apply when AI/LLM features changed)

- [ ] **LLM01 Prompt Injection** — direct (user input) and indirect (tool outputs, RAG results, external data) injection paths
- [ ] **LLM02 Sensitive Information Disclosure** — PII/credentials leaking through model responses, context windows, or completion logs
- [ ] **LLM03 Supply Chain** — compromised model weights, poisoned fine-tuning data, third-party plugin/tool integrity
- [ ] **LLM04 Data and Model Poisoning** — training data manipulation, fine-tuning with adversarial data, backdoor triggers
- [ ] **LLM05 Improper Output Handling** — model output passed directly to shells, eval, SQL, or rendered as HTML without sanitization
- [ ] **LLM06 Excessive Agency** — agent given permissions or tool access beyond task scope; no human-in-the-loop on destructive actions
- [ ] **LLM07 System Prompt Leakage** — system prompt extractable via adversarial prompting; confidential instructions exposed
- [ ] **LLM08 Vector and Embedding Weaknesses** — poisoned vector stores, embedding inversion attacks, insecure similarity search
- [ ] **LLM09 Misinformation** — model generating plausible false content in high-stakes domains without grounding or citations
- [ ] **LLM10 Unbounded Consumption** — no token/request limits; cost amplification via prompt stuffing; denial-of-wallet attacks

## CI Gate Alignment

Read the active repo `AGENTS.md` and its `.github/workflows/` for the required checks, then confirm each one passes. Do not assume a stack — enumerate what this repo actually gates on and assess every entry. Typical shapes:
- [ ] Type check for the repo's language (e.g. `tsc --noEmit`, `mypy`, `go vet`) — no errors
- [ ] The repo's test command — passes
- [ ] Linters the repo gates on (e.g. ShellCheck for bash, `ruff` for Python, `eslint` for JS) — no errors
- [ ] No unused exports or dead code introduced (verify with grep/glob against importers)

A gate result is red regardless of whether the root cause is product code, test harness, config, or credential provisioning. Baseline pre-existing failures for attribution only — a red gate still blocks a passing verdict.

## Detailed Vulnerability Checklist

Review every item applicable to the changed code surface. A finding at Critical or High severity yields FAIL; Medium/Low/Info yields FINDINGS.

### Injection
- [ ] SQL injection — parameterized queries everywhere; no string concatenation into queries
- [ ] NoSQL injection — input sanitization before MongoDB/Redis/DynamoDB queries
- [ ] Command injection — shell exec with user-controlled input; check subprocess calls, eval, exec
- [ ] Template injection (SSTI) — user input reaching Jinja2, Twig, Freemarker, Handlebars, Pebble, Mako render context
- [ ] LDAP / XPath / expression-language injection
- [ ] Path traversal — user-controlled file paths without canonicalization and allowlist validation

### Authentication & Session
- [ ] JWT algorithm confusion: `alg=none`, RS256→HS256 downgrade; verify signature algorithm is hardcoded server-side
- [ ] JWT claims: expiry (`exp`), issuer (`iss`), audience (`aud`) validated; no trusting unverified payload before signature check
- [ ] Session fixation — new session ID issued on privilege change (login, role elevation)
- [ ] Session invalidation — tokens/sessions revoked on logout, password change, and account lock
- [ ] Cookie flags — `HttpOnly`, `Secure`, `SameSite=Strict` or `Lax` on all auth cookies
- [ ] Brute-force protection — account lockout or rate limiting on auth endpoints
- [ ] MFA bypass vectors — check for fallback paths that skip second factor
- [ ] OAuth/PKCE: state parameter validated, PKCE verifier enforced, redirect URI strictly allowlisted

### Authorization
- [ ] IDOR — resource IDs not validated against authenticated user's ownership/scope
- [ ] BOLA (Broken Object Level Authorization) — per-object ownership check on every access
- [ ] BFLA (Broken Function Level Authorization) — function-level checks not relying on client-supplied role
- [ ] Mass assignment — request body fields not allowlisted before binding to model/ORM
- [ ] Horizontal privilege escalation — user A accessing user B's resources
- [ ] Vertical privilege escalation — user accessing admin/privileged functions
- [ ] Missing server-side enforcement — authorization checks not duplicated in API handler (client-side only is never sufficient)

### Input Validation & Data Handling
- [ ] All external input validated: type, length, format, range, encoding — at the trust boundary, not only in the UI
- [ ] File uploads: MIME type and magic-byte validation; filename sanitized; size limited; stored outside webroot or in object storage with no public execute
- [ ] Redirect / open redirect — user-supplied URLs validated against an allowlist before redirect
- [ ] XML / JSON parsing — XXE disabled; entity expansion limits set; malformed input handled
- [ ] Deserialization — untrusted data not deserialized into object graphs without strict type allowlists

### Cross-Site Scripting (XSS)
- [ ] Reflected XSS — user input reflected in HTML response without encoding
- [ ] Stored XSS — user content stored and later rendered without encoding
- [ ] DOM XSS — client-side sinks: `innerHTML`, `dangerouslySetInnerHTML`, `document.write`, `eval`, `setTimeout(string)`
- [ ] CSP present and restrictive: no `unsafe-inline`, no `unsafe-eval`, no wildcard origins; nonce or hash-based for inline scripts
- [ ] Output encoding context-appropriate: HTML, JS, CSS, URL encoding applied per context

### Cross-Site Request Forgery (CSRF)
- [ ] State-changing endpoints protected by CSRF token or `SameSite=Strict` cookie + origin validation
- [ ] Double-submit cookie pattern implemented correctly (token tied to session)
- [ ] Custom request headers used for AJAX CSRF protection where applicable

### Server-Side Request Forgery (SSRF)
- [ ] URL fetching (HTTP clients, webhooks, image processors, PDF generators) validates target against an allowlist
- [ ] DNS rebinding mitigated — IP resolved and validated before connection, not just on first lookup
- [ ] Cloud metadata endpoints blocked (169.254.169.254, fd00:ec2::254, metadata.google.internal)
- [ ] Redirect chains followed safely — each hop re-validated against allowlist

### Secrets & Cryptography
- [ ] No hardcoded credentials, API keys, tokens, or certificates in source code or config files
- [ ] Secrets not logged, included in error responses, query parameters, or URL paths
- [ ] Secrets not embedded in client-side bundles or HTML
- [ ] No custom crypto — use libsodium, OpenSSL, Web Crypto API; never implement your own cipher, hash, or PRNG
- [ ] Password hashing — bcrypt, Argon2id, or scrypt with appropriate cost factors; never MD5/SHA1/SHA256 for passwords
- [ ] TLS 1.2+ enforced; weak cipher suites and renegotiation disabled
- [ ] Encryption at rest for sensitive data fields (PII, PHI, financial, credentials)

### Error Handling & Information Disclosure
- [ ] Stack traces, internal paths, DB schema names, framework versions not returned to clients
- [ ] Generic auth error messages (avoid "user not found" vs "wrong password" distinction)
- [ ] Debug endpoints, admin consoles, API explorers disabled or protected in production
- [ ] HTTP response headers: `Server`, `X-Powered-By`, `X-AspNet-Version` suppressed
- [ ] Security headers present: `Strict-Transport-Security`, `X-Content-Type-Options: nosniff`, `X-Frame-Options` or CSP `frame-ancestors`

### Business Logic
- [ ] Race conditions (TOCTOU) — shared state mutated without locks or optimistic concurrency control
- [ ] Negative values and integer overflow — financial calculations validate non-negative inputs
- [ ] Workflow bypass — process steps enforceable server-side; no reliance on client-side state
- [ ] Replay attacks — idempotency keys or nonces used for sensitive operations
- [ ] Price/quantity manipulation — server authoritative for pricing; never trust client-supplied price

### API Security
- [ ] Rate limiting on all public and sensitive endpoints; different limits for auth vs. data endpoints
- [ ] GraphQL: introspection disabled in production; query depth and complexity limits enforced; field-level authorization checked
- [ ] WebSocket: origin validated on upgrade; authentication required before message processing; per-message authorization enforced
- [ ] gRPC/protobuf: required fields validated; enum values range-checked; streaming endpoints authenticated
- [ ] REST: HTTP verb restrictions enforced; `Content-Type` validated before parsing body

### Supply Chain
- [ ] No unpinned dependency versions (`^`/`~`/`*`) on security-critical packages; lockfile present and committed
- [ ] New third-party packages checked for known CVEs and maintenance status
- [ ] CDN-hosted scripts include SRI hashes (`integrity` attribute)
- [ ] No dependency confusion risk (internal package names not squattable on public registries)

### Cloud & Infrastructure (when IaC or cloud config changed)
- [ ] IAM roles/policies follow least privilege; no `*` actions or resources on sensitive services
- [ ] S3/GCS/Azure Blob — public access blocked at bucket/account level
- [ ] Secrets not in environment variables in plaintext; use Secrets Manager / Vault
- [ ] Container: non-root user; read-only root filesystem; no `privileged: true`; capabilities dropped
- [ ] Network: security groups/firewall rules as restrictive as possible; no 0.0.0.0/0 ingress on sensitive ports
- [ ] Kubernetes: no `hostPID`, `hostNetwork`, `hostIPC`; Pod Security Standards enforced; NetworkPolicies present

### AI/LLM (when AI features changed)

See the **OWASP LLM Top 10 2025 Gate** above for the full checklist. Additionally verify:
- [ ] Every LLM tool call / function call result is validated before being passed to downstream systems
- [ ] Agent action scope is explicitly bounded — list permitted operations; deny by default
- [ ] Human confirmation required before irreversible actions (file deletion, payments, external messaging)
- [ ] Completion content not rendered as HTML/JS without sanitization (LLM05)

## Threat Modeling (for design-time reviews or architectural tasks)

Perform STRIDE analysis across trust boundaries when the task modifies authentication, authorization, data flows, or infrastructure:

| Threat | Ask |
|--------|-----|
| Spoofing | Can an attacker impersonate a user, service, or identity? |
| Tampering | Can requests, responses, or stored data be modified in transit or at rest? |
| Repudiation | Can a user deny an action? Is audit logging complete and tamper-evident? |
| Info Disclosure | Do errors, logs, or responses leak internal structure, credentials, or PII? |
| Denial of Service | Can an attacker exhaust resources — CPU, memory, connections, rate limits? |
| Elevation of Privilege | Can a low-privilege actor reach high-privilege functionality or data? |

Map trust boundaries (Internet → WAF/Gateway → App → Service → DB → External integrations). Every hop is a potential pivot point.

## Severity Scale & Verdicts

| Severity | Examples | Verdict | Remediation target |
|----------|---------|---------|-------------------|
| Critical | RCE, auth bypass, SQLi with data access, secret exposure in code | FAIL | Fix before next attempt |
| High | Stored XSS, IDOR with sensitive data, privilege escalation, SSRF to internal | FAIL | Fix before next attempt |
| Medium | CSRF on state-changing actions, missing security headers, verbose errors | FINDINGS — log an `ISS` | 30 days |
| Low | Clickjacking on non-sensitive pages, minor info disclosure, weak cookie flags | FINDINGS — log an `ISS` | 90 days |
| Info | Best-practice gaps, defense-in-depth improvements, missing rate limits on low-value endpoints | FINDINGS — optional feedback | Backlog |

## Workflow

1. Resolve the task and implementation handoff from `$ARGUMENTS` or the orchestrator brief.
2. Read active repo rules (`AGENTS.md`), the Work Order under `docs/development/workorders/` with its implementation plan, and the developer/validator handoffs.
3. Identify the changed files from the implementation commit; confirm against the task's declared owned files.
4. Run the **OWASP Top 10 2025 Gate** first — assess each item as PASS / N/A / finding. Then run the **OWASP LLM Top 10 2025 Gate** if any AI/LLM code changed. Then run the **CI Gate Alignment** checks.
5. Run the **Detailed Vulnerability Checklist** section by section against each changed file. Use `grep`/`glob` to locate patterns; read the actual source rather than relying on filenames.
6. For each finding: record severity, file:line, title, attack path (exactly how an attacker triggers it), and a copy-paste-ready remediation.
7. Determine verdict:
   - Any Critical or High → **FAIL**; route back to implement.
   - No Critical/High, but Medium/Low/Info present → **FINDINGS**; proceed to status.
   - No findings → **PASS**.
8. For each Critical or High finding, record durable feedback as records under `docs/development/issues/`, then refresh the `ISSUES.md` index:
   - Read the index first and inspect active security records for the same root cause. Similar wording is not proof of a shared cause, but a duplicate record costs more than a moment's reading.
   - If no record owns the cause, author a generalized `ISS` with `issueType: security`, its severity, and its root-cause state, then record the concrete symptom as a `REG` under it. A missing control with no exploitable symptom is a `TD` instead. `Priority` derives from severity (Critical/High → `P0`). **Under `$orchestrate`, ids come from the brief**; if this slice needs one the brief did not provide, report the finding with its evidence and let the orchestrator allocate.
   - The `REG` document carries: `Type: Security`, `Discovered`, `Affects`, the delivery record it was found under, then the finding's file:line, attack path (exactly how an attacker triggers it), remediation, CVSS estimate, and the verification evidence a fix must produce.
   - If an `ISS` already owns the cause, record the finding as a `REG` under it instead of minting a second `ISS`. Never renumber or recycle an id.
9. For Medium findings, record feedback the same way; Low/Info may stay in the report only.
10. Commit the scoped record documents and their index rows with explicit staging; do not commit product code or validation reports.
11. Return the verdict, the finding-to-issue mapping, the commit SHA, and blockers.

## Delegated-Slice Rules

- Do not fix implementation defects — report them with remediation and return FAIL.
- Do not suppress or defer Critical/High findings to avoid re-work.
- Do not expand scope beyond the task's declared owned files.
- Do not set task status (`$status-update` owns this).
- Do not commit product code or validation reports.
- Do not recommend disabling security controls — find the root cause.

## Report Format

- **Verdict**: PASS | FAIL | FINDINGS
- **Findings**: Each entry — severity, file:line, title, attack path, remediation
- **Artifacts**: `ISS`/`REG`/`TD` ids authored + their document paths under `docs/development/`
- **Commit**: SHA of the scoped record commit, or `none` if nothing was committed
- **Blockers**: Missing context, inaccessible files, ambiguous trust model
- **Residual risk**: Medium/Low/Info findings logged but not blocking
