# Agent Extensions

Reusable plugins for coding agents.

This repository is the agent-agnostic successor to [junie-extensions](https://github.com/upfera/junie-extensions). The capabilities are organized as installable plugins and use the component conventions shared by modern agent runtimes.

## Included plugins

| Plugin | Purpose |
|---|---|
| **codebase-memory** | Codebase Memory MCP, progressive-disclosure skill, Scout/Verify/Auditor agents, and prompt routing |
| **wsl-notifications** | WSL desktop notifications for agent lifecycle events |
| **azure** | Azure MCP server configuration |
| **azure-devops** | Azure DevOps MCP server plus Boards and Pipelines skills |

## Repository layout

```text
agent-extensions/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── codebase-memory/
│   ├── wsl-notifications/
│   ├── azure/
│   └── azure-devops/
├── scripts/
│   └── validate.sh
├── tests/
├── .editorconfig
├── .gitignore
├── LICENSE
└── README.md
```

Each plugin is self-contained. Claude Code uses `.claude-plugin/plugin.json`; OpenHands' current Claude-compatible loader also accepts `.plugin/plugin.json`. Components stay in the standard plugin directories such as `skills/`, `agents/`, `hooks/`, and `.mcp.json`. citehttps://docs.openhands.dev/sdk/guides/plugins

## Claude Code

Add this repository as a marketplace:

```text
/plugin marketplace add https://github.com/upfera/agent-extensions
```

Then install one or more plugins:

```text
/plugin install codebase-memory@agent-extensions
/plugin install azure-devops@agent-extensions
```

For local development, Claude Code supports loading a plugin directly with `--plugin-dir`, and `claude plugin validate .` validates an individual plugin directory. citehttps://code.claude.com/docs/en/plugins

## OpenHands

OpenHands can load the plugin directories directly through its SDK plugin loader. Because OpenHands currently documents `.plugin/plugin.json` while also consuming the Claude Code layout, each plugin keeps the OpenHands manifest alongside the Claude manifest. citeturn680796search0

Example:

```python
from openhands.sdk.plugin import Plugin

plugin = Plugin.load("plugins/codebase-memory")
```

## Requirements

The plugins declare integrations but do not install their external runtimes.

For Codebase Memory:

```bash
codebase-memory-mcp --help
```

For Azure and Azure DevOps, the relevant `npx` packages must be reachable from the environment and authenticated using the configured method.

## Design principles

**Agent-neutral capabilities.** Skills, agents, MCP servers, and hooks describe a capability instead of a Junie-specific product surface.

**Explicit adapters.** Where runtimes disagree, the adapter lives at the edge. Core skill content and scripts are kept reusable.

**Small context footprint.** Skills use progressive disclosure and task-directed guidance rather than injecting large static context into every turn.

**Fail-open integrations.** Discovery helpers and desktop notifications must not turn a degraded optional integration into a failed agent session.

**No repository indexing side effects.** The Codebase Memory plugin consumes the existing local index. It does not index or delete repositories as part of normal agent operation.

## Migration from junie-extensions

The old Junie-specific `.junie-extension/` marketplace and `extension.json` files are intentionally not copied.

The important capability changes are:

- `extensions/` becomes `plugins/`
- Junie manifests become Claude/OpenHands plugin manifests
- Junie lifecycle commands become standard plugin hooks
- Junie-specific environment variables are removed
- the Codebase Memory prompt hook emits Claude's current `hookSpecificOutput.additionalContext` shape
- WSL notification configuration is expressed directly in hook registration rather than a mutable Junie cache file

## Security

Plugins execute with the privileges of the agent session. Review MCP commands, hooks, and scripts before installing third-party plugins. Never commit credentials into plugin configuration. Claude Code explicitly treats installed plugin code as running with the user's privileges. citehttps://code.claude.com/docs/en/plugins

## License

MIT
