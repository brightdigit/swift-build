#!/usr/bin/env bash
# validate-test-totals.sh
# Validates test counts from Swift test output files
#
# Usage:
#   ./scripts/validate-test-totals.sh [DIRECTORY]
#
# Arguments:
#   DIRECTORY - Path to directory containing test output files
#               (default: test/MixedFrameworkPackage/test/MixedFrameworkPackage/test-outputs)
#
# Exit Codes:
#   0 - Success (all counts match expected values)
#   1 - Validation failure (counts don't match)
#   2 - Usage error (missing directory, file not found, etc.)
#
# Examples:
#   # Validate default fixture directory
#   ./scripts/validate-test-totals.sh
#
#   # Validate custom directory
#   ./scripts/validate-test-totals.sh /path/to/test-outputs

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

# Parse XCTest count from output file
# Pattern: "Executed N tests, with M failures"
# Arguments:
#   $1 - Path to test output file
# Returns:
#   Test count (or 0 if not found)
parse_xctest_count() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    echo "0"
    return
  fi

  # For simple outputs (swift test, wasm), take the last non-zero "Executed" line
  # For xcodebuild, we need to sum "All tests" summaries from each test bundle
  # Strategy: Look for lines after "Test Suite 'All tests'" and sum their counts
  local count

  # Check if this looks like xcodebuild output (has multiple "Test Suite 'All tests'")
  local all_tests_count
  all_tests_count=$(grep -c "Test Suite 'All tests'" "$file" 2>/dev/null || echo "0")

  if [[ $all_tests_count -gt 2 ]]; then
    # Xcodebuild output - sum all "All tests" bundle totals
    count=$(grep -A1 "Test Suite 'All tests' passed" "$file" 2>/dev/null | \
      grep -o 'Executed [0-9]\+ tests' | \
      grep -o '[0-9]\+' | \
      awk '{sum+=$1} END {print sum+0}')
  else
    # Simple output - take last non-zero count
    count=$(grep -o 'Executed [0-9]\+ tests' "$file" 2>/dev/null | \
      grep -o '[0-9]\+' | \
      grep -v '^0$' | \
      tail -1)
  fi

  echo "${count:-0}"
}

# Parse Swift Testing count from output file
# Pattern: "Test run with N tests in M suites"
# Handles both Unicode variants: 􁁛 (native) and ✔ (WASM)
# Arguments:
#   $1 - Path to test output file
# Returns:
#   Test count (or 0 if not found)
parse_swift_testing_count() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    echo "0"
    return
  fi

  # Extract all "Test run with N tests" occurrences and sum them
  grep -o 'Test run with [0-9]\+ tests' "$file" 2>/dev/null | \
    grep -o '[0-9]\+' | \
    awk '{sum+=$1} END {print sum+0}'
}

# Validate a combined output file (contains both XCTest and Swift Testing)
# Arguments:
#   $1 - Path to test output file
# Returns:
#   0 if validation passes, 1 if validation fails
validate_combined_output() {
  local file="$1"
  local xctest_count swift_testing_count total
  local validation_passed=0

  if [[ ! -f "$file" ]]; then
    echo -e "${RED}  ✗ File not found: $file${NC}"
    return 1
  fi

  xctest_count=$(parse_xctest_count "$file")
  swift_testing_count=$(parse_swift_testing_count "$file")
  total=$((xctest_count + swift_testing_count))

  echo "  $(basename "$file"):"

  # Validate XCTest count
  if [[ $xctest_count -eq $EXPECTED_XCTEST ]]; then
    echo -e "    ${GREEN}✓${NC} XCTest: $xctest_count (expected: $EXPECTED_XCTEST)"
  else
    echo -e "    ${RED}✗${NC} XCTest: $xctest_count (expected: $EXPECTED_XCTEST)"
    validation_passed=1
  fi

  # Validate Swift Testing count
  if [[ $swift_testing_count -eq $EXPECTED_SWIFT_TESTING ]]; then
    echo -e "    ${GREEN}✓${NC} Swift Testing: $swift_testing_count (expected: $EXPECTED_SWIFT_TESTING)"
  else
    echo -e "    ${RED}✗${NC} Swift Testing: $swift_testing_count (expected: $EXPECTED_SWIFT_TESTING)"
    validation_passed=1
  fi

  # Validate total
  if [[ $total -eq $EXPECTED_TOTAL ]]; then
    echo -e "    ${GREEN}✓${NC} Total: $total (expected: $EXPECTED_TOTAL)"
  else
    echo -e "    ${RED}✗${NC} Total: $total (expected: $EXPECTED_TOTAL)"
    validation_passed=1
  fi

  return $validation_passed
}

# Validate a WASM XCTest-only output file
# Arguments:
#   $1 - Path to test output file
# Returns:
#   0 if validation passes, 1 if validation fails
validate_wasm_xctest() {
  local file="$1"
  local xctest_count
  local validation_passed=0

  if [[ ! -f "$file" ]]; then
    echo -e "${RED}  ✗ File not found: $file${NC}"
    return 1
  fi

  xctest_count=$(parse_xctest_count "$file")

  echo "  $(basename "$file"):"

  if [[ $xctest_count -eq $EXPECTED_XCTEST ]]; then
    echo -e "    ${GREEN}✓${NC} XCTest: $xctest_count (expected: $EXPECTED_XCTEST)"
  else
    echo -e "    ${RED}✗${NC} XCTest: $xctest_count (expected: $EXPECTED_XCTEST)"
    validation_passed=1
  fi

  return $validation_passed
}

# Validate a WASM Swift Testing-only output file
# Arguments:
#   $1 - Path to test output file
# Returns:
#   0 if validation passes, 1 if validation fails
validate_wasm_swift_testing() {
  local file="$1"
  local swift_testing_count
  local validation_passed=0

  if [[ ! -f "$file" ]]; then
    echo -e "${RED}  ✗ File not found: $file${NC}"
    return 1
  fi

  swift_testing_count=$(parse_swift_testing_count "$file")

  echo "  $(basename "$file"):"

  if [[ $swift_testing_count -eq $EXPECTED_SWIFT_TESTING ]]; then
    echo -e "    ${GREEN}✓${NC} Swift Testing: $swift_testing_count (expected: $EXPECTED_SWIFT_TESTING)"
  else
    echo -e "    ${RED}✗${NC} Swift Testing: $swift_testing_count (expected: $EXPECTED_SWIFT_TESTING)"
    validation_passed=1
  fi

  return $validation_passed
}

# Validate all fixture files in a directory
# Arguments:
#   $1 - Path to directory containing test output files
# Returns:
#   0 if all validations pass, 1 if any validation fails
validate_fixture_directory() {
  local dir="$1"
  local exit_code=0

  echo "Validating test output fixtures in: $dir"
  echo ""

  # Validate combined outputs (swift test and xcodebuild)
  echo "Combined Outputs (XCTest + Swift Testing):"
  validate_combined_output "$dir/swift-test-output.txt" || exit_code=1
  echo ""
  validate_combined_output "$dir/xcodebuild-test-output.txt" || exit_code=1
  echo ""

  # Validate WASM split outputs
  echo "WASM Split Outputs:"
  validate_wasm_xctest "$dir/wasm-xctest-output.txt" || exit_code=1
  echo ""
  validate_wasm_swift_testing "$dir/wasm-swift-testing-output.txt" || exit_code=1
  echo ""

  # Validate WASM combined total
  local wasm_xctest wasm_swift_testing wasm_total
  wasm_xctest=$(parse_xctest_count "$dir/wasm-xctest-output.txt")
  wasm_swift_testing=$(parse_swift_testing_count "$dir/wasm-swift-testing-output.txt")
  wasm_total=$((wasm_xctest + wasm_swift_testing))

  echo "WASM Combined Total:"
  if [[ $wasm_total -eq $EXPECTED_TOTAL ]]; then
    echo -e "  ${GREEN}✓${NC} Total: $wasm_total (expected: $EXPECTED_TOTAL)"
  else
    echo -e "  ${RED}✗${NC} Total: $wasm_total (expected: $EXPECTED_TOTAL)"
    exit_code=1
  fi

  return $exit_code
}

# Main entry point
main() {
  local dir="${1:-test/MixedFrameworkPackage/test/MixedFrameworkPackage/test-outputs}"

  # Check if directory exists
  if [[ ! -d "$dir" ]]; then
    echo -e "${RED}Error: Directory not found: $dir${NC}" >&2
    echo "" >&2
    echo "Usage: $0 [DIRECTORY]" >&2
    echo "  DIRECTORY - Path to directory containing test output files" >&2
    echo "              (default: test/MixedFrameworkPackage/test/MixedFrameworkPackage/test-outputs)" >&2
    exit 2
  fi

  # Run validation
  if validate_fixture_directory "$dir"; then
    echo ""
    echo -e "${GREEN}✅ All test counts validated successfully!${NC}"
    exit 0
  else
    echo ""
    echo -e "${RED}❌ Test count validation failed!${NC}"
    exit 1
  fi
}

# Execute main function with all script arguments
main "$@"
