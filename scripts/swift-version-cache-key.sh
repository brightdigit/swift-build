#!/bin/bash
# Computes the Swift version component used in SPM cache keys from 'swift --version' output
# Usage: swift --version | scripts/swift-version-cache-key.sh
# Output: the third field of the version line (e.g. '6.2.3'), unchanged for release
#         toolchains. For development snapshots (e.g. '6.4-dev'), the exact Swift
#         compiler commit from the parenthetical is appended (e.g.
#         '6.4-dev-348f9c2e6608448') so each nightly snapshot gets its own cache
#         namespace instead of sharing one stale '6.4-dev' key across snapshots.
# Exit codes: 0 = success (always; falls back to the plain version when no commit is found)

set -euo pipefail

FIRST_LINE=$(head -n 1)
SWIFT_VERSION=$(echo "$FIRST_LINE" | cut -d ' ' -f 3)

case "$SWIFT_VERSION" in
  *-dev)
    # Nightly toolchains all report the same X.Y-dev version; only the parenthetical
    # identifies the snapshot, e.g. "Swift version 6.4-dev (LLVM d1ef843cdc2991c, Swift 348f9c2e6608448)"
    SWIFT_COMMIT=$(echo "$FIRST_LINE" | sed -nE 's/.*Swift ([0-9a-f]{7,40})\).*/\1/p')
    if [ -n "$SWIFT_COMMIT" ]; then
      SWIFT_VERSION="${SWIFT_VERSION}-${SWIFT_COMMIT}"
    fi
    ;;
esac

echo "$SWIFT_VERSION"
