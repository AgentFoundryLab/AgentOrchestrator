#!/bin/bash
# remind-session-learn.sh - Stop hook
# Prompts the orchestrator to invoke $meta-learn for session analysis
# Blocking execution - includes orchestrator checklist

source "$(dirname "$0")/lib/hook-utils.sh"
parse_hook_input

# Log stop event
if [ -n "$SESSION_ID" ] && [ -d "$SESSION_LOG_DIR" ]; then
    log_event "STOP_HOOK stop_hook_active=${STOP_HOOK_ACTIVE}"
fi

# Count agents spawned this session
AGENT_COUNT=0
if [ -d "$SESSION_LOG_DIR" ]; then
    AGENT_COUNT=$(find "$SESSION_LOG_DIR" -maxdepth 1 -type d | wc -l)
    AGENT_COUNT=$((AGENT_COUNT - 1))
fi

cat << EOF
<system-reminder>
[Stop:session-learn] session=${SESSION_ID:-unknown} agents_spawned=${AGENT_COUNT}

SESSION REFLECTION PROMPT:
Before session ends, consider invoking \$meta-learn to capture:
- Lessons learned from this session
- Patterns that worked well
- Errors and their resolutions
- Blockers encountered
- Instruction/rule changes that would prevent a recurrence

ORCHESTRATOR CHECKLIST:
- [ ] All planned tasks completed or documented as pending
- [ ] Artifacts stored in correct locations
- [ ] No uncommitted changes (if applicable)
- [ ] Next steps documented if work is incomplete

Use \$meta-learn to persist session insights and rule fixes.

Session log: ${SESSION_LOG_DIR:-n/a}
Transcript: ${TRANSCRIPT_PATH:-n/a}
</system-reminder>
EOF
