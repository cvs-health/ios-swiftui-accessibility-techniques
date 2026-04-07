# MCP Server for a11y-check

Model Context Protocol (MCP) server that exposes the SwiftUI **a11y-check** tool to AI assistants. Works with **Cursor**, **Windsurf**, **Claude Desktop**, **VS Code (Copilot)**, and any MCP-compatible client. Ask "check this project for accessibility" in chat — the AI runs the checker, reports scores and WCAG failures, and can suggest or apply fixes.

## Prerequisites

- **Node.js** 18+
- **a11y-check** binary — either install via Homebrew or build from source (see [Using a local build](#using-a-local-build))

## Install and run

```bash
cd A11yAgent/mcp-server
npm install
npm run build
```

The server uses **stdio** transport: the AI tool spawns this process and communicates over JSON-RPC via stdin/stdout.

## Setup by AI Tool

All tools use the same MCP server — only the config file location differs. Replace `/path/to/` with your actual repo path in every example below.

### Environment variables

| Variable | Description |
|---|---|
| `A11Y_CHECK_PATH` | Absolute path to the `a11y-check` binary. Set this if the binary isn't on your PATH (e.g. local build or Homebrew on macOS). |
| `A11Y_PROJECT_ROOT` | Project root directory. Relative paths in `paths` resolve against this. |

---

### Cursor

**Config file:** Cursor Settings → Features → MCP → Edit config

```json
{
  "mcpServers": {
    "a11y-check": {
      "command": "node",
      "args": ["/path/to/A11yAgent/mcp-server/dist/index.js"],
      "env": {
        "A11Y_CHECK_PATH": "/path/to/a11y-check",
        "A11Y_PROJECT_ROOT": "/path/to/ios-swiftui-accessibility-techniques"
      }
    }
  }
}
```

See [cursor-mcp-example.json](cursor-mcp-example.json) for a copy-paste template.

---

### Windsurf

**Config file:** `~/.codeium/windsurf/mcp_config.json`  
(or click the **hammer icon** at the top of the Cascade panel → Configure)

```json
{
  "mcpServers": {
    "a11y-check": {
      "command": "node",
      "args": ["/path/to/A11yAgent/mcp-server/dist/index.js"],
      "env": {
        "A11Y_CHECK_PATH": "/path/to/a11y-check",
        "A11Y_PROJECT_ROOT": "/path/to/ios-swiftui-accessibility-techniques"
      }
    }
  }
}
```

After saving, refresh MCP servers from the hammer icon or restart Windsurf. See [windsurf-mcp-example.json](windsurf-mcp-example.json).

---

### Claude Desktop

**Config file:**
- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "a11y-check": {
      "command": "node",
      "args": ["/path/to/A11yAgent/mcp-server/dist/index.js"],
      "env": {
        "A11Y_CHECK_PATH": "/path/to/a11y-check",
        "A11Y_PROJECT_ROOT": "/path/to/ios-swiftui-accessibility-techniques"
      }
    }
  }
}
```

Restart Claude Desktop after saving. See [claude-desktop-mcp-example.json](claude-desktop-mcp-example.json).

---

### VS Code (GitHub Copilot)

**Config file:** `.vscode/settings.json` in your workspace, or VS Code User Settings (JSON)

```json
{
  "mcp": {
    "servers": {
      "a11y-check": {
        "command": "node",
        "args": ["/path/to/A11yAgent/mcp-server/dist/index.js"],
        "env": {
          "A11Y_CHECK_PATH": "/path/to/a11y-check",
          "A11Y_PROJECT_ROOT": "/path/to/ios-swiftui-accessibility-techniques"
        }
      }
    }
  }
}
```

Reload VS Code after saving. Copilot Chat will discover the MCP tools automatically. See [vscode-mcp-example.json](vscode-mcp-example.json).

---

### Using a local build

If you build a11y-check from source instead of Homebrew, point `A11Y_CHECK_PATH` at the binary:

```bash
cd A11yAgent && swift build -c release
# Binary is at: A11yAgent/.build/release/a11y-check
```

Set `A11Y_CHECK_PATH` to the absolute path of that binary in your MCP config. This is needed because AI tools often don't inherit your shell PATH.

## Tools exposed

| Tool | Description |
|------|-------------|
| **run_a11y_check** | Run a11y-check on given paths. Returns score (0–100), WCAG criteria pass/fail, trend delta, and diagnostics. Arguments: `paths` (required), optional `projectRoot`, `only`, `disable`, `maxDiagnostics` (default 25; use 0 for full list). |
| **list_a11y_rules** | List all a11y-check rules (IDs, names, WCAG criteria). No arguments. |

## What you can ask

Once the MCP server is configured, you can ask your AI assistant things like:

| Prompt | What happens |
|--------|-------------|
| "Check this project for accessibility issues" | Runs `run_a11y_check` on the project root and returns a summary |
| "Run a11y-check on TextFieldsView.swift" | Checks a specific file and reports issues with line numbers |
| "List all the a11y rules" | Calls `list_a11y_rules` and shows all 23 rules with WCAG criteria |
| "Which of those are the most critical to fix?" | The AI explains severity levels and WCAG impact based on the results |
| "Fix the textfield-missing-label issues" | The AI reads the diagnostics, then edits your source code to add the missing labels |
| "What WCAG criteria does this project fail?" | The AI interprets the results and maps them to compliance requirements |
| "Generate an HTML accessibility report for this project" | The AI runs `a11y-check --format html` in the terminal and saves a self-contained HTML report with WCAG conformance table, per-file details, and per-rule summary |

The full loop — **detect, understand, fix, report** — happens conversationally without leaving the editor. The AI doesn't just report problems; it can explain why they matter for users with disabilities, make the code changes to resolve them, and generate shareable reports for your team.

### Example conversation

```
You:    Check TextFieldsView.swift for accessibility issues

AI:     I found 5 errors in TextFieldsView.swift:
        • Line 214: TextField has an empty label...
        • Line 222: TextField has an empty label...
        (etc.)

You:    Fix the one on line 259

AI:     [Edits the file to add .accessibilityLabel("Address line 2")]
        I added an accessibility label to the TextField on line 259.
        VoiceOver will now announce "Address line 2" when a user
        focuses this field.
```

## Development

```bash
npm run dev    # Run with tsx (no build step)
npm run build  # Compile TypeScript to dist/
```

If you see import errors for `@modelcontextprotocol/sdk`, the package layout may differ by version. Try installing the server package explicitly: `npm install @modelcontextprotocol/server` and adjust the import paths in `src/index.ts` if needed (see the [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk) docs).

## License

Apache License 2.0 — see the [repository root LICENSE](../../LICENSE).
