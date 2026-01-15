#!/usr/bin/env bash
# validate-test-output.sh
# Validates test counts from test output (stdin only)
#
# Usage:
#   cat test-output.txt | ./validate-test-output.sh <mode>
#   command | ./validate-test-output.sh <mode>
#
# Modes:
#   combined           - Validate combined XCTest + Swift Testing output
#   xctest-only        - Validate XCTest-only output (Wasm)
#   swift-testing-only - Validate Swift Testing-only output (Wasm)
#
# Exit Codes:
#   0 - Success (counts match expected values)
#   1 - Validation failure (counts don't match)
#   2 - Usage error
#
# Examples:
#   # Combined output (SPM, Xcode, Ubuntu, Windows, Android)
#   cat test-output.txt | ./validate-test-output.sh combined
#
#   # Wasm XCTest only
#   cat wasm-xctest-output.txt | ./validate-test-output.sh xctest-only
#
#   # Wasm Swift Testing only
#   cat wasm-swift-testing-output.txt | ./validate-test-output.sh swift-testing-only

set -euo pipefail

# Constants - Expected test counts for MixedFrameworkPackage
readonly EXPECTED_XCTEST=8
readonly EXPECTED_SWIFT_TESTING=9
readonly EXPECTED_TOTAL=17

# Color codes for output (if terminal supports it)
if [[ -t 1 ]]; then
  readonly RED='\033[0;31m'
  readonly GREEN='\033[0;32m'
  readonly YELLOW='\033[1;33m'
  readonly NC='\033[0m' # No Color
else
  readonly RED=''
  readonly GREEN=''
  readonly YELLOW=''
  readonly NC=''
fi

# Parse XCTest count from input
# Pattern: "Executed N tests, with M failures"
# Arguments:
#   $1 - Input text
# Returns:
#   Test count (or 0 if not found)
parse_xctest_count() {
  local input="$1"
  local count
  local all_tests_count

  # Check if this looks like xcodebuild output (has multiple "Test Suite 'All tests'")
  all_tests_count=$(echo "$input" | grep -c "Test Suite 'All tests'" 2>/dev/null || echo "0")
  # Ensure we have a single number
  all_tests_count=$(echo "$all_tests_count" | head -1)

  if [[ ${all_tests_count:-0} -gt 2 ]]; then
    # Xcodebuild output - sum all "All tests" bundle totals
    count=$(echo "$input" | grep -A1 "Test Suite 'All tests' passed" 2>/dev/null | \
      grep -o 'Executed [0-9]\+ tests' | \
      grep -o '[0-9]\+' | \
      awk '{sum+=$1} END {print sum+0}')
  else
    # Simple output - take last non-zero count
    count=$(echo "$input" | grep -o 'Executed [0-9]\+ tests' 2>/dev/null | \
      grep -o '[0-9]\+' | \
      grep -v '^0$' | \
      tail -1)
  fi

  # Return 0 if empty
  echo "${count:-0}"
}

# Parse Swift Testing count from input
# Pattern: "Test run with N tests in M suites"
# Handles both Unicode variants: 􁁛 (native) and ✔ (WASM)
# Arguments:
#   $1 - Input text
# Returns:
#   Test count (or 0 if not found)
parse_swift_testing_count() {
  local input="$1"

  # Extract all "Test run with N tests" occurrences and sum them
  echo "$input" | grep -o 'Test run with [0-9]\+ tests' 2>/dev/null | \
    grep -o '[0-9]\+' | \
    awk '{sum+=$1} END {print sum+0}'
}

# Validate combined output (XCTest + Swift Testing)
# Expected: 8 XCTest + 9 Swift Testing = 17 total
# Arguments:
#   $1 - Input text
# Returns:
#   0 if validation passes, 1 if validation fails
validate_combined() {
  local input="$1"
  local xctest_count swift_testing_count total
  local validation_passed=0

  xctest_count=$(parse_xctest_count "$input")
  swift_testing_count=$(parse_swift_testing_count "$input")
  total=$((xctest_count + swift_testing_count))

  # Validate XCTest count
  if [[ $xctest_count -eq $EXPECTED_XCTEST ]]; then
    echo -e "${GREEN}✓${NC} XCTest: $xctest_count (expected: $EXPECTED_XCTEST)" >&2
  else
    echo -e "${RED}✗${NC} XCTest: $xctest_count (expected: $EXPECTED_XCTEST)" >&2
    validation_passed=1
  fi

  # Validate Swift Testing count
  if [[ $swift_testing_count -eq $EXPECTED_SWIFT_TESTING ]]; then
    echo -e "${GREEN}✓${NC} Swift Testing: $swift_testing_count (expected: $EXPECTED_SWIFT_TESTING)" >&2
  else
    echo -e "${RED}✗${NC} Swift Testing: $swift_testing_count (expected: $EXPECTED_SWIFT_TESTING)" >&2
    validation_passed=1
  fi

  # Validate total
  if [[ $total -eq $EXPECTED_TOTAL ]]; then
    echo -e "${GREEN}✓${NC} Total: $total (expected: $EXPECTED_TOTAL)" >&2
  else
    echo -e "${RED}✗${NC} Total: $total (expected: $EXPECTED_TOTAL)" >&2
    validation_passed=1
  fi

  return $validation_passed
}

# Validate XCTest-only output
# Expected: 8 XCTest
# Arguments:
#   $1 - Input text
# Returns:
#   0 if validation passes, 1 if validation fails
validate_xctest_only() {
  local input="$1"
  local xctest_count
  local validation_passed=0

  xctest_count=$(parse_xctest_count "$input")

  if [[ $xctest_count -eq $EXPECTED_XCTEST ]]; then
    echo -e "${GREEN}✓${NC} XCTest: $xctest_count (expected: $EXPECTED_XCTEST)" >&2
  else
    echo -e "${RED}✗${NC} XCTest: $xctest_count (expected: $EXPECTED_XCTEST)" >&2
    validation_passed=1
  fi

  return $validation_passed
}

# Validate Swift Testing-only output
# Expected: 9 Swift Testing
# Arguments:
#   $1 - Input text
# Returns:
#   0 if validation passes, 1 if validation fails
validate_swift_testing_only() {
  local input="$1"
  local swift_testing_count
  local validation_passed=0

  swift_testing_count=$(parse_swift_testing_count "$input")

  if [[ $swift_testing_count -eq $EXPECTED_SWIFT_TESTING ]]; then
    echo -e "${GREEN}✓${NC} Swift Testing: $swift_testing_count (expected: $EXPECTED_SWIFT_TESTING)" >&2
  else
    echo -e "${RED}✗${NC} Swift Testing: $swift_testing_count (expected: $EXPECTED_SWIFT_TESTING)" >&2
    validation_passed=1
  fi

  return $validation_passed
}

# Main entry point
main() {
  local mode="${1:-}"

  # Check for valid mode
  if [[ -z "$mode" ]]; then
    echo -e "${RED}Error: Mode argument required${NC}" >&2
    echo "" >&2
    echo "Usage: $0 <mode>" >&2
    echo "  Reads test output from stdin" >&2
    echo "" >&2
    echo "Modes:" >&2
    echo "  combined           - Validate combined XCTest + Swift Testing output" >&2
    echo "  xctest-only        - Validate XCTest-only output (Wasm)" >&2
    echo "  swift-testing-only - Validate Swift Testing-only output (Wasm)" >&2
    exit 2
  fi

  # Read all input from stdin
  local input
  input=$(cat)

  if [[ -z "$input" ]]; then
    echo -e "${RED}Error: No input received from stdin${NC}" >&2
    exit 2
  fi

  # Validate based on mode
  case "$mode" in
    combined)
      echo "Validating combined output (XCTest + Swift Testing)..." >&2
      if validate_combined "$input"; then
        echo -e "${GREEN}✅ Validation passed!${NC}" >&2
        exit 0
      else
        echo "" >&2
        echo -e "${RED}❌ Validation failed!${NC}" >&2
        echo "" >&2
        echo "Check for:" >&2
        echo "  - Test compilation failures" >&2
        echo "  - Platform-specific test skipping" >&2
        echo "  - Test filtering flags" >&2
        exit 1
      fi
      ;;

    xctest-only)
      echo "Validating XCTest-only output..." >&2
      if validate_xctest_only "$input"; then
        echo -e "${GREEN}✅ Validation passed!${NC}" >&2
        exit 0
      else
        echo "" >&2
        echo -e "${RED}❌ Validation failed!${NC}" >&2
        exit 1
      fi
      ;;

    swift-testing-only)
      echo "Validating Swift Testing-only output..." >&2
      if validate_swift_testing_only "$input"; then
        echo -e "${GREEN}✅ Validation passed!${NC}" >&2
        exit 0
      else
        echo "" >&2
        echo -e "${RED}❌ Validation failed!${NC}" >&2
        exit 1
      fi
      ;;

    *)
      echo -e "${RED}Error: Invalid mode: $mode${NC}" >&2
      echo "Valid modes: combined, xctest-only, swift-testing-only" >&2
      exit 2
      ;;
  esac
}

# Execute main function with all script arguments
main "$@"
