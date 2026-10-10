#!/usr/bin/env bash
set -euo pipefail

root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

command -v jq >/dev/null
command -v bash >/dev/null

json_files=(
  "$root/.claude-plugin/marketplace.json"
  "$root/.claude-plugin/plugin.json"
  "$root/plugins/codebase-memory/.claude-plugin/plugin.json"
  "$root/plugins/codebase-memory/.plugin/plugin.json"
  "$root/plugins/codebase-memory/.mcp.json"
  "$root/plugins/codebase-memory/mcp.json"
  "$root/plugins/codebase-memory/hooks/hooks.json"
  "$root/plugins/azure/.claude-plugin/plugin.json"
  "$root/plugins/azure/.plugin/plugin.json"
  "$root/plugins/azure/.mcp.json"
  "$root/plugins/azure-devops/.claude-plugin/plugin.json"
  "$root/plugins/azure-devops/.plugin/plugin.json"
  "$root/plugins/azure-devops/.mcp.json"
  "$root/plugins/wsl-notifications/.claude-plugin/plugin.json"
  "$root/plugins/wsl-notifications/.plugin/plugin.json"
  "$root/plugins/wsl-notifications/hooks/hooks.json"
)

for file in "${json_files[@]}"; do
  jq empty "$file"
done

bash -n "$root/plugins/codebase-memory/scripts/cbm-project-router.sh"
bash -n "$root/plugins/wsl-notifications/scripts/notify-send.sh"

bash "$root/plugins/codebase-memory/tests/test-router.sh"
bash "$root/plugins/wsl-notifications/tests/test.sh"

echo "agent-extensions validation passed"
