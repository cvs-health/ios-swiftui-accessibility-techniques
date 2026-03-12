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

Then run `a11y-check` from anywhere.

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

# HTML report (self-contained page with WCAG conformance summary)
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

Add a11y-check as a **Run Script** build phase so issues appear inline in Xcode's editor:

1. In Xcode, select your target → **Build Phases** → **+** → **New Run Script Phase**.
2. Add this script:

   ```bash
   if command -v a11y-check &> /dev/null; then
       a11y-check "${SRCROOT}/Sources" --format xcode
   fi
   ```

3. Build your project. Accessibility issues appear as inline warnings and errors.

The `--format xcode` output uses the format Xcode expects:  
`file:line:column: warning: [rule-id] message [WCAG criteria]`

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

An [MCP server](mcp-server/README.md) is included so AI assistants like Cursor can run a11y-check when you ask (e.g. "check this project for accessibility"). Install a11y-check and Node.js, then add the server to your MCP config and point it at `A11yAgent/mcp-server`.

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

The **color contrast** rule computes actual WCAG 2.x contrast ratios when both foreground and background colors can be resolved — including SwiftUI system colors (`.black`, `.white`, `.red`, etc.), `Color(red:green:blue:)` literals, hex patterns, and named colors from your `.xcassets` catalogs.

Run `a11y-check --list-rules` for full descriptions and severities.

## License

Apache License 2.0 — see the [repository root LICENSE](../LICENSE).
