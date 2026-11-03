#!/bin/bash
# Emit a11y-check findings in Xcode's diagnostic format, so they land in the Issue Navigator.
#
# Point this at any checkout. It reads source as text and compiles nothing, so it does not need
# the app to build — which is the whole point: a full audit of a large app takes minutes here
# versus however long that app takes to compile.
#
# Configure in the scheme (Product > Scheme > Edit Scheme > Run > Arguments > Environment
# Variables), or export before launching Xcode:
#
#   A11Y_REPO    checkout to scan          (default: the directory above this project)
#   A11Y_SCOPE   subpath within it         (default: the whole checkout)
#   A11Y_BIN     a11y-check binary         (default: ./a11y-check, else PATH, else Homebrew)
#   A11Y_CONFIG  .a11ycheck.yml to use     (default: auto-detected from the repo)
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="${A11Y_REPO:-$(cd "$HERE/.." && pwd)}"
SCOPE="${A11Y_SCOPE:-.}"
TARGET="$REPO/$SCOPE"

# Prefer a binary pinned next to this project, so results do not shift mid-audit.
if   [ -n "${A11Y_BIN:-}" ];            then BIN="$A11Y_BIN"
elif [ -x "$HERE/a11y-check" ];         then BIN="$HERE/a11y-check"
elif command -v a11y-check >/dev/null;  then BIN="$(command -v a11y-check)"
elif [ -x /opt/homebrew/bin/a11y-check ]; then BIN=/opt/homebrew/bin/a11y-check
else echo "error: a11y-check not found — set A11Y_BIN or copy the binary next to this project"; exit 1
fi

[ -e "$TARGET" ] || { echo "error: scope not found: $TARGET"; exit 1; }

CFG_ARGS=()
[ -n "${A11Y_CONFIG:-}" ] && CFG_ARGS=(--config "$A11Y_CONFIG")

# Print the version with the results. A stale binary reports fewer findings and still looks
# like it worked, which is close to undetectable once the numbers are written down somewhere.
echo "note: a11y-check $("$BIN" --version) scanning $SCOPE in $REPO"

# One path per invocation: the tool returns no diagnostics when handed several at once.
#
# No --base-path. It makes paths relative, which is right for SARIF and GitHub annotations and
# wrong here — Xcode resolves diagnostics by absolute path, and this project normally sits
# outside the checkout, so relative paths attach to nothing and the Issue Navigator stays empty.
#
# Severity passes through as a11y-check reports it: error for critical/serious, warning for
# minor, note for info. That red/yellow split in the Issue Navigator is the main triage tool once
# there are a few thousand findings, so it is kept at one cosmetic cost — Xcode adds "Command
# PhaseScriptExecution emitted errors but did not return a nonzero exit code" at the top of the
# target whenever a script phase prints error: and exits 0. That line is expected; the
# alternatives are losing the colours or failing the build, and neither suits an advisory audit.
#
# A11Y_SEVERITY=warnings downgrades everything for a clean badge. The ranking survives either
# way, since every message carries [critical] / [serious] / [moderate] / [minor].
if [ "${A11Y_SEVERITY:-errors}" = "warnings" ]; then
    "$BIN" "$TARGET" "${CFG_ARGS[@]}" --format xcode --no-trend 2>/dev/null \
        | sed -E 's/^([^:]+:[0-9]+:[0-9]+:) error:/\1 warning:/' || true
else
    "$BIN" "$TARGET" "${CFG_ARGS[@]}" --format xcode --no-trend 2>/dev/null || true
fi

exit 0
