# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a GitHub Action for building and testing Swift packages across multiple platforms. The action supports Swift Package Manager (SwiftPM) builds, Xcode builds for Apple platforms (iOS, macOS, watchOS, tvOS, visionOS), and Android builds using the Swift Android SDK.

## Project Structure

- `action.yml` - Main GitHub Action definition with input parameters and build/test steps
- `.github/workflows/swift-test.yml` - CI workflow testing the action across different platform configurations
- `test/SingleTargetPackage/` - Test Swift package with a single target for validation
- `test/MultiTargetPackage/` - Test Swift package with multiple targets (Core and Utils) for validation

## Build Commands

### Local Swift Package Testing
For testing Swift packages locally:
```bash
# In test/SingleTargetPackage or test/MultiTargetPackage
swift build --build-tests --cache-path .cache --force-resolved-versions
swift test --enable-code-coverage --cache-path .cache --force-resolved-versions
```

### Xcode Testing (macOS only)
For Apple platform testing:
```bash
# macOS
xcodebuild test -scheme [SCHEME] -sdk macosx -destination 'platform=macOS' -enableCodeCoverage YES

# iOS Simulator
xcodebuild test -scheme [SCHEME] -sdk iphonesimulator -destination 'platform=iOS Simulator,name=[DEVICE],OS=[VERSION]' -enableCodeCoverage YES

# Similar patterns for watchOS, tvOS, and visionOS
```

### Android Testing
For Android platform testing (requires skiptools/swift-android-action):
```bash
# Android emulator testing (Ubuntu or Intel macOS)
# Handled by skiptools/swift-android-action@v2
# Supports Swift 6.2+, API levels 28+

# ARM macOS runners: build-only mode (no emulator support)
# Use android-run-tests: false for ARM macOS
```

Note: Android builds delegate to skiptools/swift-android-action. See action.yml for full parameter documentation.

### WebAssembly (Wasm) Testing
For WebAssembly platform testing:
```bash
# Wasm builds use Swift Wasm SDK + WasmKit runtime (default, bundled with Swift 6.2.3+)
# Wasmtime available as optional fallback via wasmtime-version parameter
# Supports: wasm32-unknown-wasi and wasm32-unknown-unknown-wasm (embedded)

# Build and test with WasmKit (default - no downloads required)
swift build --build-tests --swift-sdk swift-6.2.3-RELEASE_wasm
wasmkit run .build/swift-6.2.3-RELEASE_wasm/debug/MyPackageTests.wasm --testing-library swift-testing

# OPTIONAL: Wasmtime fallback for older Swift versions
# Configure via wasmtime-version parameter (e.g., '27.0.0', '26.0.0')
# Breaking Change (v2.0): 'latest' is no longer supported - use specific versions
# Wasmtime binary is automatically cached to avoid ~500MB download per run
# First run with Wasmtime: downloads binary (~3-5 minutes)
# Subsequent runs: uses cached binary (<5 seconds)
```

**WasmKit (Default):**
- Bundled with Swift 6.2.3+ toolchains - no external downloads
- Instant test execution (no download delays)
- No caching overhead (~500MB saved compared to Wasmtime)

**Wasmtime (Fallback):**
- Used when `wasmtime-version` parameter is explicitly specified
- Wasmtime binaries are cached per version to avoid repeated downloads
- Cache key: `wasmtime-{version}-{os}-{arch}`

**Testing Framework Detection (NEW):**
The action automatically detects which testing framework your Wasm tests use:
- **Swift Testing** (`import Testing`) → runs with `--testing-library swift-testing`
- **XCTest** (`import XCTest`) → runs without testing library flag
- **Both frameworks** → runs tests twice (once for each framework)

Override auto-detection with the `wasm-testing-library` parameter:
```yaml
- uses: YourOrg/swift-build@v2
  with:
    type: wasm
    wasm-testing-library: 'swift-testing'  # Force Swift Testing
    wasm-swift-test-flags: '--parallel'    # Optional test runner flags
```

**Code Coverage:** Wasm builds do NOT support code coverage (neither WasmKit nor Wasmtime provide coverage support). Use the `contains-code-coverage` output to conditionally skip coverage collection for Wasm builds.

## GitHub Action Usage

### Inputs

The action accepts these key inputs:
- `scheme` (required) - The scheme to build and test
- `working-directory` - Directory containing the Swift package (default: '.')
- `type` - Build type for Apple platforms (ios, watchos, visionos, tvos, macos)
- `xcode` - Xcode version path for Apple platforms
- `deviceName` / `osVersion` - Simulator configuration for Apple platforms
- `download-platform` - Whether to download platform if not available
- **Android-specific parameters** (auto-detects Android when any are set):
  - `android-swift-version` - Swift version for Android (default: '6.2')
  - `android-api-level` - Android API level (default: '28')
  - `android-ndk-version` - Android NDK version (requires manual NDK installation)
  - `android-run-tests` - Run tests on emulator (default: true; use false for ARM macOS)
  - `android-swift-build-flags` / `android-swift-test-flags` - Additional build/test flags
  - `android-emulator-boot-timeout` - Emulator timeout in seconds (default: '600')
- **Wasm-specific parameters**:
  - `wasm-swift-flags` - Additional Swift compiler/linker flags for Wasm builds (required for most projects)
    - Example: `-Xcc -D_WASI_EMULATED_SIGNAL -Xcc -D_WASI_EMULATED_MMAN -Xlinker -lwasi-emulated-signal -Xlinker -lwasi-emulated-mman -Xlinker -lwasi-emulated-getpid -Xlinker --initial-memory=536870912 -Xlinker --max-memory=536870912`
    - WASI emulation flags are required for projects using Foundation/CoreFoundation
    - Memory configuration flags often required for test suites with large datasets (default Wasm memory ~62MB)
    - Must be explicitly configured (no defaults provided)
  - `wasmtime-version` - Optional Wasmtime runtime fallback (default: WasmKit)
    - Default: Uses WasmKit runtime (bundled with Swift 6.2.3+ toolchains)
    - Specify a specific version to use Wasmtime fallback: '27.0.0', '26.0.0', etc. (X.Y.Z format)
    - Breaking Change (v2.0): 'latest' is no longer supported - use specific version numbers
    - Automatically cached when using Wasmtime to avoid ~500MB download per run
  - `wasm-testing-library` - Testing library detection mode for Wasm tests (default: 'auto')
    - `auto`: Automatically detect by scanning test sources for `import Testing` vs `import XCTest`
    - `swift-testing`: Force Swift Testing framework (adds `--testing-library swift-testing` flag)
    - `xctest`: Force XCTest framework (no testing library flag)
    - `both`: Run tests twice (once for each framework, fails if either fails)
    - `none`: Run without testing library flags (for custom test harnesses)
      - **When to use:**
        - Custom test frameworks (not XCTest or Swift Testing)
        - Test harnesses that provide their own command-line interface
        - Debugging test execution without framework-specific flags
        - Binary testing tools that don't expect testing library arguments
      - **Example:**
        ```yaml
        - uses: YourOrg/swift-build@v2
          with:
            type: wasm
            wasm-testing-library: 'none'  # No --testing-library flag
            wasm-swift-test-flags: '--custom-flag --verbose'  # Custom harness flags
        ```
      - **Note:** Most projects should use `auto` mode instead. Only use `none` if you have a custom test framework.
  - `wasm-swift-test-flags` - Additional flags passed to test runner (WasmKit/Wasmtime)
    - Examples: `'--parallel'`, `'--filter TestSuiteName'`
    - Applied after `--testing-library` flag

**Security Considerations:**
- **`wasm-swift-flags` and `wasm-swift-test-flags` Input Sanitization**: These parameters are parsed into bash arrays to prevent command injection vulnerabilities. Values are split on whitespace to support multiple space-separated flags (e.g., `--parallel --verbose`). While GitHub Actions input parameters are typically sourced from trusted workflow YAML files, array-based parsing provides defense-in-depth protection against injection attacks.

  **Limitations**: Flags requiring space-containing values are not supported (e.g., `--filter "Test Suite"` will be incorrectly split). Use alternative formats like `--filter=TestSuite` or comma-separated values where possible.

### Outputs

The action provides these outputs:
- `contains-code-coverage` - Whether this build contains code coverage data
  - Returns `'true'` for SwiftPM and Xcode builds with tests enabled
  - Returns `'false'` for Wasm builds (not supported), Android builds (handled separately), and build-only mode
  - Use this to conditionally run coverage collection actions:
    ```yaml
    - name: Generate Coverage
      if: steps.build.outputs.contains-code-coverage == 'true'
      uses: sersoft-gmbh/swift-coverage-action@v5
    ```

## Platform Support Matrix

The action supports:
- **Ubuntu**: Swift 5.9-6.2 across focal/jammy/noble distributions
- **macOS**: Xcode 15.1+ with platform-specific simulator testing
- **Android**: Swift 6.2+ with emulator testing (Ubuntu/Intel macOS) or build-only (ARM macOS)
- **WebAssembly (Wasm)**: Swift 6.2+ with Wasmtime runtime (auto-cached binaries)
- **Cross-platform caching**: Different strategies for macOS vs Ubuntu builds, with optimized Wasmtime binary caching

## Latest Platform Versions

**Current Stable Release: Xcode 26.4**
- **Xcode Version:** 26.4

**Recent Stable Releases:**
- **Xcode 26.2** - Swift 6.2.3 (December 12, 2025)
- **Xcode 26.1.1** - Swift 6.2.1 (November 11, 2025)
- **Xcode 26.1** - Swift 6.2.1 (November 3, 2025)
- **Xcode 26.0.1** - Swift 6.2 (September 22, 2025)

**Note:** Version information sourced from [xcodereleases.com](https://xcodereleases.com). For the most current releases and beta versions, refer to the live data.

## Test Package Architecture

- **SingleTargetPackage**: Simple single-target Swift package for basic validation
- **MultiTargetPackage**: Multi-target package with Core depending on Utils, demonstrating target dependencies

## Wasm Migration Guide

**Breaking Change (v2.0)**: Wasm compiler flags are now explicitly configured via input parameters instead of being hardcoded.

### Migration Steps

**Before (v1.x - implicit flags)**:
```yaml
- uses: YourOrg/swift-build@v1
  with:
    type: wasm
```

**After (v2.0 - explicit flags)**:
```yaml
- uses: YourOrg/swift-build@v2
  with:
    type: wasm
    wasm-swift-flags: >-
      -Xcc -D_WASI_EMULATED_SIGNAL
      -Xcc -D_WASI_EMULATED_MMAN
      -Xlinker -lwasi-emulated-signal
      -Xlinker -lwasi-emulated-mman
      -Xlinker -lwasi-emulated-getpid
      -Xlinker --initial-memory=536870912
      -Xlinker --max-memory=536870912
```

### Common Flag Patterns

**WASI Emulation Flags** (required for Foundation/CoreFoundation):
- `-Xcc -D_WASI_EMULATED_SIGNAL` - Required for signal.h support
- `-Xcc -D_WASI_EMULATED_MMAN` - Required for mmap support
- `-Xlinker -lwasi-emulated-signal` - Link against WASI signal emulation library
- `-Xlinker -lwasi-emulated-mman` - Link against WASI mmap emulation library
- `-Xlinker -lwasi-emulated-getpid` - Link against WASI getpid emulation library

**Memory Configuration Flags** (for test suites with large datasets):
- `-Xlinker --initial-memory=536870912` - Set initial memory to 512MB (default: ~62MB)
- `-Xlinker --max-memory=536870912` - Set maximum memory to 512MB
- Adjust values based on your test suite requirements (values in bytes)

**When to Use Which Flags**:
- Most Swift projects using Foundation/CoreFoundation will need WASI emulation flags
- Test suites processing large data (XML, JSON, images) will need memory configuration
- Pure Swift code without Foundation dependencies may work without flags
- Start with the example configuration above and adjust as needed
