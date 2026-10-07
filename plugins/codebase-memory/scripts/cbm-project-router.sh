#!/usr/bin/env bash
set -u

command -v jq >/dev/null 2>&1 || exit 0
ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CACHE_DIR="${CBM_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/codebase-memory}"
CACHE_FILE="${CBM_CACHE_FILE:-$CACHE_DIR/projects.json}"
TTL="${CBM_CACHE_TTL_SEC:-600}"
BIN="${CBM_BIN:-codebase-memory-mcp}"

mkdir -p "$CACHE_DIR" 2>/dev/null || exit 0

mtime=0
[ -f "$CACHE_FILE" ] && mtime="$(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)"
now="$(date +%s)"
age=$((now - mtime))

if [ ! -s "$CACHE_FILE" ] || [ "$mtime" -le 0 ] || [ "$age" -lt 0 ] || [ "$age" -ge "$TTL" ]; then
  tmp="$CACHE_FILE.tmp.$$"
  raw="$("$BIN" cli list_projects --offset 0 --limit 100 2>/dev/null)" || raw=""
  if [ -n "$raw" ]; then
    printf '%s' "$raw" |
      jq -c '{projects: [(.projects[]? | if type == "object" then .name else . end)]}' > "$tmp" 2>/dev/null &&
      mv -f "$tmp" "$CACHE_FILE" 2>/dev/null || rm -f "$tmp" 2>/dev/null
  fi
fi

[ -s "$CACHE_FILE" ] || exit 0

prompt="$(cat 2>/dev/null | jq -r '.prompt // empty' 2>/dev/null || true)"
[ -n "$prompt" ] || exit 0

matches="$(
  printf '%s\n' "$prompt" |
    grep -o -E '[A-Za-z0-9_-]+' |
    while IFS= read -r token; do
      norm="$(printf '%s' "$token" | tr '[:upper:]' '[:lower:]' | tr '_' '-')"
      jq -r --arg n "$norm" '.projects[]? | select((ascii_downcase | gsub("_"; "-")) == $n)' "$CACHE_FILE" 2>/dev/null
    done |
    awk '!seen[$0]++' |
    paste -sd ', ' -
)"

[ -n "$matches" ] || exit 0

context="Codebase Memory confirmed indexed project(s) mentioned in the prompt: $matches. Use the confirmed project name(s) directly. Verify structural claims with graph tools and use source fallback when coverage is incomplete."

jq -n --arg ctx "$context" '{
  hookSpecificOutput: {
    hookEventName: "UserPromptSubmit",
    additionalContext: $ctx
  }
}'
