# WSL Notifications

Desktop notifications for coding-agent lifecycle events from WSL.

Supported events:
- PermissionRequest
- Stop
- StopFailure
- SessionEnd

Delivery order:
1. Use AGENT_NOTIFY_COMMAND for an explicit notification command.
2. Windows Toast through powershell.exe.
3. notify-send.
4. stdout fallback.

The notification script is intentionally independent of a specific agent product. It consumes the standard hook JSON event fields and fails open when optional notification infrastructure is unavailable.
