#!/bin/bash
# remind-validate.sh - SubagentStop hook (phase 1: stop_hook_active=false)
# Outputs validation checklist, writes to agent-stop.jsonl
# Blocking execution - agent decides whether to act

source "$(dirname "$0")/lib/hook-utils.sh"
parse_hook_input

# Only trigger validation on the first stop event (stop_hook_active=false)
if [ "$STOP_HOOK_ACTIVE" != "false" ]; then
    exit 0
fi

# Write agent-stop.jsonl (logs internally) and log validation prompt
if [ -n "$AGENT_ID" ] && [ -d "$AGENT_LOG_DIR" ]; then
    write_agent_stop_jsonl
    log_event "VALIDATION_PROMPT" "$AGENT_LOG_DIR"
fi

# Read agent start for output
read_agent_start

cat << EOF
<system-reminder>
[SubagentStop:validate] session=${SESSION_ID:-unknown} agent=${AGENT_ID:-unknown} type=${AGENT_TYPE}
Started: ${AGENT_START_TIME}

SELF-VALIDATION CHECKLIST:
Before completing, verify:
1. [ ] All acceptance criteria in scope are met
2. [ ] Artifact follows its template sections (if applicable)
3. [ ] No assumptions made without evidence (verify via docs/code)
4. [ ] Focused tests for the touched surface pass (if applicable)
5. [ ] Output stored in correct location

HANDOFF CHECKLIST (a slice is complete only at an explicit checkpoint):
6. [ ] Scoped commit made — explicit staging, citing the record id
7. [ ] Every service and store this lane booted is stopped via the repo's
       stop path, or named as still live with its port/store
8. [ ] Status left to \$status-update — this stage did not set it
9. [ ] Evidence recorded only at the scope actually exercised;
       'configured' or 'inspected' reported as neither executed nor passed
10.[ ] Final report names: changed files, checks run, last checkpoint SHA,
       done vs remaining, blockers, skipped scope, residual risk

If any item fails, address before completing.
If unable to verify, note the gap explicitly — silence is not a pass.

Agent log: ${AGENT_LOG_DIR:-n/a}
</system-reminder>
EOF
