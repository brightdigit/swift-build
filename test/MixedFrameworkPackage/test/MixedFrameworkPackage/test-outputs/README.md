# Test Output Examples

This directory contains reference test outputs from running the MixedFrameworkPackage test suite in various configurations. These outputs serve as test fixtures for validating test result parsing logic in the swift-build GitHub Action.

## Package Structure

MixedFrameworkPackage contains:
- **Library Targets**: Calculator, Validator (depends on Utils), Utils
- **Swift Testing Tests**: CalculatorSwiftTestingTests, ValidatorSwiftTestingTests
- **XCTest Tests**: CalculatorXCTests, UtilsXCTests

This mixed-framework setup makes it ideal for testing output parsing across different testing frameworks.

## Output Files

### 1. swift-test-output.txt
**Command**: `swift test`

Native Swift test execution on macOS. Shows both XCTest and Swift Testing outputs in a single run.

**Key Characteristics**:
- XCTest runs first with classic format (`Test Case '-[ClassName.TestName]'`)
- Swift Testing runs second with Unicode symbols (􀟈, 􁁛, etc.)
- Real timestamps (e.g., `2026-01-14 16:41:39.023`)
- Combined test count summary at the end

### 2. xcodebuild-test-output.txt
**Command**: `xcodebuild test -scheme MixedFrameworkPackage-Package -sdk macosx -destination 'platform=macOS' -enableCodeCoverage YES`

Verbose xcodebuild test execution including full build pipeline.

**Key Characteristics**:
- Very large output (~263KB)
- Includes complete build process (WriteAuxiliaryFile, CompileSwift, Link, etc.)
- Test results appear after extensive build logging
- Shows dependency graph and derived data paths
- Note: Swift packages use `-Package` suffix for scheme names

### 3. wasm-swift-testing-output.txt
**Command**: `wasmkit run --dir . .build/wasm32-unknown-wasip1/debug/MixedFrameworkPackagePackageTests.xctest --testing-library swift-testing`

WASM execution with Swift Testing framework using WasmKit runtime.

**Key Characteristics**:
- Only Swift Testing tests run (XCTest tests ignored)
- Unicode symbols similar to native (◇ for started, ✔ for passed)
- Target platform: `wasm32-unknown-wasip`
- High-precision execution times (e.g., `0.006112208 seconds`)
- Clean, structured output

### 4. wasm-xctest-output.txt
**Command**: `wasmkit run --dir . .build/wasm32-unknown-wasip1/debug/MixedFrameworkPackagePackageTests.xctest`

WASM execution with XCTest framework (no `--testing-library` flag).

**Key Characteristics**:
- Only XCTest tests run (Swift Testing tests ignored)
- Classic XCTest format identical to native
- Unix epoch timestamps (`1970-01-02 13:53:54.408`) - artifact of WASM environment
- Test bundle name shows as `debug.xctest`
- Standard test suite hierarchy

### 5. wasm-build-output.txt
**Command**: `swift build --build-tests --swift-sdk swift-6.2.3-RELEASE_wasm`

Successful WASM build output (very brief for cached builds).

**Key Characteristics**:
- Minimal output when build is cached
- Shows planning and build completion time

### 6. wasm-embedded-build-output.txt
**Command**: `swift build --build-tests --swift-sdk swift-6.2.3-RELEASE_wasm-embedded`

Failed build attempt with WASM embedded SDK.

**Key Characteristics**:
- Build fails due to missing Foundation module
- WASM embedded is bare-bones environment without standard library
- Demonstrates platform capability differences

## Usage for Testing

These outputs can be used to:
1. Validate test result parsing logic
2. Test handling of mixed XCTest/Swift Testing frameworks
3. Ensure correct test counting across different output formats
4. Verify timestamp parsing for different formats
5. Test error handling for build failures

## Re-generating Outputs

To regenerate these outputs, run from the MixedFrameworkPackage directory:

```bash
# Standard Swift test
swift test 2>&1 | tee test-outputs/swift-test-output.txt

# Xcodebuild test
xcodebuild test -scheme MixedFrameworkPackage-Package -sdk macosx -destination 'platform=macOS' -enableCodeCoverage YES 2>&1 | tee test-outputs/xcodebuild-test-output.txt

# WASM with Swift Testing
swift build --build-tests --swift-sdk swift-6.2.3-RELEASE_wasm
wasmkit run --dir . .build/wasm32-unknown-wasip1/debug/MixedFrameworkPackagePackageTests.xctest --testing-library swift-testing 2>&1 | tee test-outputs/wasm-swift-testing-output.txt

# WASM with XCTest
wasmkit run --dir . .build/wasm32-unknown-wasip1/debug/MixedFrameworkPackagePackageTests.xctest 2>&1 | tee test-outputs/wasm-xctest-output.txt

# WASM embedded (will fail)
swift build --build-tests --swift-sdk swift-6.2.3-RELEASE_wasm-embedded 2>&1 | tee test-outputs/wasm-embedded-build-output.txt
```

## Generated

These outputs were generated on 2026-01-15 using:
- Swift 6.2.3
- Xcode 16.3
- macOS 15.2.0 (arm64)
- WasmKit runtime (bundled with Swift toolchain)
