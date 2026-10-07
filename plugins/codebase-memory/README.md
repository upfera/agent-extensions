# Codebase Memory

Codebase Memory integration for coding agents.

## Provides

- Codebase Memory MCP with full, Scout, and analysis tool profiles
- progressive-disclosure skill
- Scout, Verify, and Auditor agent definitions
- UserPromptSubmit routing that recognizes indexed project names
- fail-open behavior when the local MCP executable or cache is unavailable

The plugin consumes the existing local Codebase Memory index. It does not index, delete, or mutate repositories.

## Claude Code

The plugin uses .claude-plugin/plugin.json, .mcp.json, skills, agents, and hooks.

## OpenHands

The plugin also carries .plugin/plugin.json for the OpenHands Agent Plugins loader.

## Requirements

The codebase-memory-mcp executable must be installed and available on PATH.

## Security

The prompt router only reads the local project list and emits additional context. It does not execute repository content.
