#!/usr/bin/env bash
set -u

INPUT=""
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -|test) ;;
    *) [[ -n "$INPUT" ]] || INPUT="$1" ;;
  esac
  shift
done

[[ -n "$INPUT" ]] || INPUT="$(cat 2>/dev/null || true)"

event="$(printf '%s' "$INPUT" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("hook_event_name","Agent"))' 2>/dev/null || true)"
message="$(printf '%s' "$INPUT" | python3 -c 'import json,sys; d=json.load(sys.stdin); print((d.get("last_assistant_message") or d.get("reason") or d.get("prompt") or d.get("tool_name") or "Agent activity").replace("\n"," ")[:240])' 2>/dev/null || true)"

event="${event:-Agent}"
message="${message:-Agent activity}"
title="Agent - $event"

if [[ -n "${AGENT_NOTIFY_COMMAND:-}" ]]; then
  "$AGENT_NOTIFY_COMMAND" "$title" "$message"
  exit 0
fi

if command -v powershell.exe >/dev/null 2>&1; then
  powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command     "$title = [System.Security.SecurityElement]::Escape('$title'); $body = [System.Security.SecurityElement]::Escape('$message'); [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null; [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null; $xml = New-Object Windows.Data.Xml.Dom.XmlDocument; $xml.LoadXml(\"<toast><visual><binding template='ToastGeneric'><text>$title</text><text>$body</text></binding></visual></toast>\"); $toast = New-Object Windows.UI.Notifications.ToastNotification $xml; [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Microsoft.Windows.ShellExperienceHost').Show($toast)"     >/dev/null 2>&1 && exit 0
fi

if command -v notify-send >/dev/null 2>&1; then
  notify-send "$title" "$message" >/dev/null 2>&1 || true
  exit 0
fi

printf '%s: %s\n' "$title" "$message"
