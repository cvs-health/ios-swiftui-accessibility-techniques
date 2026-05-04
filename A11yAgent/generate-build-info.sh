#!/bin/sh
# Generates BuildInfo.swift with the current git commit and date.
# Run before `swift build` to embed version info.
COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "dev")
DATE=$(date +%Y-%m-%d)
cat > Sources/A11yAgentCLI/BuildInfo.swift <<EOF
let buildCommit = "$COMMIT"
let buildDate = "$DATE"
EOF
