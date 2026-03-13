# A11y Checker (a11y-check)

Static analysis for Swift/SwiftUI accessibility issues, mapped to [WCAG 2.2](https://www.w3.org/TR/WCAG22/) success criteria. Runs on your source files and reports missing labels, incorrect traits, touch target sizes, color contrast, dynamic type, and more — with 23 rules across 10 WCAG criteria.

## Check your own iOS app

1. **Install** a11y-check once (see [Installation](#installation) below).
2. **Run it:** Open Terminal, go to your app's project folder, and run:

   ```bash
   cd /path/to/YourApp
   a11y-check .
   ```

   The `.` means "this folder" — a11y-check scans all `.swift` files recursively and prints issues with file and line.

**Quick tips:**

```bash
a11y-check . --only error          # Show only errors
a11y-check . --format xcode        # Output for Xcode build phases
a11y-check . --diff                # Only issues on lines you changed
a11y-check --list-rules            # List all 23 rules
```

## Installation

Requires Swift 5.9+ and macOS 13+.

### Homebrew (easiest)

```bash
git clone https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git
cd ios-swiftui-accessibility-techniques
brew tap cvs-health/ios-swiftui-accessibility-techniques file://$PWD
brew install --HEAD cvs-health/ios-swiftui-accessibility-techniques/a11y-check
```

If the build fails with `cannot find type 'SendableMetatype' in scope`, run:  
`env -u SDKROOT brew install --HEAD cvs-health/ios-swiftui-accessibility-techniques/a11y-check`

Then run `a11y-check` from anywhere. Run `which a11y-check` to confirm the install path (typically `/opt/homebrew/bin/a11y-check`).

> **Note:** If you later build a newer version from source, the Homebrew-installed binary remains at the old version until you reinstall. See [Keeping the binary up to date](#keeping-the-binary-up-to-date) under Xcode integration.

### Build from source

```bash
git clone https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git
cd ios-swiftui-accessibility-techniques/A11yAgent
swift build
```

The binary is at `.build/debug/a11y-check` (or `.build/release/a11y-check` after `swift build -c release`).

### Swift Package Manager plugin

Add a11y-check as a package dependency and run it without installing anything:

```swift
// In your app's Package.swift
dependencies: [
    .package(url: "https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git", from: "0.1.0"),
]
```

Then run:

```bash
swift package --allow-writing-to-package-directory a11y-check
```

The plugin scans all Swift source targets in your package automatically.

## Usage

```bash
# Check current directory (all .swift files)
a11y-check .

# Check a specific file or directory
a11y-check Sources/MyApp/
a11y-check Sources/Views/ProfileView.swift

# List all rules
a11y-check --list-rules

# Only show errors (skip warnings/info)
a11y-check . --only error

# Disable specific rules
a11y-check . --disable image-missing-label,fixed-font-size

# Use a config file
a11y-check . --config .a11ycheck.yml
```

### Output formats

```bash
# Default: colored terminal output
a11y-check .

# JSON (for CI pipelines and tooling)
a11y-check . --format json

# Xcode (for build phase scripts — shows inline in the editor)
a11y-check . --format xcode

# HTML report (WCAG summary, code snippets, fix suggestions)
a11y-check . --format html > report.html
```

### Diff-only mode

Only report issues on lines you changed — perfect for enforcing "no new accessibility issues" without drowning in legacy violations:

```bash
# Issues on uncommitted changes only
a11y-check . --diff

# Issues on changes vs. a branch
a11y-check . --diff --diff-base main
```

## Options

| Option | Description |
|--------|-------------|
| `paths` | File or directory paths to analyze (default: `.`) |
| `--format` | Output format: `terminal` (default), `json`, `xcode`, `html` |
| `--only` | Minimum severity: `info`, `warning`, or `error` |
| `--disable` | Comma-separated rule IDs to disable |
| `--config` | Path to `.a11ycheck.yml` config file (auto-detected if not specified) |
| `--diff` | Only report diagnostics on lines changed in the git diff |
| `--diff-base` | Git ref to diff against (default: `HEAD`). Use with `--diff` |
| `--list-rules` | Print all rules and exit |
| `--compact` | Suppress file path in output |

## Configuration file

Create a `.a11ycheck.yml` in your project root. a11y-check automatically finds it by walking up from the analysis path.

```yaml
# .a11ycheck.yml

# Override rule severities
severity_overrides:
  image-missing-label: warning    # downgrade from error
  hardcoded-color: info           # downgrade from warning

# Disable rules entirely
disabled_rules:
  - line-limit-1
  - fixed-font-size

# Allowlist mode: if non-empty, only these rules run
enabled_only: []

# Rule-specific options
options:
  min_touch_target: 44    # override small-touch-target threshold (default 24)
  contrast_ratio: 4.5     # WCAG AA contrast minimum

# Skip paths matching these patterns
exclude_paths:
  - "*/Generated/*"
  - "*/Pods/*"
  - "*Tests*"
```

CLI flags (`--disable`, `--only`) are applied on top of the config file.

## Inline suppression

Suppress specific diagnostics directly in your source code:

```swift
// Suppress a specific rule on this line
Image(systemName: "star") // a11y-check:disable image-missing-label

// Suppress multiple rules
Image(systemName: "star") // a11y-check:disable image-missing-label, image-label-contains-role

// Suppress all rules on this line
Image(systemName: "star") // a11y-check:disable

// Suppress on the next line
// a11y-check:disable-next-line image-missing-label
Image(systemName: "star")
```

## Xcode integration

Add a11y-check as a **Run Script** build phase so issues appear inline in Xcode's editor, just like compiler warnings.

### Setup

1. In Xcode, select your target → **Build Phases** → **+** → **New Run Script Phase**.
2. Name the phase **a11y-check** (double-click the title).
3. Add this script (use the **full path** to the binary — see note below):

   ```bash
   /opt/homebrew/bin/a11y-check "${SRCROOT}/YourAppName" --format xcode || true
   ```

   Replace `YourAppName` with the folder containing your Swift source files. `${SRCROOT}` is the directory containing your `.xcodeproj` file.

4. **Uncheck** "Based on dependency analysis" — otherwise Xcode may cache old results and skip running the script.
5. Build your project. Accessibility issues appear as inline errors and warnings in the editor.

### Important: use the full path to the binary

Xcode build scripts run with a minimal `/bin/sh` environment that does **not** inherit your shell's `PATH`. Even if `a11y-check` works fine in Terminal, Xcode won't find it by name alone. Always use the absolute path:

```bash
# Good — Xcode can find this
/opt/homebrew/bin/a11y-check "${SRCROOT}/Sources" --format xcode || true

# Bad — Xcode can't find this (not in its PATH)
a11y-check "${SRCROOT}/Sources" --format xcode || true
```

Find your binary path by running `which a11y-check` in Terminal. If you built from source instead of Homebrew, use the full path to `.build/debug/a11y-check` or `.build/release/a11y-check`.

### Performance: scope the scan

Scanning your entire source tree can take **30–60+ seconds** on large projects, which slows down every build. To keep builds fast:

```bash
# Slow — scans everything recursively
/opt/homebrew/bin/a11y-check "${SRCROOT}" --format xcode || true

# Better — scope to just your source directory
/opt/homebrew/bin/a11y-check "${SRCROOT}/YourAppName" --format xcode || true

# Fastest — scan specific files
/opt/homebrew/bin/a11y-check "${SRCROOT}/YourAppName/Views/ProfileView.swift" --format xcode || true
```

Exclude generated code and third-party dependencies by scoping the path or using an [`.a11ycheck.yml` config file](#configuration-file) with `exclude_paths`.

### Exit codes and `|| true`

a11y-check exits with code **1** when any error-severity diagnostic is found. Without `|| true`, this causes Xcode to treat the build phase as a failure, which **stops the build**. Add `|| true` to let the build continue while still showing the inline annotations:

```bash
# Build continues even with errors (recommended during development)
/opt/homebrew/bin/a11y-check "${SRCROOT}/Sources" --format xcode || true

# Build fails on accessibility errors (recommended for CI or strict enforcement)
/opt/homebrew/bin/a11y-check "${SRCROOT}/Sources" --format xcode
```

### Keeping the binary up to date

If you installed via Homebrew and later build a newer version from source, the Homebrew binary at `/opt/homebrew/bin/a11y-check` may be outdated and missing new features like `--format xcode`. To update it:

```bash
# Option 1: reinstall via Homebrew
brew reinstall --HEAD cvs-health/ios-swiftui-accessibility-techniques/a11y-check

# Option 2: copy the locally built binary over the Homebrew one
brew unlink a11y-check
cp A11yAgent/.build/debug/a11y-check /opt/homebrew/bin/a11y-check
```

### Output format

The `--format xcode` output uses the format Xcode expects for inline annotations:

```
/path/to/File.swift:42:13: error: [rule-id] Message text [WCAG X.Y.Z]
/path/to/File.swift:58:9: warning: [rule-id] Message text [WCAG X.Y.Z]
```

Xcode picks these up automatically and displays them in both the source editor (inline) and the Issue Navigator (left panel). You can filter the Issue Navigator by typing a rule ID (e.g. `textfield-missing-label`) to find a11y-check issues specifically.

## HTML report

Generate a self-contained HTML report for sharing with teams or compliance reviews:

```bash
a11y-check Sources/ --format html > accessibility-report.html
```

The report includes:

- **Summary banner** with error, warning, and info counts
- **WCAG 2.2 conformance table** showing pass/fail for each criterion, linked to the WCAG spec
- **By-file detail** with expandable sections for each file's issues
- **By-rule summary** showing issue counts per rule

### Code snippets and fix suggestions

Every diagnostic in the report shows three things to help you understand and fix the issue:

1. **Bad code** — a dark code block showing the offending line (highlighted in red) with one line of context above and below, with line numbers.
2. **Fix suggestion** — a green "Fix:" badge with a specific action, e.g. *"Add a visible Text("First Name") above the field and .accessibilityLabel("First Name")"*.
3. **Corrected code** — a green code block showing the suggested fix applied to the original code. For form control labels, this includes both the visible `Text` label inserted above the field and the `.accessibilityLabel()` modifier appended below.

This makes the report actionable — developers can see exactly what's wrong, why, and how to fix it without needing to look anything up.

### Generate via AI (MCP)

If you have the [MCP server](#mcp-cursor--ai-assistants) set up, ask your AI assistant:

> "Generate an HTML accessibility report for this project"

The AI runs `a11y-check . --format html > accessibility-report.html` in the terminal and opens the report in your browser.

## CI integration

### GitHub Actions

```yaml
- name: Checkout repo
  uses: actions/checkout@v4
- name: Accessibility check
  run: |
    brew tap cvs-health/ios-swiftui-accessibility-techniques file://$PWD
    brew install --HEAD cvs-health/ios-swiftui-accessibility-techniques/a11y-check
    a11y-check Sources/ --format json --only error
```

### Diff-only in CI (no new issues)

Only fail the build if the PR introduces new accessibility errors:

```yaml
- name: Accessibility check (changed files only)
  run: |
    a11y-check Sources/ --diff --diff-base origin/main --only error
```

### HTML report as artifact

```yaml
- name: Generate accessibility report
  run: a11y-check Sources/ --format html > accessibility-report.html
- name: Upload report
  uses: actions/upload-artifact@v4
  with:
    name: accessibility-report
    path: accessibility-report.html
```

The CLI exits with code **1** when any diagnostic has severity **error**, so the step fails the job.

## MCP (Cursor / AI assistants)

An [MCP server](mcp-server/README.md) is included so AI assistants like Cursor can run a11y-check through natural language — no terminal commands needed. The AI calls the tool behind the scenes, explains the results, and can fix the issues for you.

### Quick setup

1. Install a11y-check (Homebrew or build from source).
2. Install the MCP server dependencies:
   ```bash
   cd A11yAgent/mcp-server && npm install && npm run build
   ```
3. Add to **Cursor Settings → Features → MCP → Edit config**:
   ```json
   {
     "mcpServers": {
       "a11y-check": {
         "command": "node",
         "args": ["/path/to/A11yAgent/mcp-server/dist/index.js"]
       }
     }
   }
   ```
4. Restart Cursor.

See the [MCP server README](mcp-server/README.md) for full setup options including local builds and environment variables.

### What you can ask

Once the MCP server is running, ask your AI assistant things like:

- **"Check this project for accessibility issues"** — scans your source files and returns a summary of all issues found
- **"Run a11y-check on TextFieldsView.swift"** — check a specific file
- **"Which of those are the most critical to fix?"** — the AI explains severity and WCAG impact
- **"Fix the textfield-missing-label issues"** — the AI edits your code to add the missing labels
- **"List all the a11y rules"** — shows all 23 rules with descriptions and WCAG criteria
- **"What WCAG criteria does this project fail?"** — the AI interprets the results and maps them to compliance requirements
- **"Generate an HTML accessibility report for this project"** — the AI runs `a11y-check . --format html > accessibility-report.html` in the terminal, then opens the report in your browser. The report includes a WCAG conformance table, per-file breakdown with code snippets and fix suggestions, and per-rule summary — ready to share with your team or compliance reviewers.

The full loop — detect, understand, fix, report — happens conversationally without leaving the editor.

## Rules

a11y-check includes 23 rules across these categories:

| Category | Rules | WCAG |
|----------|-------|------|
| **Images** | `image-missing-label`, `image-label-contains-role` | 1.1.1 |
| **Headings** | `heading-trait-missing`, `fake-heading-in-label` | 1.3.1 |
| **Color & contrast** | `hardcoded-color`, `color-contrast-insufficient` | 1.4.3 |
| **Dynamic type** | `fixed-font-size`, `line-limit-1` | 1.4.4 |
| **Focus** | `sheet-focus-return` | 2.4.3, 2.1.2 |
| **Page titles** | `missing-navigation-title` | 2.4.2 |
| **Links** | `generic-link-text`, `button-used-as-link` | 2.4.4, 4.1.2 |
| **Touch targets** | `small-touch-target` | 2.5.8 |
| **Buttons** | `button-label-contains-role`, `icon-button-missing-label`, `visually-disabled-not-semantic` | 4.1.2 |
| **Traits** | `tap-gesture-missing-button-trait` | 4.1.2 |
| **Toggles** | `toggle-missing-label` | 4.1.2 |
| **Form controls** | `textfield-missing-label`, `slider-missing-label`, `stepper-missing-label`, `picker-missing-label` | 4.1.2 |
| **Accessibility hidden** | `hidden-parent-with-controls` | 4.1.2 |

The **textfield-missing-label** rule catches two problems:
- **Error:** TextField/SecureField with an empty `""` label and no `.accessibilityLabel()` — VoiceOver users won't know what to enter.
- **Warning:** TextField/SecureField using placeholder text as its label (e.g. `TextField("First Name", text: $name)` without a `prompt:` parameter or `.accessibilityLabel()`). Placeholder text disappears when the user starts typing and renders in low-contrast gray, failing both WCAG 3.3.2 (Labels or Instructions) and 1.4.3 (Contrast). Use a visible `Text` label above the field, or use the `prompt:` parameter to separate the placeholder from the label.

The **color contrast** rule computes actual WCAG 2.x contrast ratios when both foreground and background colors can be resolved — including SwiftUI system colors (`.black`, `.white`, `.red`, etc.), `Color(red:green:blue:)` literals, hex patterns, and named colors from your `.xcassets` catalogs.

Run `a11y-check --list-rules` for full descriptions and severities.

## Troubleshooting

### "a11y-check: command not found" in Xcode

Xcode build scripts use a minimal PATH that doesn't include `/opt/homebrew/bin`. Use the **full path** to the binary in your Run Script build phase. See [Xcode integration](#xcode-integration).

### No warnings appear in Xcode after building

| Check | Fix |
|-------|-----|
| **Old binary** — does `a11y-check --help` show `--format xcode`? | [Update the binary](#keeping-the-binary-up-to-date). Homebrew installs can be outdated. |
| **"Based on dependency analysis" is checked** | Uncheck it in the build phase settings so Xcode runs the script every build. |
| **Wrong source path** | `${SRCROOT}` is the folder containing `.xcodeproj`. Print it with `echo "${SRCROOT}" > /tmp/srcroot.txt` in the script to verify. |
| **Binary not at expected path** | Run `which a11y-check` in Terminal and make sure the path in the script matches. |

**Debug tip:** Temporarily change your build phase script to write output to a file so you can inspect it:

```bash
echo "SRCROOT=${SRCROOT}" > /tmp/a11y-check-debug.log
/opt/homebrew/bin/a11y-check "${SRCROOT}/YourAppName" --format xcode >> /tmp/a11y-check-debug.log 2>&1
echo "EXIT CODE: $?" >> /tmp/a11y-check-debug.log
```

After building, open `/tmp/a11y-check-debug.log` to see what happened.

### Build is slow after adding a11y-check

Scanning a large project can take 30–60+ seconds. Scope the scan to a specific subdirectory or file instead of the project root. See [Performance: scope the scan](#performance-scope-the-scan).

### `cannot find type 'SendableMetatype' in scope` during Homebrew install

Run the install with SDKROOT cleared:

```bash
env -u SDKROOT brew install --HEAD cvs-health/ios-swiftui-accessibility-techniques/a11y-check
```

## License

Apache License 2.0 — see the [repository root LICENSE](../LICENSE).
