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
| **run_a11y_check** | Run a11y-check on given paths. Returns score (0–100), WCAG criteria pass/fail, trend delta, and diagnostics with per-issue WCAG mappings. Arguments: `paths` (required), optional `projectRoot`, `only`, `disable`, `maxDiagnostics` (default 25; use 0 for full list). |
| **list_a11y_rules** | List all a11y-check rules (IDs, names, WCAG criteria). No arguments. |

## Scoring

Every `run_a11y_check` call returns a **WCAG 2.2 accessibility score** (0–100 with a letter grade A–F). The score is based on:

- **WCAG criteria pass/fail** — which of the 40+ Level A and AA success criteria have errors
- **Issue penalties** — errors (−5), warnings (−2), info (−0.5) per finding
- **Failed criteria list** — e.g. 3.3.2 Labels or Instructions, 4.1.2 Name Role Value

Example MCP output:

```
Score: 25/100 (F) — 9 passed, 2 failed

Failed WCAG criteria:
  ✗ 3.3.2 Labels or Instructions (11 errors, 0 warnings)
  ✗ 4.1.2 Name, Role, Value (1 errors, 0 warnings)
```

## Trend Tracking

Scores are **automatically recorded** on every run to a `.a11y-scores.json` file in the analyzed directory. When history exists, the MCP output includes a **trend delta** showing how the score changed:

```
Score: 75.0/100 (C) — 12 passed, 1 failed
Trend: +12.5 from last run
```

This lets you track progress over time — fix issues, re-run, and see the score improve. The trend data also appears in:

- **HTML reports** — SVG line chart with score history and a data table
- **JSON output** — `trend` object with historical entries and delta
- **Terminal output** — sparkline chart and history table

Use `--no-trend` on the CLI to disable tracking if needed.

## What you can ask

Once the MCP server is configured, you can ask your AI assistant things like:

| Prompt | What happens |
|--------|-------------|
| "Check this project for accessibility issues" | Runs `run_a11y_check` on the project root and returns score, failed WCAG criteria, and diagnostics |
| "Run a11y-check on TextFieldsView.swift" | Checks a specific file and reports score and issues with line numbers |
| "What's my accessibility score?" | Runs the check and highlights the score, grade, and trend delta |
| "How has the score changed?" | The AI reads the trend data and explains whether things are improving |
| "List all the a11y rules" | Calls `list_a11y_rules` and shows all rules with WCAG criteria |
| "Which WCAG criteria are we failing?" | The AI interprets the failed criteria list from the score output |
| "Fix the textfield-missing-label issues" | The AI reads the diagnostics, then edits your source code to add the missing labels |
| "Generate an HTML accessibility report" | The AI runs `a11y-check --format html` in the terminal and saves a report with score trend chart, WCAG conformance table, and per-file details |

The full loop — **detect, score, understand, fix, track** — happens conversationally without leaving the editor. The AI reports your score, explains which WCAG criteria fail and why they matter for users with disabilities, makes the code changes, and tracks your improvement over time.

### Example conversation

```
You:    Check TextFieldsView.swift for accessibility issues

AI:     Score: 25/100 (F) — 9 passed, 2 failed

        Failed WCAG criteria:
          ✗ 3.3.2 Labels or Instructions (11 errors)
          ✗ 4.1.2 Name, Role, Value (1 error)

        11 issues found. Top issues:
        • Line 247: TextField uses placeholder "First Name" as its
          only label — missing persistent visible label (WCAG 3.3.2)
        • Line 255: TextField has empty label and no
          .accessibilityLabel() (WCAG 3.3.2 + 4.1.2)
        (etc.)

You:    Fix them

AI:     [Adds Text labels and .accessibilityLabel() modifiers]
        Fixed 11 issues across the file.

You:    Run the check again

AI:     Score: 100/100 (A) — 11 passed, 0 failed
        Trend: +75.0 from last run ✅
        No accessibility issues found.
```

## Development

```bash
npm run dev    # Run with tsx (no build step)
npm run build  # Compile TypeScript to dist/
```

If you see import errors for `@modelcontextprotocol/sdk`, the package layout may differ by version. Try installing the server package explicitly: `npm install @modelcontextprotocol/server` and adjust the import paths in `src/index.ts` if needed (see the [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk) docs).

## License

Apache License 2.0 — see the [repository root LICENSE](../../LICENSE).
