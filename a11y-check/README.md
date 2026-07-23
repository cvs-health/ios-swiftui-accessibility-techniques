# A11y Checker (a11y-check)

![a11y score](a11y-badge.svg)

Static analysis for Swift/SwiftUI accessibility issues, mapped to [WCAG 2.2](https://www.w3.org/TR/WCAG22/) success criteria. Runs on your source files and reports missing labels, incorrect traits, touch target sizes, color contrast, dynamic type, and more — with 37 rules across 19 WCAG criteria. Includes a **WCAG 2.2 scoring system** that grades your files or entire project from 0–100.

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
a11y-check MyView.swift --lines 50-120  # Check only specific lines
a11y-check . --fix                 # Auto-fix issues where possible
a11y-check . --fix --dry-run       # Preview fixes without applying
a11y-check . --per-view            # Score each SwiftUI View separately
a11y-check . --no-trend            # Disable automatic trend tracking
a11y-check --baseline-save         # Save current issues as baseline
a11y-check . --baseline            # Only report new issues (not in baseline)
a11y-check . --format sarif > results.sarif  # SARIF for GitHub code scanning
a11y-check . --badge > badge.svg   # Score badge for README
a11y-check . --watch               # Re-run on file changes
a11y-check --generate-docs > RULES.md  # Generate rule docs
a11y-check --list-rules            # List all 37 rules
```

Every run automatically includes a **WCAG 2.2 accessibility score** (0–100 with letter grade) after the diagnostics. Use `--min-score 80` to fail CI if the score drops below a threshold.

## Installation

Requires Swift 5.9+ and macOS 13+.

### Homebrew (easiest)

```bash
brew tap cvs-health/ios-swiftui-accessibility-techniques https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git
brew install --HEAD cvs-health/ios-swiftui-accessibility-techniques/a11y-check
```

If the build fails with `cannot find type 'SendableMetatype' in scope`, run:  
`env -u SDKROOT brew install --HEAD cvs-health/ios-swiftui-accessibility-techniques/a11y-check`

Then run `a11y-check` from anywhere. Run `a11y-check --version` to verify the install. Run `which a11y-check` to confirm the install path (typically `/opt/homebrew/bin/a11y-check`).

> **Note:** If you later build a newer version from source, the Homebrew-installed binary remains at the old version until you reinstall. See [Keeping the binary up to date](#keeping-the-binary-up-to-date) under Xcode integration.

### Build from source

```bash
git clone https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git
cd ios-swiftui-accessibility-techniques/a11y-check
./generate-build-info.sh   # optional: embeds git commit in --version output
swift build
```

The binary is at `.build/debug/a11y-check` (or `.build/release/a11y-check` after `swift build -c release`).

### Swift Package Manager plugin

Add a11y-check as a package dependency and run it without installing anything:

**In Xcode:** File > Add Package Dependencies > paste:
```
https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git
```

**Or in your Package.swift:**
```swift
dependencies: [
    .package(url: "https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git", branch: "main"),
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

# SARIF (for GitHub code scanning)
a11y-check . --format sarif > results.sarif
```

### Diff-only mode

Only report issues on lines you changed — perfect for enforcing "no new accessibility issues" without drowning in legacy violations:

```bash
# Issues on uncommitted changes only
a11y-check . --diff

# Issues on changes vs. a branch
a11y-check . --diff --diff-base main
```

## Accessibility scoring

Every `a11y-check` run automatically calculates a **WCAG 2.2 accessibility score** (0–100) with a letter grade and appends it after the diagnostics. No extra commands needed — the score appears in all output formats (terminal, JSON, Xcode, and HTML).

```
5 errors, 3 warnings in 4 files

WCAG Score: 62.5 / 100  (D)
  [████████████░░░░░░░░]   62.5%  8 criteria passed, 2 failed — 5 errors, 3 warnings

Failed WCAG criteria:
  ✗ 1.1.1 Non-text Content  (3 errors)
  ✗ 1.3.1 Info and Relationships  (2 errors, 1 warning)

Needs review:
  ⚠ 2.4.6 Headings and Labels  (1 warning)
```

Use `--min-score` to enforce a minimum score threshold:

```bash
# Fail if score drops below 80
a11y-check . --min-score 80
```

### What the score includes

- **Overall score** (0–100) with a letter grade (A+ through F)
- **Failed WCAG criteria** — lists each failed success criterion with error/warning counts
- **Needs review** — criteria with warnings but no errors
- **HTML reports** additionally include a full 48-criteria WCAG 2.2 conformance table with per-criterion status and links to the spec
- **JSON output** includes a `score` object alongside `diagnostics` with grade, failed criteria, and review criteria

### Impact levels

Every rule has an **impact** level that describes how much a violation affects users with disabilities, independent of WCAG conformance status:

| Impact | Meaning | Example rules |
|--------|---------|---------------|
| **Critical** | Content completely inaccessible | `image-missing-label`, `textfield-missing-label`, `hidden-parent-with-controls` |
| **Serious** | Major barrier, workaround may exist | `color-contrast-insufficient`, `small-touch-target`, `heading-trait-missing` |
| **Moderate** | Inconvenient but usable | `input-missing-purpose`, `button-label-contains-role` |
| **Minor** | Annoyance, best-practice | `image-label-contains-role`, `hardcoded-color` |

Impact appears as a badge in HTML reports, as a label in terminal/Xcode output, and as a field in JSON and SARIF output.

### How scoring works

The overall score combines two components equally:

1. **Criteria coverage (50%)** — what percentage of checked WCAG criteria pass. Errors cause a criterion to fail; warnings put it in "review" status (counted as a conditional pass with a small penalty).
2. **Issue density (50%)** — a deduction based on issue counts normalized across files, **weighted by impact**. Base penalties are: errors −5, warnings −2, info −0.5. These are then multiplied by an impact weight:
   - Critical: **2.0x** (a critical error deducts 10 points)
   - Serious: **1.5x** (a serious error deducts 7.5 points)
   - Moderate: **1.0x** (unchanged)
   - Minor: **0.5x** (a minor warning deducts only 1 point)

Per-file scores start at 100 and deduct per issue using the same severity weights. The letter grade maps the overall score to a traditional A+–F scale.

### Scoring in CI

Use `--min-score` as a quality gate to prevent accessibility regressions:

```yaml
- name: Accessibility check
  run: a11y-check Sources/ --min-score 80
```

Or capture the full output (diagnostics + score) as JSON:

```yaml
- name: Accessibility check
  run: a11y-check Sources/ --format json > a11y-results.json
- name: Upload results
  uses: actions/upload-artifact@v4
  with:
    name: a11y-results
    path: a11y-results.json
```

## Auto-fix

Use `--fix` to automatically apply available fixes to your source files:

```bash
a11y-check . --fix
```

Preview what would change without modifying files:

```bash
a11y-check . --fix --dry-run
```

### Rules with auto-fix

| Rule | Fix applied |
|---|---|
| `heading-trait-missing` | Appends `.accessibilityAddTraits(.isHeader)` to the view's modifier chain |
| `fake-heading-in-label` | Removes the word "heading" from the `.accessibilityLabel()` string |
| `image-label-contains-role` | Removes role words ("image", "icon", "graphic") from the label string |
| `missing-accessibility-grouping` | Appends `.accessibilityElement(children: .combine)` to the HStack/VStack |
| `button-group-missing-container-label` | Appends `.accessibilityElement(children: .contain)` to the button group container |
| `fixed-font-size` | Replaces `.font(.system(size: N))` with `.font(.body)` |
| `line-limit-1` | Removes `.lineLimit(1)` entirely |
| `hardcoded-color` | Removes the hardcoded color modifier (`.foregroundColor(.black)`, etc.) to restore SwiftUI's adaptive defaults |
| `input-missing-purpose` | Appends `.textContentType(...)` with the inferred content type |
| `button-label-contains-role` | Removes the word "button" from the `.accessibilityLabel()` string |
| `small-touch-target` | Increases `.frame(width:height:)` to the 24×24pt minimum |

Use `--dry-run` to preview all fixes without modifying files.

After applying fixes, `a11y-check` re-analyzes and shows the updated score.

## Trend tracking

Score tracking is **automatic** — every run records the score, grade, error count, and git commit hash to `.a11y-scores.json` in the project directory. Once you have history from previous runs, the output automatically shows a sparkline, delta from the last run, and a history table:

```
Score Trend:
  Change from last run: +4.2
  History: ▃▄▅▅▆▇

  Date                          Score  Grade  Errors  Δ
  2025-04-01T10:00:00Z          72.5   C      12      —
  2025-04-03T14:30:00Z          76.8   C      8       +4.3
  → now                          81.0   B-     5       +4.2
```

Use `--format json` to get machine-readable trend data. Use `--no-trend` to disable tracking.

## Per-view scoring

Use `--per-view` to score each SwiftUI `View` struct independently:

```bash
a11y-check . --per-view
```

This detects all `struct X: View` declarations and shows a score for each, sorted worst-first:

```
Per-View Scores:
  [███████░░░░░░░░░░░░░]  37.5 (F)  BadFormView  Views/FormView.swift:45-120  (11 errors)
  [████████████████████]  100.0 (A+) GoodFormView  Views/FormView.swift:5-43
  [████████████████████]  100.0 (A+) HomeView  Views/HomeView.swift:1-80
```

## SARIF output (GitHub Code Scanning)

Generate [SARIF](https://docs.oasis-open.org/sarif/sarif/v2.1.0/sarif-v2.1.0.html) output for GitHub code scanning. Issues appear as annotations directly on PR diffs:

```bash
a11y-check Sources/ --format sarif > results.sarif
```

Upload to GitHub in your workflow:

```yaml
- name: Run a11y-check
  run: a11y-check Sources/ --format sarif > results.sarif
- name: Upload SARIF
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: results.sarif
```

> **Requires GitHub Advanced Security (GHAS).** The `upload-sarif` step only works on public repositories or private repositories with GHAS enabled. Without it, the upload step will fail with "Resource not accessible by integration" — but the rest of the workflow (PR score comment, artifact upload, Slack notification) works without GHAS. To enable GHAS on a private repo, go to **Settings → Security → Code security and analysis → Code scanning → Enable**.

## Score badge

Generate an SVG badge showing your project's accessibility score:

```bash
# SVG badge file
a11y-check Sources/ --badge > a11y-badge.svg

# Or use a shields.io URL in your README (run a11y-check to get the score first)
```

Add to your README:

```markdown
![a11y score](a11y-badge.svg)
```

## Watch mode

Re-run analysis automatically when files change — useful during development:

```bash
a11y-check Sources/ --watch
```

Press `Ctrl+C` to stop. Each time a `.swift` file is modified, a11y-check re-runs and prints updated results.

## Report diff

Compare current results against a previous JSON report to see only **new** issues:

```bash
# Save a report
a11y-check Sources/ --format json > baseline-report.json

# Later, compare against it
a11y-check Sources/ --diff-report baseline-report.json
```

## Rule documentation generator

Generate a complete Markdown reference for all rules:

```bash
a11y-check --generate-docs > RULES.md
```

The generated document includes a summary table, grouping by WCAG criterion, and grouping by severity.

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
| `--min-score` | Minimum passing score (0–100). Exits with error code 1 if below threshold |
| `--lines` | Only check lines in a range, e.g. `50-120`. Comma-separated for multiple ranges: `10-30,80-100` |
| `--fix` | Automatically apply available fixes to source files |
| `--dry-run` | Show what `--fix` would change without modifying files |
| `--trend` / `--no-trend` | Score trend tracking (enabled by default). Use `--no-trend` to disable |
| `--per-view` | Show per-SwiftUI-View scores in addition to the overall score |
| `--baseline-save` | Save current issues as baseline (`.a11y-baseline.json`). Future `--baseline` runs only report new issues |
| `--baseline` | Filter out issues in the baseline — only new regressions are shown |
| `--badge` | Generate an SVG score badge to stdout |
| `--watch` | Watch for file changes and re-run analysis automatically |
| `--diff-report` | Compare against a previous JSON report — only new issues shown |
| `--generate-docs` | Generate Markdown rule documentation to stdout |

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

There are two ways to run a11y-check in Xcode. Pick whichever fits your project:

| | **Build Plugin (SPM)** | **Run Script** |
|---|---|---|
| **How it works** | Add the package as an SPM dependency — the plugin runs automatically | Add a shell script build phase that calls the Homebrew binary |
| **Requires Homebrew** | No — SPM builds the tool from source | Yes |
| **Errors fail the build** | Yes — errors block the build | No — `|| true` lets the build continue |
| **Best for** | Strict enforcement, CI pipelines | Development, gradual adoption |

Both approaches show accessibility issues inline in Xcode's editor and Issue Navigator.

### Option A: Build Plugin (SPM)

Add `a11y-check` as a package dependency and attach the build plugin to your target.

**In `Package.swift`:**

```swift
dependencies: [
    .package(url: "https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git", branch: "main"),
],
targets: [
    .target(
        name: "MyApp",
        plugins: [
            .plugin(name: "A11yCheckBuildPlugin", package: "a11y-check"),
        ]
    ),
]
```

**In Xcode (without `Package.swift`):**

1. File → Add Package Dependencies
2. Enter `https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git`, set branch to `main`
3. Select your target → Build Phases → expand **Run Build Tool Plug-ins** → click **+** → select `A11yCheckBuildPlugin` → click **Add**

Build your project. Accessibility errors and warnings appear inline. **Errors will fail the build** — fix them or use [inline suppression](#inline-suppression) to silence specific diagnostics. To downgrade a rule from error to warning, use a [`.a11ycheck.yml` config file](#configuration-file) with `severity_overrides`.

### Option B: Run Script

Install via Homebrew, then add a Run Script build phase. Errors appear inline but **don't block the build**.

**1. Install a11y-check:**

```bash
brew install --HEAD cvs-health/ios-swiftui-accessibility-techniques/a11y-check
```

**2. Add the Run Script build phase:**

1. In Xcode, select your target → **Build Phases** → **+** → **New Run Script Phase**
2. Name the phase **a11y-check** (double-click the title)
3. Add this script:

   ```bash
   /opt/homebrew/bin/a11y-check "${SRCROOT}/YourAppName" --format xcode || true
   ```

   Replace `YourAppName` with the folder containing your Swift source files. `${SRCROOT}` is the directory containing your `.xcodeproj`.

4. **Uncheck** "Based on dependency analysis" — otherwise Xcode may cache old results
5. In Build Settings, search for **"User Script Sandboxing"** and set it to **No** — otherwise Xcode blocks the script from reading your source files
6. Build your project

The `|| true` at the end means accessibility errors show inline but don't stop the build. Remove `|| true` if you want errors to fail the build.

> **Important: use the full path to the binary.** Xcode build scripts run with a minimal `PATH` that won't find `a11y-check` by name alone. Always use `/opt/homebrew/bin/a11y-check` (or run `which a11y-check` to find your path).

### Performance: scope the scan

Scanning your entire source tree can take **30–60+ seconds** on large projects. Scope the path to keep builds fast:

```bash
# Slow — scans everything
/opt/homebrew/bin/a11y-check "${SRCROOT}" --format xcode || true

# Better — scope to your source directory
/opt/homebrew/bin/a11y-check "${SRCROOT}/YourAppName" --format xcode || true

# Fastest — scan specific files
/opt/homebrew/bin/a11y-check "${SRCROOT}/YourAppName/Views/ProfileView.swift" --format xcode || true
```

You can also exclude paths using an [`.a11ycheck.yml` config file](#configuration-file) with `exclude_paths`.

### Keeping the binary up to date

If you use the Run Script approach, the Homebrew binary may become outdated. To update:

```bash
brew uninstall a11y-check && brew install --HEAD cvs-health/ios-swiftui-accessibility-techniques/a11y-check
```

Check your version with:

```bash
a11y-check --version
# Example output: 0.3.0 (abc1234 2026-05-04)
```

### Troubleshooting

**"Tap remote mismatch" error:**  
If you previously installed with `file://$PWD` and now see `file:///... != https://...`, fix it with:

```bash
brew tap --force cvs-health/ios-swiftui-accessibility-techniques https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git
```

**"already installed, it's just not linked":**  
Run `brew link cvs-health/ios-swiftui-accessibility-techniques/a11y-check` to link the binary.

**"Error: invalid option: --HEAD":**  
`brew reinstall` does not support `--HEAD`. Uninstall first, then install:

```bash
brew uninstall a11y-check
brew install --HEAD cvs-health/ios-swiftui-accessibility-techniques/a11y-check
```

**"No such file or directory" during install:**  
If `brew install` fails with `Dir.chdir` or "no such file or directory", the local tap has a stale formula. Re-tap from GitHub:

```bash
brew untap cvs-health/ios-swiftui-accessibility-techniques
brew tap cvs-health/ios-swiftui-accessibility-techniques https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git
brew install --HEAD cvs-health/ios-swiftui-accessibility-techniques/a11y-check
```

**Old version after update:**  
If `a11y-check --version` shows an old version (e.g. `0.1.0` without a commit hash), uninstall and reinstall:

```bash
brew uninstall a11y-check && brew install --HEAD cvs-health/ios-swiftui-accessibility-techniques/a11y-check
```

**No annotations in Xcode (Run Script):**  
Most likely **User Script Sandboxing** is enabled, which blocks the script from reading your source files. Go to Build Settings → search "User Script Sandboxing" → set to **No**.

If that doesn't fix it, debug by temporarily changing the Run Script to write output to a file:

```bash
echo "SRCROOT=${SRCROOT}" > /tmp/a11y-check-debug.log
ls "${SRCROOT}/YourAppName" >> /tmp/a11y-check-debug.log 2>&1
/opt/homebrew/bin/a11y-check "${SRCROOT}/YourAppName" --format xcode >> /tmp/a11y-check-debug.log 2>&1
echo "EXIT CODE: $?" >> /tmp/a11y-check-debug.log
```

After building, run `cat /tmp/a11y-check-debug.log` in Terminal. If you see "Operation not permitted", User Script Sandboxing is still on. Once it's working, switch the Run Script back to the normal command so Xcode can see the output.

### Output format

The `--format xcode` output uses the format Xcode expects for inline annotations:

```
/path/to/File.swift:42:13: error: [rule-id] Message text [WCAG X.Y.Z]
/path/to/File.swift:58:9: warning: [rule-id] Message text [WCAG X.Y.Z]
```

Xcode picks these up automatically and displays them in both the source editor (inline) and the Issue Navigator (left panel).

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

A ready-to-use workflow is included at [`a11y-check/.github/workflows/a11y-check.yml`](.github/workflows/a11y-check.yml). It:

1. Builds a11y-check from source
2. Runs the accessibility check
3. Posts the score as a **PR comment** with WCAG criteria pass/fail
4. Uploads JSON results as an artifact
5. Fails the job if the score is below the configurable threshold

Copy it to your repo's `.github/workflows/` directory. Set the `MIN_SCORE` and `PATHS` environment variables at the top of the file.

Alternatively, use a simpler inline step:

```yaml
- name: Checkout repo
  uses: actions/checkout@v4
- name: Build a11y-check
  run: cd a11y-check && swift build -c release && echo "$(pwd)/.build/release" >> $GITHUB_PATH
- name: Accessibility check
  run: a11y-check Sources/ --min-score 70
```

### Diff-only in CI (no new issues)

Only fail the build if the PR introduces new accessibility errors:

```yaml
- name: Accessibility check (changed files only)
  run: |
    a11y-check Sources/ --diff --diff-base origin/main --only error
```

### Baseline mode in CI

Save a baseline of known issues then only fail on **new regressions**:

```bash
# Once: save the current state as baseline (commit this file)
a11y-check Sources/ --baseline-save

# In CI: only new issues fail the build
a11y-check Sources/ --baseline
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
   cd a11y-check/mcp-server && npm install && npm run build
   ```
3. Add to **Cursor Settings → Features → MCP → Edit config**:
   ```json
   {
     "mcpServers": {
       "a11y-check": {
         "command": "node",
         "args": ["/path/to/a11y-check/mcp-server/dist/index.js"]
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
- **"List all the a11y rules"** — shows all 37 rules with descriptions and WCAG criteria
- **"What WCAG criteria does this project fail?"** — the AI interprets the results and maps them to compliance requirements
- **"What's the accessibility score for this project?"** — runs `a11y-check .` and explains the WCAG 2.2 score breakdown
- **"Score ProfileView.swift"** — runs the check on a single file and highlights what to fix based on the score
- **"Generate an HTML accessibility report for this project"** — the AI runs `a11y-check . --format html > accessibility-report.html` in the terminal, then opens the report in your browser. The report includes a WCAG conformance table, per-file breakdown with code snippets and fix suggestions, and per-rule summary — ready to share with your team or compliance reviewers.

The full loop — detect, understand, fix, report — happens conversationally without leaving the editor.

## Rules

a11y-check includes 37 rules across these categories:

| Category | Rules | WCAG | Impact |
|----------|-------|------|--------|
| **Images** | `image-missing-label`, `image-label-contains-role` | 1.1.1 | Critical, Minor |
| **Headings** | `heading-trait-missing`, `fake-heading-in-label` | 2.4.6, 1.3.1 | Serious, Serious |
| **Color & contrast** | `hardcoded-color`, `color-contrast-insufficient` | 1.4.3 | Minor, Serious |
| **Dynamic type** | `fixed-font-size`, `line-limit-1` | 1.4.4 | Serious, Serious |
| **Focus** | `sheet-focus-return` | 2.4.3, 2.1.2 | Serious |
| **Page titles** | `missing-navigation-title` | 2.4.2 | Serious |
| **Links** | `generic-link-text`, `button-used-as-link` | 2.4.4, 4.1.2 | Serious, Serious |
| **Touch targets** | `small-touch-target` | 2.5.8 | Serious |
| **Buttons** | `button-label-contains-role`, `icon-button-missing-label`, `visually-disabled-not-semantic` | 4.1.2 | Moderate, Critical, Serious |
| **Label in Name** | `label-in-name` | 2.5.3 | Serious |
| **Traits** | `tap-gesture-missing-button-trait` | 4.1.2 | Critical |
| **Toggles** | `toggle-missing-label` | 4.1.2 | Critical |
| **Form controls** | `textfield-missing-label`, `slider-missing-label`, `stepper-missing-label`, `picker-missing-label`, `picker-style-missing-accessibility` | 4.1.2 | Critical |
| **Accessibility hidden** | `hidden-parent-with-controls` | 4.1.2 | Critical |
| **Animation** | `animation-missing-reduce-motion` | 2.3.1 | Serious |
| **Tab views** | `tabview-missing-label` | 4.1.2, 2.4.2 | Serious |
| **Input purpose** | `input-missing-purpose` | 1.3.5 | Moderate |
| **Gestures** | `gesture-missing-alternative` | 2.1.1, 2.5.1 | Serious |
| **Reading Order / Grouping** | `missing-accessibility-grouping`, `zstack-order-confusing`, `sort-priority-overused`, `button-group-missing-container-label` | 1.3.1, 1.3.2 | Minor, Minor, Moderate, Moderate |
| **Timing** | `auto-dismiss-no-control` | 2.2.1 | Moderate |
| **Orientation** | `orientation-lock` | 1.3.4 | Serious |
| **Hints** | `missing-accessibility-hint`, `hint-describes-action-method` | 3.3.2 | Moderate, Minor |

The **input-missing-purpose** rule only flags TextFields when it can infer a specific `UITextContentType` from the field's label, placeholder, or binding name — for example, a field labeled "Email" gets flagged with a suggestion to add `.textContentType(.emailAddress)`. TextFields for generic input (task names, folder names, notes, search queries, etc.) are silently skipped because there is no standard content type for them and flagging them would be a false positive. SecureFields are always flagged since they almost always need `.textContentType(.password)` or `.textContentType(.newPassword)`.

The **textfield-missing-label** rule catches two problems:
- **Error:** TextField/SecureField with an empty `""` label and no `.accessibilityLabel()` — VoiceOver users won't know what to enter.
- **Warning:** TextField/SecureField using placeholder text as its label (e.g. `TextField("First Name", text: $name)` without a `prompt:` parameter or `.accessibilityLabel()`). Placeholder text disappears when the user starts typing and renders in low-contrast gray, failing both WCAG 3.3.2 (Labels or Instructions) and 1.4.3 (Contrast). Use a visible `Text` label above the field, or use the `prompt:` parameter to separate the placeholder from the label.

The **color contrast** rule computes actual WCAG 2.x contrast ratios when both foreground and background colors can be resolved — including SwiftUI system colors (`.black`, `.white`, `.red`, etc.), `Color(red:green:blue:)` literals, hex patterns, and named colors from your `.xcassets` catalogs.

- **Dark mode & Increase Contrast variants:** when a `.xcassets` color set defines `dark` or `high-contrast` appearance entries, the rule checks the contrast ratio for each theme that is present. A diagnostic names the failing theme (e.g. _"…in Dark Mode…"_). Light-mode-only catalogs are unaffected.
- **Container backgrounds:** if a text view (e.g. `Text`) has no `.background` on its own modifier chain, the rule walks up to the nearest enclosing container (VStack, HStack, ZStack, ScrollView, List, etc.) and pairs against its `.background`. Sibling views' backgrounds are never paired.
- **Numeric large text:** `.font(.system(size: N))` is treated as large text (3.0:1 threshold) when `N ≥ 18`, or when `N ≥ 14` combined with a bold/semibold/heavy/black weight. Named styles (`.largeTitle`, `.title`, `.title2`, `.title3`) continue to be detected as before.
- **Runtime complement:** static analysis cannot reach dynamic or runtime-resolved colors. For full coverage, pair `a11y-check` with Xcode's [`performAccessibilityAudit(for: .contrast)`](https://developer.apple.com/documentation/xctest/xcuiapplication/4191487-performaccessibilityaudit) in your UI tests.

The **image-missing-label** and **missing-accessibility-grouping** rules automatically skip views inside `label:` closures (e.g., `Menu { } label: { HStack { Text("Sort") Image(systemName: "chevron.down") } }`). SwiftUI treats the entire `label:` closure content as a single accessibility element, so individual images don't need their own labels and HStacks don't need manual grouping.

The **orientation-lock** rule flags code that restricts the app to a single orientation (portrait-only or landscape-only). Users with mounted devices (e.g. wheelchair mounts) may not be able to rotate their device. The rule checks `supportedInterfaceOrientations` overrides and `requestGeometryUpdate` calls. It does not flag code that returns `.all` or `.allButUpsideDown`.

The **missing-accessibility-hint** rule flags interactive elements with complex gestures (`onLongPressGesture`, `onDrag`, `onDrop`, `contextMenu`, `swipeActions`, `DragGesture`, `LongPressGesture`) that lack an `.accessibilityHint()`. Hints tell VoiceOver users what will happen when they activate the element. Standard tap actions and buttons don't need hints since their behavior is obvious from the label.

The **hint-describes-action-method** rule flags `.accessibilityHint()` values that describe how to interact instead of what happens. VoiceOver already announces the gesture (e.g. "double tap to activate"), so hints like "Double tap to add to cart" are redundant. Rewrite hints in third-person declarative form:
- Bad: "Double tap to purchase", "Tap to delete", "Swipe left to remove"
- Good: "Purchases this item", "Deletes the message", "Removes from list"

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

