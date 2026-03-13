# MCP Server for a11y-check

Model Context Protocol (MCP) server that exposes the SwiftUI **a11y-check** tool to AI assistants (e.g. [Cursor](https://cursor.com)). Lets you ask things like “check this project for accessibility” in chat; the AI runs the checker and can suggest or apply fixes.

## Prerequisites

- **Node.js** 18+
- **a11y-check** binary: either install via Homebrew (see below) or **build from source** and point the MCP server at it (see [Using a local build](#using-a-local-build)).

## Install and run

```bash
cd A11yAgent/mcp-server
npm install
npm run build
npm start
```

The server uses **stdio** transport: it reads JSON-RPC from stdin and writes to stdout. Cursor (or another MCP client) spawns this process and communicates over stdio.

## Cursor setup

1. Install or build **a11y-check** (see Prerequisites and [Using a local build](#using-a-local-build)).
2. Add the MCP server to Cursor’s config.

   **Cursor Settings → Features → MCP → Edit config** (or edit the config file directly).

3. Add an entry for this server. Use the **path** to the repo and run the Node script:

   **Option A – use `npx` (run from repo root):**

   ```json
   {
     "mcpServers": {
       "a11y-check": {
         "command": "node",
         "args": [
           "/path/to/ios-swiftui-accessibility-techniques/A11yAgent/mcp-server/dist/index.js"
         ]
       }
     }
   }
   ```

   Replace `/path/to/ios-swiftui-accessibility-techniques` with your actual repo path. See [cursor-mcp-example.json](cursor-mcp-example.json) for a copy-paste template.

   **Option B – use `npm run start` in the mcp-server directory:**

   ```json
   {
     "mcpServers": {
       "a11y-check": {
         "command": "npm",
         "args": ["run", "start"],
         "cwd": "/path/to/ios-swiftui-accessibility-techniques/A11yAgent/mcp-server"
       }
     }
   }
   ```

4. Restart Cursor (or reload MCP servers) so it picks up the new server.

### Using a local build

If you build a11y-check from source instead of using Homebrew, set **`A11Y_CHECK_PATH`** so the MCP server can find the binary (Cursor often doesn’t inherit your shell PATH).

1. Build the CLI:
   ```bash
   cd A11yAgent && swift build
   ```
2. In Cursor’s MCP config, add `env` with the **absolute path** to the binary:

   ```json
   {
     "mcpServers": {
       "a11y-check": {
         "command": "node",
         "args": ["/path/to/ios-swiftui-accessibility-techniques/A11yAgent/mcp-server/dist/index.js"],
         "env": {
           "A11Y_CHECK_PATH": "/path/to/ios-swiftui-accessibility-techniques/A11yAgent/.build/debug/a11y-check",
           "A11Y_PROJECT_ROOT": "/path/to/ios-swiftui-accessibility-techniques"
         }
       }
     }
   }
   ```

   Replace both paths with your real repo path. **A11Y_PROJECT_ROOT** makes relative paths (e.g. `["iOSswiftUIa11yTechniques"]`) resolve correctly. See [cursor-mcp-example.json](cursor-mcp-example.json).

## Tools exposed

| Tool | Description |
|------|-------------|
| **run_a11y_check** | Run a11y-check on given paths. Arguments: `paths` (required), optional `projectRoot`, `only`, `disable`, `maxDiagnostics` (default 100; limits how many diagnostics are returned so output shows in chat; use 0 for full list). |
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

The full loop — **detect, understand, fix** — happens conversationally without leaving the editor. The AI doesn't just report problems; it can explain why they matter for users with disabilities and make the code changes to resolve them.

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
