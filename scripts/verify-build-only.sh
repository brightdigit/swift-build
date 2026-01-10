#!/bin/bash
# Verifies that tests were not run in build-only mode
# Usage: scripts/verify-build-only.sh <platform> [working-directory]
# Platform: spm, xcode, windows, android, wasm
# Exit codes: 0 = verified, 1 = tests found

set -euo pipefail

PLATFORM="${1:-spm}"
WORKING_DIR="${2:-.}"

# Validate working directory exists and is a directory
if [[ ! -d "$WORKING_DIR" ]]; then
  echo "ERROR: Working directory does not exist or is not a directory: $WORKING_DIR" >&2
  exit 1
fi

echo "Verifying build-only mode for platform: $PLATFORM"
cd "$WORKING_DIR"

case "$PLATFORM" in
  spm)
    # Check for test executables in .build directory
    if [ -d ".build" ]; then
      if find .build -type f \( -name "*Tests" -o -name "*PackageTests" \) 2>/dev/null | grep -q .; then
        echo "ERROR: Test binaries found in .build directory"
        find .build -type f \( -name "*Tests" -o -name "*PackageTests" \) 2>/dev/null
        exit 1
      fi
    fi
    echo "✓ Verified: No SPM test binaries"
    ;;

  xcode)
    # Check for .xctest bundles in derived data
    if [ -n "${RUNNER_TEMP:-}" ]; then
      if find "$RUNNER_TEMP/DerivedData" -name "*.xctest" 2>/dev/null | grep -q .; then
        echo "ERROR: .xctest bundles found in derived data"
        find "$RUNNER_TEMP/DerivedData" -name "*.xctest" 2>/dev/null
        exit 1
      fi
    fi
    echo "✓ Verified: No .xctest bundles"
    ;;

  windows)
    # Check for .exe test executables
    if [ -d ".build" ]; then
      if find .build -type f \( -name "*Tests.exe" -o -name "*PackageTests.exe" -o -name "*Tests" -o -name "*PackageTests" \) 2>/dev/null | grep -q .; then
        echo "ERROR: Test binaries found"
        exit 1
      fi
    fi
    echo "✓ Verified: No Windows test binaries"
    ;;

  android)
    echo "✓ Build-only verified (delegated to swift-android-action)"
    ;;

  wasm)
    # Check for .wasm test binaries
    if [ -d ".build" ]; then
      if find .build -type f \( -name "*Tests.wasm" -o -name "*PackageTests.wasm" \) 2>/dev/null | grep -q .; then
        echo "ERROR: WASM test binaries found"
        exit 1
      fi
    fi
    echo "✓ Verified: No WASM test binaries"
    ;;

  *)
    echo "ERROR: Unknown platform: $PLATFORM" >&2
    exit 1
    ;;
esac

echo "✓ Build-only mode verification passed"
