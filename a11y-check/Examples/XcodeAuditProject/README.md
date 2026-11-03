# Standalone audit project

An Xcode project whose only job is to put `a11y-check` findings in the **Issue Navigator** of an
existing codebase, so they can be reviewed and triaged for false positives.

It compiles nothing. The target is an aggregate target running one script, so a full audit of a
large app takes as long as the scan — not as long as the app takes to build.

## Why not just add a build phase to the app target?

Both documented integrations (the SPM build plugin, and a Run Script phase) attach to a real
target, which means **building the app** to see findings. On a large app that is minutes per
look, and it needs an edit to `project.pbxproj` — awkward to justify for a one-off review, and
awkward to revert.

This project is the alternative for the review case. Use a build phase once you have decided
what to enforce.

## Use

1. Copy this folder anywhere — it does not need to live inside the repo you are scanning.
2. Put the `a11y-check` binary in `bin/`, or let the script find one on `PATH`/Homebrew.
3. Open `a11y-check.xcodeproj` and press **⌘B**. Findings appear in the Issue Navigator (**⌘5**)
   and are clickable through to the real source files.

Configure in the scheme — **Product > Scheme > Edit Scheme > Run > Arguments > Environment
Variables** — or export before launching Xcode:

| Variable | Default | |
|---|---|---|
| `A11Y_REPO` | the directory above this project | checkout to scan |
| `A11Y_SCOPE` | the whole checkout | subpath, e.g. `Packages/Shop`, for a fast re-check |
| `A11Y_BIN` | `bin/a11y-check`, else `PATH`, else Homebrew | which binary |
| `A11Y_CONFIG` | auto-detected from the repo | explicit `.a11ycheck.yml` |

Pin the binary in `bin/` for a real audit. Results that shift halfway through because the tool
was upgraded are worse than no results.

## Three things that are easy to get wrong

Each of these produces a silent wrong answer rather than an error, so they are worth knowing
before you debug an empty Issue Navigator.

**Do not pass `--base-path`.** It makes paths relative, which is what SARIF and GitHub
annotations want. Xcode resolves diagnostics by **absolute** path, and this project normally sits
outside the checkout — so relative paths attach to nothing and the navigator stays empty while
the build succeeds.

**Rewrite `error:` to `warning:`.** Xcode raises *"Command PhaseScriptExecution emitted errors
but did not return a nonzero exit code"* whenever a script phase prints `error:` and exits 0,
which puts a spurious issue at the top of the audit. Nothing is lost by downgrading: every
message already carries its own severity as `[critical]` / `[serious]` / `[moderate]` /
`[minor]`.

**Print `--version` with the results.** A stale binary reports fewer findings and still looks
like it worked. One real project vendored a months-old build for weeks without noticing, and an
audit run against it would have mis-measured several rules — one reported 133 findings where the
current version reports 1.

## Teach it your design system first

If the app wraps SwiftUI's views, set `view_aliases` and `font_modifiers` in `.a11ycheck.yml`
before auditing, or most rules will see straight past your UI. In one app the heading rule found
82 findings before configuration and 835 after, because the font arrived as
`MyText(_, font: .headingXL)` and the rule only read `.font()`.

Auditing before that step measures the configuration, not the code.
