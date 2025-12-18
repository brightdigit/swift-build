# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a GitHub Action for building and testing Swift packages across multiple platforms. The action supports Swift Package Manager (SPM) builds, Xcode builds for Apple platforms (iOS, macOS, watchOS, tvOS, visionOS), and Android builds using the Swift Android SDK.

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

## GitHub Action Usage

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

## Platform Support Matrix

The action supports:
- **Ubuntu**: Swift 5.9-6.2 across focal/jammy/noble distributions
- **macOS**: Xcode 15.1+ with platform-specific simulator testing
- **Android**: Swift 6.2+ with emulator testing (Ubuntu/Intel macOS) or build-only (ARM macOS)
- **Cross-platform caching**: Different strategies for macOS vs Ubuntu builds

## Test Package Architecture

- **SingleTargetPackage**: Simple single-target Swift package for basic validation
- **MultiTargetPackage**: Multi-target package with Core depending on Utils, demonstrating target dependencies

## Task Master AI Instructions
**Import Task Master's development workflow commands and guidelines, treat as if import is in the main CLAUDE.md file.**
@./.taskmaster/CLAUDE.md
