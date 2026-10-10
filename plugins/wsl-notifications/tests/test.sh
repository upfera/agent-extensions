#!/usr/bin/env bash
set -euo pipefail
root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
notify="$root/scripts/notify-send.sh"
command -v bash >/dev/null
bash -n "$notify"
out="$(printf '%s\n' '{"hook_event_name":"Stop","last_assistant_message":"test event"}' | AGENT_NOTIFY_COMMAND="$(command -v echo)" bash "$notify")"
[[ "$out" = "Agent - Stop test event" ]]
out="$(printf '%s\n' '{"hook_event_name":"SessionEnd","last_assistant_message":"unicode ąćęłńóśźż"}' | AGENT_NOTIFY_COMMAND="$(command -v echo)" bash "$notify")"
printf '%s\n' "$out" | grep -q "unicode"
echo "all tests passed"
