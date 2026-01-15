#!/usr/bin/env bash
# validate-test-output.sh
# Validates test counts from test output (stdin only)
#
# Usage:
#   cat test-output.txt | ./validate-test-output.sh <mode> <xctest-count> <swift-testing-count>
#   command | ./validate-test-output.sh <mode> <xctest-count> <swift-testing-count>
#
# Arguments:
#   mode                - Validation mode (combined|xctest-only|swift-testing-only)
#   xctest-count        - Expected XCTest count (required)
#   swift-testing-count - Expected Swift Testing count (required for combined mode)
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
#   # Combined output (8 XCTest + 9 Swift Testing)
#   cat test-output.txt | ./validate-test-output.sh combined 8 9
#
#   # Wasm XCTest only (8 tests)
#   cat wasm-xctest-output.txt | ./validate-test-output.sh xctest-only 8
#
#   # Wasm Swift Testing only (9 tests)
#   cat wasm-swift-testing-output.txt | ./validate-test-output.sh swift-testing-only 9

set -euo pipefail

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

  # Detect xcodebuild format by checking for platform-specific markers
  # Xcodebuild includes lines like: "Test Suite 'All tests' started at ..."
  # AND "Test Suite 'Selected tests' ..."
  # This is more robust than counting occurrences with arbitrary thresholds
  if echo "$input" | grep -q "Test Suite 'Selected tests'" && \
     echo "$input" | grep -q "Test Suite 'All tests'"; then
    # Xcodebuild output detected - sum all "All tests" bundle totals
    echo "DEBUG: Detected xcodebuild format" >&2
    count=$(echo "$input" | grep -A1 "Test Suite 'All tests' passed" 2>/dev/null | \
      grep -o 'Executed [0-9]\+ tests' | \
      grep -o '[0-9]\+' | \
      awk '{sum+=$1} END {print sum+0}')
  else
    # SwiftPM/simple output - take last non-zero count
    echo "DEBUG: Detected SwiftPM format" >&2
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
# Arguments:
#   $1 - Input text
#   $2 - Expected XCTest count
#   $3 - Expected Swift Testing count
# Returns:
#   0 if validation passes, 1 if validation fails
validate_combined() {
  local input="$1"
  local expected_xctest="$2"
  local expected_swift_testing="$3"
  local expected_total=$((expected_xctest + expected_swift_testing))
  local xctest_count swift_testing_count total
  local validation_passed=0

  xctest_count=$(parse_xctest_count "$input")
  swift_testing_count=$(parse_swift_testing_count "$input")
  total=$((xctest_count + swift_testing_count))

  # Validate XCTest count
  if [[ $xctest_count -eq $expected_xctest ]]; then
    echo -e "${GREEN}✓${NC} XCTest: $xctest_count (expected: $expected_xctest)" >&2
  else
    echo -e "${RED}✗${NC} XCTest: $xctest_count (expected: $expected_xctest)" >&2
    validation_passed=1
  fi

  # Validate Swift Testing count
  if [[ $swift_testing_count -eq $expected_swift_testing ]]; then
    echo -e "${GREEN}✓${NC} Swift Testing: $swift_testing_count (expected: $expected_swift_testing)" >&2
  else
    echo -e "${RED}✗${NC} Swift Testing: $swift_testing_count (expected: $expected_swift_testing)" >&2
    validation_passed=1
  fi

  # Validate total
  if [[ $total -eq $expected_total ]]; then
    echo -e "${GREEN}✓${NC} Total: $total (expected: $expected_total)" >&2
  else
    echo -e "${RED}✗${NC} Total: $total (expected: $expected_total)" >&2
    validation_passed=1
  fi

  return $validation_passed
}

# Validate XCTest-only output
# Arguments:
#   $1 - Input text
#   $2 - Expected XCTest count
# Returns:
#   0 if validation passes, 1 if validation fails
validate_xctest_only() {
  local input="$1"
  local expected_xctest="$2"
  local xctest_count
  local validation_passed=0

  xctest_count=$(parse_xctest_count "$input")

  if [[ $xctest_count -eq $expected_xctest ]]; then
    echo -e "${GREEN}✓${NC} XCTest: $xctest_count (expected: $expected_xctest)" >&2
  else
    echo -e "${RED}✗${NC} XCTest: $xctest_count (expected: $expected_xctest)" >&2
    validation_passed=1
  fi

  return $validation_passed
}

# Validate Swift Testing-only output
# Arguments:
#   $1 - Input text
#   $2 - Expected Swift Testing count
# Returns:
#   0 if validation passes, 1 if validation fails
validate_swift_testing_only() {
  local input="$1"
  local expected_swift_testing="$2"
  local swift_testing_count
  local validation_passed=0

  swift_testing_count=$(parse_swift_testing_count "$input")

  if [[ $swift_testing_count -eq $expected_swift_testing ]]; then
    echo -e "${GREEN}✓${NC} Swift Testing: $swift_testing_count (expected: $expected_swift_testing)" >&2
  else
    echo -e "${RED}✗${NC} Swift Testing: $swift_testing_count (expected: $expected_swift_testing)" >&2
    validation_passed=1
  fi

  return $validation_passed
}

# Main entry point
main() {
  local mode="${1:-}"
  local xctest_count="${2:-}"
  local swift_testing_count="${3:-}"

  # Check for valid mode
  if [[ -z "$mode" ]]; then
    echo -e "${RED}Error: Mode argument required${NC}" >&2
    echo "" >&2
    echo "Usage: $0 <mode> <xctest-count> [swift-testing-count]" >&2
    echo "  Reads test output from stdin" >&2
    echo "" >&2
    echo "Arguments:" >&2
    echo "  mode                - Validation mode (combined|xctest-only|swift-testing-only)" >&2
    echo "  xctest-count        - Expected XCTest count (required)" >&2
    echo "  swift-testing-count - Expected Swift Testing count (required for combined mode)" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  cat test-output.txt | $0 combined 8 9" >&2
    echo "  cat wasm-xctest-output.txt | $0 xctest-only 8" >&2
    echo "  cat wasm-swift-testing-output.txt | $0 swift-testing-only 9" >&2
    exit 2
  fi

  # Validate required arguments based on mode
  case "$mode" in
    combined)
      if [[ -z "$xctest_count" || -z "$swift_testing_count" ]]; then
        echo -e "${RED}Error: Combined mode requires both xctest-count and swift-testing-count${NC}" >&2
        echo "Usage: $0 combined <xctest-count> <swift-testing-count>" >&2
        exit 2
      fi
      ;;
    xctest-only)
      if [[ -z "$xctest_count" ]]; then
        echo -e "${RED}Error: XCTest-only mode requires xctest-count${NC}" >&2
        echo "Usage: $0 xctest-only <xctest-count>" >&2
        exit 2
      fi
      ;;
    swift-testing-only)
      if [[ -z "$swift_testing_count" ]]; then
        # Accept count from either position for flexibility
        if [[ -n "$xctest_count" ]]; then
          swift_testing_count="$xctest_count"
        else
          echo -e "${RED}Error: Swift Testing-only mode requires swift-testing-count${NC}" >&2
          echo "Usage: $0 swift-testing-only <swift-testing-count>" >&2
          exit 2
        fi
      fi
      ;;
    *)
      echo -e "${RED}Error: Invalid mode: $mode${NC}" >&2
      echo "Valid modes: combined, xctest-only, swift-testing-only" >&2
      exit 2
      ;;
  esac

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
      if validate_combined "$input" "$xctest_count" "$swift_testing_count"; then
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
      if validate_xctest_only "$input" "$xctest_count"; then
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
      if validate_swift_testing_only "$input" "$swift_testing_count"; then
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
