# Tech Debt Index

Blueprint-versus-code drift and deliberate shortcuts carrying a removal trigger. A defect is an `ISS`
with its `REG` reports, not a `TD`.

Record prose lives in `debt/`; this index is the lookup surface. Status is owned by `$status-update`.

Ids are immutable — [`ID-MAP.md`](ID-MAP.md) resolves the pre-migration `G-` form.

| TD | Category | Scope | Severity | Priority | Title | Removal Trigger | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [TD-001](debt/TD-001.md) | infra | hooks | Low | P2 | OpenCode hooks are out of scope by policy | OpenCode gains a shell-executable hook model, or a hook stops being advisory | Deferred |

---

`TD-002` onward are unissued. `Deferred` is non-terminal: the record stays in this active index and
still accepts links.
