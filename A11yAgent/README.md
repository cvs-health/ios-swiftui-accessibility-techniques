# A11y Checker (a11y-check)

Static analysis for Swift/SwiftUI accessibility issues, mapped to [WCAG 2.2](https://www.w3.org/TR/WCAG22/) success criteria. Runs on your source files and reports missing labels, incorrect traits, touch target size, dynamic type, and more.

## Installation

Requires Swift 5.9+ and macOS 13+.

### From source (recommended)

```bash
git clone https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git
cd ios-swiftui-accessibility-techniques/A11yAgent
swift build
```

Run the binary directly (no need to type `swift run`):  
`.build/debug/a11y-check` or, after `swift build -c release`, `.build/release/a11y-check`.  
Example: `./.build/debug/a11y-check .`

### Homebrew (from repo formula)

From the repo root (parent of `Formula/`):

```bash
brew install --build-from-source ./Formula/a11y-check.rb
```

Then run `a11y-check` from anywhere.

## Usage

```bash
# Check current directory (all .swift files)
a11y-check .

# Check a specific file or directory
a11y-check Sources/MyApp/
a11y-check Sources/Views/ProfileView.swift

# List all rules
a11y-check --list-rules

# Only show errors (ignore warnings/info)
a11y-check . --only error

# JSON output (e.g. for CI)
a11y-check Sources/ --format json

# Disable specific rules
a11y-check . --disable image-missing-label,fixed-font-size

# Compact output (omit file path; useful for single-file)
a11y-check Sources/MyView.swift --compact
```

## Options

| Option | Description |
|--------|-------------|
| `paths` | File or directory paths to analyze (default: `.`) |
| `--format` | `terminal` (default) or `json` |
| `--only` | Minimum severity: `info`, `warning`, or `error` |
| `--disable` | Comma-separated rule IDs to disable |
| `--list-rules` | Print all rules and exit |
| `--compact` | Suppress file path in output |

## CI integration

Use JSON and the exit code to fail the build on accessibility errors:

```yaml
# Example: GitHub Actions (install from repo formula; tap not required)
- name: Checkout repo
  uses: actions/checkout@v4
- name: Accessibility check
  run: |
    brew install --build-from-source ./Formula/a11y-check.rb
    a11y-check Sources/ --format json --only error
```

The CLI exits with code **1** when any diagnostic has severity **error**, so the step fails the job.

## MCP (Cursor / AI assistants)

An [MCP server](mcp-server/README.md) is included so AI assistants like Cursor can run a11y-check when you ask (e.g. “check this project for accessibility”). Install a11y-check and Node.js, then add the server to your MCP config and point it at `A11yAgent/mcp-server`.

## Rules

Rules cover images, buttons, headings, toggles, links, touch targets, dynamic type, navigation titles, form controls, and more. Each rule is tied to WCAG 2.2 criteria. Run `a11y-check --list-rules` to see IDs, descriptions, and severities.

## License

Apache License 2.0 — see the [repository root LICENSE](../LICENSE).