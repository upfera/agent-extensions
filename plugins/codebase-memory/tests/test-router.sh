#!/usr/bin/env bash
set -euo pipefail
root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/projects.json" <<'JSON'
{"projects":["atlas-rjthk1","mercury-wvrbw3"]}
JSON

export CBM_CACHE_FILE="$tmp/projects.json"
export CBM_CACHE_DIR="$tmp"
export CBM_CACHE_TTL_SEC=999999

out="$(printf '%s\n' '{"prompt":"Compare ATLAS_RJTHK1 and mercury-wvrbw3"}' | bash "$root/scripts/cbm-project-router.sh")"
printf '%s' "$out" | jq -e '.hookSpecificOutput.additionalContext | contains("atlas-rjthk1")' >/dev/null
printf '%s' "$out" | jq -e '.hookSpecificOutput.additionalContext | contains("mercury-wvrbw3")' >/dev/null

[[ -z "$(printf '%s\n' '{"prompt":"unrelated prompt"}' | bash "$root/scripts/cbm-project-router.sh")" ]]
[[ -z "$(printf '%s\n' '{"not_prompt":true}' | bash "$root/scripts/cbm-project-router.sh")" ]]
[[ -z "$(printf '%s\n' '{invalid' | bash "$root/scripts/cbm-project-router.sh")" ]]
bash -n "$root/scripts/cbm-project-router.sh"
echo "all tests passed"
