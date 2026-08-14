# Feedback Index

Intake provenance for raw reports. An `FB` records that someone reported something, verbatim, so triage
can route it — it is never a peer of `ISS`/`REG` and is never diagnosed on its own.

Record prose lives in `feedback/`; this index is the lookup surface. `FB` carries no
implementation-status verdict: its lifecycle is triage-driven and owned by `$reconcile`, not assessed by
`$status-update`.

| FB | Category | Scope | Report Kind | Title | Linked To | Status |
| --- | --- | --- | --- | --- | --- | --- |
| — | — | — | — | *(none filed)* | — | — |

---

No `FB` records exist. The type is new with the record schema — pre-migration reports were filed
directly as issues, which is why `ISS-002`'s reopening has no intake record behind it.

Lifecycle: `New` → `Triaged` → `Accepted` \| `Rejected` → `Closed`, plus a direct `New` → `Rejected` for
a declined report that produces no downstream record. Triage is the only writer of `Linked To`, and the
target must already exist.
