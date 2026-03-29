#!/bin/bash
# Parses Swift version from 'swift --version' output
# Usage: swift --version | scripts/parse-swift-version.sh
# Output: X.Y.Z or X.Y version string to stdout (patch omitted when not present in swift --version)
# Exit codes: 0 = success, 1 = parse error

set -euo pipefail

SWIFT_VERSION_RAW=$(cat)
echo "Raw version output: $SWIFT_VERSION_RAW" >&2

# Pattern 1: Swift version X.Y.Z
if echo "$SWIFT_VERSION_RAW" | grep -qE 'Swift version [0-9]+\.[0-9]+\.[0-9]+'; then
  echo "$SWIFT_VERSION_RAW" | sed -E 's/.*Swift version ([0-9]+\.[0-9]+\.[0-9]+).*/\1/'
  exit 0
fi

# Pattern 2: Apple Swift version X.Y (swiftlang-X.Y.Z)
if echo "$SWIFT_VERSION_RAW" | grep -qE 'Apple Swift version [0-9]+\.[0-9]+' && \
   echo "$SWIFT_VERSION_RAW" | grep -qE '\(swiftlang-[0-9]+\.[0-9]+\.[0-9]+'; then
  echo "$SWIFT_VERSION_RAW" | sed -E 's/.*\(swiftlang-([0-9]+\.[0-9]+\.[0-9]+).*/\1/'
  exit 0
fi

# Pattern 3: (swift-X.Y.Z)
if echo "$SWIFT_VERSION_RAW" | grep -qE '\(swift-[0-9]+\.[0-9]+\.[0-9]+'; then
  echo "$SWIFT_VERSION_RAW" | sed -E 's/.*\(swift-([0-9]+\.[0-9]+\.[0-9]+).*/\1/'
  exit 0
fi

# Pattern 4: Swift version X.Y (no patch component, e.g. "Swift version 6.3 (swift-6.3-RELEASE)")
# Returns X.Y as-is — Swift.org Wasm SDK artifacts use the same X.Y naming (e.g. swift-6.3-RELEASE_wasm)
if echo "$SWIFT_VERSION_RAW" | grep -qE 'Swift version [0-9]+\.[0-9]+[^.]'; then
  echo "$SWIFT_VERSION_RAW" | sed -E 's/.*Swift version ([0-9]+\.[0-9]+)[^.].*/\1/'
  exit 0
fi

# Pattern 5: (swift-X.Y-RELEASE) — no patch component
if echo "$SWIFT_VERSION_RAW" | grep -qE '\(swift-[0-9]+\.[0-9]+-'; then
  echo "$SWIFT_VERSION_RAW" | sed -E 's/.*\(swift-([0-9]+\.[0-9]+)-.*/\1/'
  exit 0
fi

echo "ERROR: Could not parse Swift version from: $SWIFT_VERSION_RAW" >&2
exit 1
