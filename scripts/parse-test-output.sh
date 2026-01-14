#!/bin/bash
# parse-test-output.sh - Parse Swift test output and extract test statistics
#
# Usage: parse-test-output.sh <platform> <output-file> [expected-count]
#
# Platforms:
#   spm         - Swift Package Manager (auto-detects Swift Testing vs XCTest)
#   xcode       - Xcode builds (handles raw xcodebuild and xcbeautify)
#   wasm        - WebAssembly single framework
#   wasm-both   - WebAssembly "both" mode (sums Swift Testing + XCTest)
#
# Exit codes:
#   0 - Success (parsing succeeded, optional validation passed)
#   1 - Parsing failed (unrecognized format, missing file, etc.)
#   2 - Validation failed (test count doesn't match expected)

set -euo pipefail

# Parse arguments
PLATFORM="${1:-}"
OUTPUT_FILE="${2:-}"
EXPECTED_COUNT="${3:-}"

# Validate arguments
if [[ -z "$PLATFORM" ]]; then
  echo "ERROR: Platform argument required" >&2
  echo "Usage: $0 <platform> <output-file> [expected-count]" >&2
  exit 1
fi

if [[ -z "$OUTPUT_FILE" ]]; then
  echo "ERROR: Output file argument required" >&2
  echo "Usage: $0 <platform> <output-file> [expected-count]" >&2
  exit 1
fi

if [[ ! -f "$OUTPUT_FILE" ]]; then
  echo "ERROR: Output file not found: $OUTPUT_FILE" >&2
  exit 1
fi

# Read output file
OUTPUT=$(cat "$OUTPUT_FILE")

# Initialize result variables
TOTAL=0
PASSED=0
FAILED=0
SKIPPED=0

# Parse Swift Testing output
# Pattern: "Test run with 9 tests in 2 suites passed after 0.001 seconds."
# Also handles: "Test run with 9 tests passed after 0.001 seconds." (no suites)
parse_swift_testing() {
  # Extract total test count
  TOTAL=$(echo "$OUTPUT" | grep -oE "Test run with [0-9]+ test" | grep -oE "[0-9]+" | head -1 || echo "")

  if [[ -z "$TOTAL" ]]; then
    echo "ERROR: Cannot parse Swift Testing output - no 'Test run with X tests' pattern found" >&2
    echo "Output excerpt:" >&2
    echo "$OUTPUT" | head -20 >&2
    echo "..." >&2
    echo "$OUTPUT" | tail -20 >&2
    return 1
  fi

  # Extract failed count (default 0 if not present)
  FAILED=$(echo "$OUTPUT" | grep -oE "[0-9]+ failed" | grep -oE "[0-9]+" || echo "0")

  # Extract skipped count (default 0 if not present)
  SKIPPED=$(echo "$OUTPUT" | grep -oE "[0-9]+ skipped" | grep -oE "[0-9]+" || echo "0")

  # Calculate passed
  PASSED=$((TOTAL - FAILED - SKIPPED))

  return 0
}

# Parse XCTest output (SwiftPM format)
# Pattern: "Executed 8 tests, with 0 failures (0 unexpected) in 0.003 (0.005) seconds"
parse_xctest_spm() {
  # Extract total test count from LAST occurrence (All tests summary)
  TOTAL=$(echo "$OUTPUT" | grep -oE "Executed [0-9]+ test" | grep -oE "[0-9]+" | tail -1 || echo "")

  if [[ -z "$TOTAL" ]]; then
    echo "ERROR: Cannot parse XCTest output - no 'Executed X tests' pattern found" >&2
    echo "Output excerpt:" >&2
    echo "$OUTPUT" | head -20 >&2
    echo "..." >&2
    echo "$OUTPUT" | tail -20 >&2
    return 1
  fi

  # Extract failed count from LAST occurrence
  FAILED=$(echo "$OUTPUT" | grep -oE "with [0-9]+ failure" | grep -oE "[0-9]+" | tail -1 || echo "0")

  # XCTest doesn't report skipped in summary
  SKIPPED="0"

  # Calculate passed
  PASSED=$((TOTAL - FAILED))

  return 0
}

# Parse Xcode output
# Handles both raw xcodebuild and xcbeautify formats
parse_xcodebuild() {
  # Try xcbeautify format first: "✓ All tests passed (17 tests)"
  if echo "$OUTPUT" | grep -q "All tests passed"; then
    TOTAL=$(echo "$OUTPUT" | grep -oE "All tests passed \([0-9]+ test" | grep -oE "[0-9]+" || echo "")

    if [[ -n "$TOTAL" ]]; then
      FAILED="0"
      PASSED="$TOTAL"
      SKIPPED="0"
      return 0
    fi
  fi

  # Fallback to raw xcodebuild format (same as XCTest SPM)
  # Pattern: "Executed 17 tests, with 0 failures (0 unexpected) in 0.123 (0.456) seconds"
  parse_xctest_spm
  return $?
}

# Parse Wasm "both" mode output (or mixed SPM output)
# Combines Swift Testing and XCTest results
parse_wasm_both() {
  # Parse Swift Testing section (should be one "Test run" line)
  ST_TOTAL=$(echo "$OUTPUT" | grep -oE "Test run with [0-9]+ test" | grep -oE "[0-9]+" | tail -1 || echo "0")

  if [[ "$ST_TOTAL" -eq 0 ]]; then
    echo "ERROR: Cannot parse Swift Testing section in mixed output" >&2
    echo "Output excerpt:" >&2
    echo "$OUTPUT" | head -30 >&2
    return 1
  fi

  ST_FAILED=$(echo "$OUTPUT" | grep -oE "[0-9]+ failed" | grep -oE "[0-9]+" | tail -1 || echo "0")
  ST_SKIPPED=$(echo "$OUTPUT" | grep -oE "[0-9]+ skipped" | grep -oE "[0-9]+" | tail -1 || echo "0")
  ST_PASSED=$((ST_TOTAL - ST_FAILED - ST_SKIPPED))

  # Parse XCTest section (use LAST "Executed" line for total)
  XC_TOTAL=$(echo "$OUTPUT" | grep -oE "Executed [0-9]+ test" | grep -oE "[0-9]+" | tail -1 || echo "0")

  if [[ "$XC_TOTAL" -eq 0 ]]; then
    echo "ERROR: Cannot parse XCTest section in mixed output" >&2
    echo "Output excerpt:" >&2
    echo "$OUTPUT" | tail -30 >&2
    return 1
  fi

  XC_FAILED=$(echo "$OUTPUT" | grep -oE "with [0-9]+ failure" | grep -oE "[0-9]+" | tail -1 || echo "0")
  XC_PASSED=$((XC_TOTAL - XC_FAILED))

  # Sum results
  TOTAL=$((ST_TOTAL + XC_TOTAL))
  PASSED=$((ST_PASSED + XC_PASSED))
  FAILED=$((ST_FAILED + XC_FAILED))
  SKIPPED=$((ST_SKIPPED))  # XCTest doesn't report skipped

  return 0
}

# Platform-specific parsing
case "$PLATFORM" in
  spm)
    # Check if both frameworks are present (mixed framework package)
    HAS_SWIFT_TESTING=$(echo "$OUTPUT" | grep -c "Test run with" || echo "0")
    HAS_XCTEST=$(echo "$OUTPUT" | grep -c "Executed.*tests" || echo "0")

    if [[ "$HAS_SWIFT_TESTING" -gt 0 ]] && [[ "$HAS_XCTEST" -gt 0 ]]; then
      # Both frameworks present - sum results like wasm-both mode
      parse_wasm_both || exit 1
    elif [[ "$HAS_SWIFT_TESTING" -gt 0 ]]; then
      # Only Swift Testing
      parse_swift_testing || exit 1
    elif [[ "$HAS_XCTEST" -gt 0 ]]; then
      # Only XCTest
      parse_xctest_spm || exit 1
    else
      echo "ERROR: Cannot detect test framework from SPM output" >&2
      echo "Output excerpt:" >&2
      echo "$OUTPUT" | head -20 >&2
      echo "..." >&2
      echo "$OUTPUT" | tail -20 >&2
      exit 1
    fi
    ;;

  xcode)
    parse_xcodebuild || exit 1
    ;;

  wasm)
    # Same as SPM (auto-detect framework)
    if echo "$OUTPUT" | grep -q "Test run with"; then
      parse_swift_testing || exit 1
    elif echo "$OUTPUT" | grep -q "Executed.*tests"; then
      parse_xctest_spm || exit 1
    else
      echo "ERROR: Cannot detect test framework from Wasm output" >&2
      echo "Output excerpt:" >&2
      echo "$OUTPUT" | head -20 >&2
      echo "..." >&2
      echo "$OUTPUT" | tail -20 >&2
      exit 1
    fi
    ;;

  wasm-both)
    parse_wasm_both || exit 1
    ;;

  *)
    echo "ERROR: Unknown platform: $PLATFORM" >&2
    echo "Supported platforms: spm, xcode, wasm, wasm-both" >&2
    exit 1
    ;;
esac

# Output results (GitHub Actions format)
echo "total=$TOTAL"
echo "passed=$PASSED"
echo "failed=$FAILED"
echo "skipped=$SKIPPED"

# Validate count if specified
if [[ -n "$EXPECTED_COUNT" ]]; then
  if [[ "$TOTAL" != "$EXPECTED_COUNT" ]]; then
    echo "ERROR: Test count mismatch. Expected: $EXPECTED_COUNT, Actual: $TOTAL" >&2
    exit 2
  fi
  echo "✓ Test count validation passed: $TOTAL tests" >&2
fi

exit 0
