#!/bin/bash
# Parses Swift version from 'swift --version' output
# Usage: swift --version | scripts/parse-swift-version.sh
# Output: X.Y.Z version string to stdout
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

echo "ERROR: Could not parse Swift version from: $SWIFT_VERSION_RAW" >&2
exit 1
