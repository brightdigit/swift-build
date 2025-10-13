# Swift-Build 

[![CI](https://github.com/brightdigit/swift-build/workflows/CI/badge.svg)](https://github.com/brightdigit/swift-build/actions)
[![GitHub release](https://img.shields.io/github/release/brightdigit/swift-build.svg)](https://github.com/brightdigit/swift-build/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**A comprehensive GitHub Action for building and testing Swift packages across all platforms with intelligent caching and zero-config setup.**

> [!NOTE]
> :open_book: **Learn how** `swift-build` works in [this blog post.](https://brightdigit.com/tutorials/swift-build/)

## 📋 Table of Contents

- [✨ Why Choose This Action?](#-why-choose-this-action)
- [⚙️ Configuration Reference](#️-configuration-reference)
  - [Required Parameters](#required-parameters)
  - [Optional Parameters](#optional-parameters)
  - [Parameter Combinations & Interactions](#parameter-combinations--interactions)
  - [Default Behaviors](#default-behaviors)
  - [Build Tool Selection](#build-tool-selection)
- [🚀 Quick Start](#-quick-start)
  - [Basic Usage Examples](#basic-usage-examples)
  - [iOS Simulator Testing](#ios-simulator-testing)
  - [Multi-Platform Matrix Configurations](#multi-platform-matrix-configurations)
- [⚙️ Configuration Examples by Use Case](#️-configuration-examples-by-use-case)
- [🌟 Real-World Examples](#-real-world-examples)
- [🌍 Platform Support](#-platform-support)
- [🚀 Advanced Examples](#-advanced-examples)
- [🔧 Troubleshooting & FAQ](#-troubleshooting--faq)
- [🔗 Related Actions & Caching Strategies](#-related-actions--caching-strategies)
- [🔄 Migration Guides and Workflow Templates](#-migration-guides-and-workflow-templates)
- [🐛 Issue Reporting and Debug Guide](#-issue-reporting-and-debug-guide)

## ✨ Why Choose This Action?

🚀 **Zero Configuration** - Works out of the box with just a scheme parameter  
⚡ **Intelligent Caching** - Platform-specific caching strategies for maximum performance  
🌍 **Complete Platform Coverage** - Ubuntu (Swift 5.9-6.2) + macOS (iOS, watchOS, tvOS, visionOS, macOS) + Windows (Swift 6.1+)  
🎯 **Optimized Workflows** - Purpose-built for modern Swift CI/CD pipelines  
📦 **Real-World Proven** - Used by 25+ open source Swift packages including SyndiKit, DataThespian, and more  

## ⚙️ Configuration Reference

### Parameters

| Parameter | Description | Default | Example | Valid Values | Used By |
|-----------|-------------|---------|---------|--------------|---------|
| `scheme` | The scheme to build and test | Required when `type` specified | `MyPackage-Package` | Any valid scheme name | **Xcode builds only** - Required when `type` is specified (iOS, watchOS, tvOS, visionOS, macOS simulator testing). Not needed for SPM builds (Ubuntu/macOS) |
| `working-directory` | Directory containing the Swift package | `.` | `./MyPackage` | Any valid directory path | **All platforms** - SPM (Ubuntu/macOS) and Xcode builds |
| `type` | Build type for Apple platforms | `null` | `ios` | `ios`, `watchos`, `visionos`, `tvos`, `macos` | **Xcode builds only** - When specified, uses xcodebuild. When `null` (not specified), uses SPM (swift build/test) instead |
| `xcode` | Xcode version path for Apple platforms | System default | `/Applications/Xcode_15.4.app` | Any Xcode.app path | **Xcode builds only** - iOS, watchOS, tvOS, visionOS, macOS simulator testing |
| `deviceName` | Simulator device name | `null` | `iPhone 15` | Any available simulator | **Xcode builds only** - Required when `type` is specified (except `macos`) |
| `osVersion` | Simulator OS version | `null` | `17.5` | Compatible OS version | **Xcode builds only** - Required when `type` is specified (except `macos`) |
| `download-platform` | Download platform if not available | `false` | `true` | `true`, `false` | **Xcode builds only** - iOS, watchOS, tvOS, visionOS simulator testing |
| `build-only` | Build without running tests | `false` | `true` | `true`, `false` | **All platforms** - SPM (Ubuntu/macOS/Windows) and Xcode builds |
| `windows-swift-version` | Swift version for Windows toolchain | `null` | `swift-6.1-release` | `swift-6.0-release`, `swift-6.1-release`, `swift-6.2-branch` | **Windows builds only** - Maps to `swift-version` parameter in [compnerd/gha-setup-swift](https://github.com/compnerd/gha-setup-swift) |
| `windows-swift-build` | Swift build identifier for Windows | `null` | `6.1-RELEASE` | `6.1-RELEASE`, `6.2-DEVELOPMENT-SNAPSHOT-2025-09-06-a` | **Windows builds only** - Maps to `swift-build` parameter in [compnerd/gha-setup-swift](https://github.com/compnerd/gha-setup-swift) |
| `use-xcbeautify` | Enable xcbeautify for prettified xcodebuild output | `false` | `true` | `true`, `false` | **Apple platforms only** - macOS with `type` parameter specified |
| `xcbeautify-renderer` | xcbeautify renderer for CI integration | `default` | `github-actions` | `default`, `github-actions`, `teamcity`, `azure-devops-pipelines` | **Apple platforms only** - Used when `use-xcbeautify` is `true` |



### Parameter Combinations & Interactions

- **Ubuntu builds**: Only `working-directory` is used (no `scheme` needed)
- **macOS SPM builds**: `scheme`, `working-directory` (no `type` specified)
- **Apple platform builds**: Require `scheme`, `type`, and optionally `deviceName`/`osVersion`
- **Windows builds**: `working-directory`, `windows-swift-version`, `windows-swift-build` (no `scheme` needed)
- **Custom Xcode**: When `xcode` is specified, it overrides system default
- **Platform download**: Only effective with Xcode versions

### Default Behaviors

- **No `type`**: Uses Swift Package Manager directly with `swift` command (works on Ubuntu, macOS, and Windows)
- **Simulator parameters**: For iOS/watchOS/tvOS/visionOS, you must specify both `deviceName` and `osVersion`. macOS native (`type: macos`) does not require them.
- **No `xcode`**: Uses system default Xcode installation
- **No `working-directory`**: Operates in repository root
- **No Windows parameters**: Windows builds require `windows-swift-version` and `windows-swift-build` to be specified

### Build Tool Selection

- **Swift Package Manager**: Uses `swift build` and `swift test` commands (Ubuntu, macOS, and Windows SPM builds)
- **Xcode Build System**: Uses `xcodebuild` command when `type` is specified (iOS, watchOS, tvOS, visionOS, macOS)

### Build-Only Mode

When `build-only: true` is specified:

- **SPM builds**: Uses `swift build` instead of `swift build --build-tests` + `swift test`
- **Xcode builds**: Uses `xcodebuild build` instead of `xcodebuild test`
- **Code coverage**: Not collected (coverage is only generated when tests are run)
- **Test compilation**: Test targets are not compiled in build-only mode
- **Performance**: Faster execution since tests are skipped
- **Use cases**: Build validation, binary distribution, CI pipelines that separate build and test stages

### xcbeautify Integration

swift-build includes optional integration with [xcbeautify](https://github.com/thii/xcbeautify) for enhanced xcodebuild output formatting and better CI integration.

#### When xcbeautify is Used

- **Platform**: macOS only (requires Xcode toolchain)
- **Trigger**: When `use-xcbeautify: true` AND `type` parameter is specified
- **Purpose**: Provides human-friendly, colored output and better CI integration

#### xcbeautify Renderers

| Renderer | Description | Best For |
|----------|-------------|----------|
| `default` | Standard colored output | Local development, general use |
| `github-actions` | GitHub Actions integration | GitHub Actions workflows |
| `teamcity` | TeamCity service messages | TeamCity CI/CD |
| `azure-devops-pipelines` | Azure DevOps logging | Azure DevOps Pipelines |

#### xcbeautify Benefits

- **Enhanced Readability**: Colored output with proper formatting
- **CI Integration**: Platform-specific renderers for better log parsing
- **Error Highlighting**: Clear identification of warnings and errors
- **Performance**: Faster than alternatives like xcpretty
- **Modern Support**: Works with new Xcode build system and parallel testing

#### Example Usage

```yaml
# Basic xcbeautify usage
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyApp
    type: ios
    deviceName: iPhone 15
    osVersion: '17.0'
    use-xcbeautify: true

# With specific renderer for GitHub Actions
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyApp
    type: ios
    deviceName: iPhone 15
    osVersion: '17.0'
    use-xcbeautify: true
    xcbeautify-renderer: github-actions
```

## 🚀 Quick Start

### Basic Usage Examples

The simplest possible configurations for common Swift package scenarios:

#### Minimal Swift Package Testing (Ubuntu)
```yaml
name: Test Package
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    container: swift:6.1
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyPackage  # Just your package name
```

#### Minimal Swift Package Testing (macOS)
```yaml
name: Test Package
on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyPackage-Package  # Standard SPM scheme naming
```

#### Single-Target Package with Auto-Generated Scheme
```yaml
name: Test Single Target
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    container: swift:6.1
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyLibrary  # Matches your target name in Package.swift
```

#### Multi-Target Package Testing
```yaml
name: Test Multi-Target Package
on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyPackage-Package  # Tests all targets
```

#### Windows Swift Package Testing
```yaml
name: Test Windows Package
on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          windows-swift-version: swift-6.1-release
          windows-swift-build: 6.1-RELEASE
```

#### Build-Only Mode (Skip Tests)
```yaml
name: Build Validation
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    container: swift:6.1
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.4
        with:
          scheme: MyPackage
          build-only: true  # Only build, don't run tests
```

### iOS Simulator Testing

```yaml
name: Test iOS App
on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: YourApp
          type: ios
          deviceName: iPhone 15
          osVersion: '17.0'
```

### iOS Testing with xcbeautify

```yaml
name: Test iOS App with Enhanced Output
on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: YourApp
          type: ios
          deviceName: iPhone 15
          osVersion: '17.0'
          use-xcbeautify: true
          xcbeautify-renderer: github-actions
```

### Multi-Platform Matrix Configurations

#### Complete Ubuntu Swift Version Matrix
```yaml
name: Ubuntu Swift Testing
on: [push, pull_request]

jobs:
  test-ubuntu:
    strategy:
      matrix:
        swift: ['5.9', '5.10', '6.0', '6.1', '6.2']
        ubuntu: [focal, jammy, noble]
        nightly: [false, true]
        exclude:
          # Swift 5.9 not available on Ubuntu Noble
          - swift: '5.9'
            ubuntu: noble
          # Nightly only for latest Swift version
          - swift: '5.9'
            nightly: true
          - swift: '5.10'
            nightly: true
          - swift: '6.0'
            nightly: true
          - swift: '6.1'
            nightly: true
          # Stable releases only for older Swift versions
          - swift: '6.2'
            nightly: false
    
    runs-on: ubuntu-latest
    container:
      image: ${{ matrix.nightly && format('swiftlang/swift:nightly-{0}-{1}', matrix.swift, matrix.ubuntu) || format('swift:{0}-{1}', matrix.swift, matrix.ubuntu) }}
    
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyPackage
```

#### macOS + iOS Combined Matrix
```yaml
name: macOS and iOS Testing
on: [push, pull_request]

jobs:
  test-apple-platforms:
    strategy:
      matrix:
        include:
          # macOS SPM builds
          - os: macos-14
            xcode: /Applications/Xcode_15.1.app
          - os: macos-15
            xcode: /Applications/Xcode_16.4.app
          
          # macOS native testing
          - os: macos-14
            type: macos
            xcode: /Applications/Xcode_15.1.app
          - os: macos-15
            type: macos
            xcode: /Applications/Xcode_16.4.app
          
          # iOS simulator testing
          - os: macos-14
            type: ios
            xcode: /Applications/Xcode_15.1.app
            deviceName: iPhone 15
            osVersion: '17.0'
          - os: macos-15
            type: ios
            xcode: /Applications/Xcode_16.4.app
            deviceName: iPhone 16 Pro
            osVersion: '18.5'
    
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyPackage
          type: ${{ matrix.type }}
          xcode: ${{ matrix.xcode }}
          deviceName: ${{ matrix.deviceName }}
          osVersion: ${{ matrix.osVersion }}
```

#### Cross-Platform SPM Matrix (Ubuntu + macOS + Windows)
```yaml
name: Cross-Platform SPM Testing
on: [push, pull_request]

jobs:
  test-cross-platform:
    strategy:
      matrix:
        include:
          # Ubuntu builds
          - os: ubuntu-latest
            container: swift:5.9-jammy
            swift: '5.9'
          - os: ubuntu-latest
            container: swift:6.1-noble
            swift: '6.1'
          - os: ubuntu-latest
            container: swiftlang/swift:nightly-6.2-noble
            swift: '6.2-nightly'
          
          # macOS builds
          - os: macos-14
            xcode: /Applications/Xcode_15.1.app
            swift: '5.9'
          - os: macos-15
            xcode: /Applications/Xcode_16.4.app
            swift: '6.0'
          
          # Windows builds
          - os: windows-latest
            windows-swift-version: swift-6.1-release
            windows-swift-build: 6.1-RELEASE
            swift: '6.1'
    
    runs-on: ${{ matrix.os }}
    container: ${{ matrix.container }}
    
    steps:
      - uses: actions/checkout@v4
      - name: Display Swift Version
        run: swift --version
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyPackage-Package
          xcode: ${{ matrix.xcode }}
          windows-swift-version: ${{ matrix.windows-swift-version }}
          windows-swift-build: ${{ matrix.windows-swift-build }}
```

### Windows Swift Development Examples

#### Basic Windows Swift Package Testing
```yaml
name: Windows Swift Package Tests
on: [push, pull_request]

jobs:
  test-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          windows-swift-version: swift-6.1-release
          windows-swift-build: 6.1-RELEASE
```

#### Windows Swift Version Matrix
```yaml
name: Windows Swift Version Testing
on: [push, pull_request]

jobs:
  test-windows-versions:
    strategy:
      matrix:
        include:
          - windows-swift-version: swift-6.0-release
            windows-swift-build: 6.0-RELEASE
            swift: '6.0'
          - windows-swift-version: swift-6.1-release
            windows-swift-build: 6.1-RELEASE
            swift: '6.1'
          - windows-swift-version: swift-6.2-branch
            windows-swift-build: 6.2-DEVELOPMENT-SNAPSHOT-2025-09-06-a
            swift: '6.2-dev'
    
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Display Swift Version
        run: swift --version
      - uses: brightdigit/swift-build@v1.3.5
        with:
          windows-swift-version: ${{ matrix.windows-swift-version }}
          windows-swift-build: ${{ matrix.windows-swift-build }}
```

> **Note:** The Windows Swift toolchain installation is handled automatically by [compnerd/gha-setup-swift](https://github.com/compnerd/gha-setup-swift) based on the provided `windows-swift-version` and `windows-swift-build` parameters. These map to the `swift-version` and `swift-build` parameters respectively in the underlying action.

#### Windows with Custom Working Directory
```yaml
name: Windows Custom Directory
on: [push, pull_request]

jobs:
  test-windows-custom:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          working-directory: ./packages/core
          windows-swift-version: swift-6.1-release
          windows-swift-build: 6.1-RELEASE
```

### Apple Platform Simulator Testing Examples

#### iOS Simulator Testing
```yaml
name: iOS Testing
on: [push, pull_request]

jobs:
  test-ios:
    strategy:
      matrix:
        include:
          # iPhone simulators with Xcode 15.1
          - deviceName: iPhone 15
            osVersion: '17.0'
            xcode: /Applications/Xcode_15.1.app
            runner: macos-14
          - deviceName: iPhone 15 Pro
            osVersion: '17.5'
            xcode: /Applications/Xcode_15.4.app
            runner: macos-14
          
          # iPhone simulators with Xcode 16.4
          - deviceName: iPhone 16
            osVersion: '18.0'
            xcode: /Applications/Xcode_16.4.app
            runner: macos-15
          - deviceName: iPhone 16 Pro
            osVersion: '18.5'
            xcode: /Applications/Xcode_16.4.app
            runner: macos-15

    runs-on: ${{ matrix.runner }}
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyApp
          type: ios
          xcode: ${{ matrix.xcode }}
          deviceName: ${{ matrix.deviceName }}
          osVersion: ${{ matrix.osVersion }}
```

#### iOS Testing with xcbeautify
```yaml
name: iOS Testing with Enhanced Output
on: [push, pull_request]

jobs:
  test-ios-enhanced:
    strategy:
      matrix:
        include:
          # iPhone simulators with enhanced output
          - deviceName: iPhone 15
            osVersion: '17.0'
            xcode: /Applications/Xcode_15.1.app
            runner: macos-14
            renderer: github-actions
          - deviceName: iPhone 16 Pro
            osVersion: '18.5'
            xcode: /Applications/Xcode_16.4.app
            runner: macos-15
            renderer: github-actions

    runs-on: ${{ matrix.runner }}
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyApp
          type: ios
          xcode: ${{ matrix.xcode }}
          deviceName: ${{ matrix.deviceName }}
          osVersion: ${{ matrix.osVersion }}
          use-xcbeautify: true
          xcbeautify-renderer: ${{ matrix.renderer }}
```

#### watchOS Simulator Testing
```yaml
name: watchOS Testing
on: [push, pull_request]

jobs:
  test-watchos:
    strategy:
      matrix:
        include:
          # Apple Watch simulators
          - deviceName: Apple Watch Series 9 (45mm)
            osVersion: '10.0'
            xcode: /Applications/Xcode_15.1.app
          - deviceName: Apple Watch Ultra 2 (49mm)
            osVersion: '11.0'
            xcode: /Applications/Xcode_16.4.app
          - deviceName: Apple Watch Series 10 (46mm)
            osVersion: '11.5'
            xcode: /Applications/Xcode_16.4.app

    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyWatchApp
          type: watchos
          xcode: ${{ matrix.xcode }}
          deviceName: ${{ matrix.deviceName }}
          osVersion: ${{ matrix.osVersion }}
```

#### tvOS Simulator Testing
```yaml
name: tvOS Testing
on: [push, pull_request]

jobs:
  test-tvos:
    strategy:
      matrix:
        include:
          # Apple TV simulators
          - deviceName: Apple TV 4K (3rd generation)
            osVersion: '17.0'
            xcode: /Applications/Xcode_15.1.app
          - deviceName: Apple TV 4K (3rd generation)
            osVersion: '18.0'
            xcode: /Applications/Xcode_16.4.app
          - deviceName: Apple TV 4K (3rd generation)
            osVersion: '18.5'
            xcode: /Applications/Xcode_16.4.app

    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyTVApp
          type: tvos
          xcode: ${{ matrix.xcode }}
          deviceName: ${{ matrix.deviceName }}
          osVersion: ${{ matrix.osVersion }}
```

#### visionOS Simulator Testing
```yaml
name: visionOS Testing
on: [push, pull_request]

jobs:
  test-visionos:
    strategy:
      matrix:
        include:
          # Apple Vision Pro simulators
          - deviceName: Apple Vision Pro
            osVersion: '1.0'
            xcode: /Applications/Xcode_15.1.app
          - deviceName: Apple Vision Pro
            osVersion: '2.0'
            xcode: /Applications/Xcode_16.4.app
          - deviceName: Apple Vision Pro
            osVersion: '2.5'
            xcode: /Applications/Xcode_16.4.app

    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyVisionApp
          type: visionos
          xcode: ${{ matrix.xcode }}
          deviceName: ${{ matrix.deviceName }}
          osVersion: ${{ matrix.osVersion }}
```

#### macOS Native Testing
```yaml
name: macOS Native Testing
on: [push, pull_request]

jobs:
  test-macos:
    strategy:
      matrix:
        include:
          # macOS native builds with different Xcode versions
          - xcode: /Applications/Xcode_15.1.app
            runner: macos-14
          - xcode: /Applications/Xcode_15.4.app
            runner: macos-14
          - xcode: /Applications/Xcode_16.4.app
            runner: macos-15

    runs-on: ${{ matrix.runner }}
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyMacApp
          type: macos
          xcode: ${{ matrix.xcode }}
```

#### Complete Apple Ecosystem Matrix
```yaml
name: Apple Ecosystem Testing
on: [push, pull_request]

jobs:
  test-apple-ecosystem:
    strategy:
      matrix:
        include:
          # iOS platforms
          - type: ios
            deviceName: iPhone 15
            osVersion: '17.0'
            xcode: /Applications/Xcode_15.1.app
            runner: macos-14
          - type: ios
            deviceName: iPhone 16 Pro
            osVersion: '18.5'
            xcode: /Applications/Xcode_16.4.app
            runner: macos-15
          
          # watchOS platforms
          - type: watchos
            deviceName: Apple Watch Ultra 2 (49mm)
            osVersion: '10.0'
            xcode: /Applications/Xcode_15.1.app
            runner: macos-14
          - type: watchos
            deviceName: Apple Watch Ultra 2 (49mm)
            osVersion: '11.5'
            xcode: /Applications/Xcode_16.4.app
            runner: macos-15
          
          # tvOS platforms
          - type: tvos
            deviceName: Apple TV 4K (3rd generation)
            osVersion: '17.0'
            xcode: /Applications/Xcode_15.1.app
            runner: macos-14
          - type: tvos
            deviceName: Apple TV 4K (3rd generation)
            osVersion: '18.5'
            xcode: /Applications/Xcode_16.4.app
            runner: macos-15
          
          # visionOS platforms
          - type: visionos
            deviceName: Apple Vision Pro
            osVersion: '1.0'
            xcode: /Applications/Xcode_15.1.app
            runner: macos-14
          - type: visionos
            deviceName: Apple Vision Pro
            osVersion: '2.5'
            xcode: /Applications/Xcode_16.4.app
            runner: macos-15
          
          # macOS native
          - type: macos
            xcode: /Applications/Xcode_15.1.app
            runner: macos-14
          - type: macos
            xcode: /Applications/Xcode_16.4.app
            runner: macos-15

    runs-on: ${{ matrix.runner }}
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyUniversalApp
          type: ${{ matrix.type }}
          xcode: ${{ matrix.xcode }}
          deviceName: ${{ matrix.deviceName }}
          osVersion: ${{ matrix.osVersion }}
```

## 🌟 Real-World Examples

### Production Usage from Open Source Projects

**SyndiKit** - Swift Package for Decoding RSS Feeds  
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            container: swift:6.1
          - os: macos-latest
    runs-on: ${{ matrix.os }}
    container: ${{ matrix.container }}
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: SyndiKit-Package
```
*Repository: [brightdigit/SyndiKit](https://github.com/brightdigit/SyndiKit)*

**DataThespian** - Concurrency-Friendly SwiftData  
```yaml
name: macOS
on: [push, pull_request]
jobs:
  test-macos:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: DataThespian-Package
```
*Repository: [brightdigit/DataThespian](https://github.com/brightdigit/DataThespian)*

**Sublimation** - Server-Side Swift Development  
```yaml
name: Swift Tests
on: [push, pull_request]
jobs:
  test:
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            container: swift:5.9
            swift: 5.9
          - os: ubuntu-latest
            container: swift:5.10
            swift: 5.10
          - os: macos-latest
            swift: 5.9
          - os: macos-latest
            swift: 5.10
    runs-on: ${{ matrix.os }}
    container: ${{ matrix.container }}
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: Sublimation-Package
```
*Repository: [brightdigit/Sublimation](https://github.com/brightdigit/Sublimation)*

### More Examples from the BrightDigit Ecosystem

| Package | Purpose | CI Strategy |
|---------|---------|-------------|
| **[AviaryInsights](https://github.com/brightdigit/AviaryInsights)** | Plausible Analytics SDK | Ubuntu + macOS matrix |
| **[FeatherQuill](https://github.com/brightdigit/FeatherQuill)** | Feature flag management | Cross-platform testing |
| **[Options](https://github.com/brightdigit/Options)** | Enhanced enum utilities | Swift version matrix |
| **[SimulatorServices](https://github.com/brightdigit/SimulatorServices)** | simctl Swift interface | macOS-only with iOS simulator |
| **[ThirtyTo](https://github.com/brightdigit/ThirtyTo)** | Base32Crockford encoding | Multi-platform validation |

### Key Patterns from Production Usage

1. **Simple Package Testing**: Most projects use basic `scheme` parameter only
2. **Cross-Platform Strategy**: Ubuntu + macOS matrix for maximum compatibility  
3. **Zero Configuration**: No additional setup or caching configuration needed
4. **Consistent Naming**: `PackageName-Package` scheme naming convention
5. **Reliable Defaults**: Let swift-build handle platform-specific optimizations

## ⚙️ Configuration Examples by Use Case

### Swift Package Manager (Ubuntu/macOS/Windows)
```yaml
# Ubuntu/macOS
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyPackageTests
    working-directory: ./packages/core

# Windows
- uses: brightdigit/swift-build@v1.3.5
  with:
    working-directory: ./packages/core
    windows-swift-version: swift-6.1-release
    windows-swift-build: 6.1-RELEASE
```

### iOS Simulator Testing
```yaml
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyApp
    type: ios
    deviceName: iPhone 15 Pro
    osVersion: '17.5'
```

### iOS Testing with xcbeautify
```yaml
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyApp
    type: ios
    deviceName: iPhone 15 Pro
    osVersion: '17.5'
    use-xcbeautify: true
    xcbeautify-renderer: github-actions
```

### macOS Native Testing
```yaml
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyApp
    type: macos
```

### Custom Xcode Version
```yaml
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyApp
    type: ios
    xcode: /Applications/Xcode_16.4.app
    deviceName: iPhone 16 Pro
    osVersion: '18.5'
```

### Beta Platform Support
```yaml
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyApp
    type: visionos
    xcode: /Applications/Xcode_26_beta.app
    deviceName: Apple Vision Pro
    osVersion: '26.0'
    download-platform: true
```

### Build-Only Mode
```yaml
# SPM build without running tests
- uses: brightdigit/swift-build@v1.3.4
  with:
    scheme: MyPackage
    build-only: true

# iOS build without running tests
- uses: brightdigit/swift-build@v1.3.4
  with:
    scheme: MyApp
    type: ios
    deviceName: iPhone 15 Pro
    osVersion: '17.5'
    build-only: true
```

## 🌍 Platform Support

swift-build works seamlessly across all major platforms with zero configuration required.

### Supported Platforms

| Platform | Build Tool | What swift-build Provides |
|----------|------------|---------------------------|
| **Ubuntu Linux** | Swift Package Manager | Automatic dependency caching, optimized build paths |
| **macOS** | Swift Package Manager | Xcode integration, intelligent DerivedData management |
| **Windows** | Swift Package Manager | Windows Swift toolchain installation, Windows-specific caching |
| **iOS** | Xcode + Simulators | Simulator management, device selection, platform downloads |
| **watchOS** | Xcode + Simulators | Paired simulator setup, automatic device pairing |
| **tvOS** | Xcode + Simulators | Apple TV simulator configuration |
| **visionOS** | Xcode + Simulators | Vision Pro simulator support (Xcode 16.4+) |
| **macOS (native)** | Xcode | Direct native testing without simulators |

### Version Compatibility

For detailed version compatibility and release information:

- **Swift Versions**: [swiftversion.net](https://swiftversion.net) - Complete Swift version history and platform support
- **Xcode Releases**: [xcodereleases.com](https://xcodereleases.com) - Comprehensive Xcode version database with Swift versions and SDK support

### Docker Images for Linux Builds

Choose the right Docker image for your Swift version:

| Image Type | When to Use | Example |
|------------|-------------|---------|
| **[Official Swift](https://hub.docker.com/_/swift)** | Stable releases (6.0, 6.1+) | `swift:6.1-noble` |
| **[Swift Nightly](https://hub.docker.com/r/swiftlang/swift/tags)** | Development/nightly builds [[memory:3814335]] | `swiftlang/swift:nightly-6.2-noble` |

### GitHub Runner Support

| Runner | Best For | swift-build Features |
|--------|----------|---------------------|
| **ubuntu-latest** | Swift Package Manager testing | Linux-optimized caching, container support |
| **windows-latest** | Windows Swift development | Windows Swift toolchain installation, Windows-specific caching |
| **macos-14** | Stable Xcode versions (15.x) | iOS/watchOS/tvOS simulators, Xcode 15 support |
| **macos-15** | Latest Xcode versions (16.x+) | visionOS support, Xcode 16+ beta features |

### Platform-Specific Features

- **🔍 Auto-Detection**: Automatically detects runner OS and configures appropriate build tools
- **📦 Smart Caching**: Platform-specific caching strategies (`.build` + `.swiftpm` on Linux/Windows, DerivedData on macOS)
- **🪟 Windows Toolchain**: Automatic Swift toolchain installation and configuration for Windows runners
- **📲 Simulator Management**: Automatic iOS/watchOS/tvOS/visionOS simulator setup and device selection
- **⬇️ Platform Downloads**: Automatically downloads missing Apple platform simulators for beta/nightly Xcode
- **🛠️ Build Tool Selection**: Uses `swift` command on Linux/macOS/Windows SPM, `xcodebuild` for Apple platforms
- **🎨 Enhanced Output**: Optional xcbeautify integration for prettified xcodebuild output with CI-specific renderers

### External Resources

- **GitHub Runner Images**: [github.com/actions/runner-images](https://github.com/actions/runner-images)
- **macOS Runner Documentation**: [GitHub Hosted Runners](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners/about-github-hosted-runners#supported-runners-and-hardware-resources)
- **Swift Docker Hub**: [Official Swift Images](https://hub.docker.com/_/swift)
- **Windows Swift Setup**: [compnerd/gha-setup-swift](https://github.com/compnerd/gha-setup-swift) - The underlying action used for Windows Swift toolchain installation with detailed parameter documentation

## 🚀 Advanced Examples

### Complete Multi-Platform Matrix

```yaml
name: Comprehensive Swift Testing
on: [push, pull_request]

jobs:
  test-cross-platform:
    strategy:
      matrix:
        include:
          # Ubuntu Matrix
          - os: ubuntu-latest
            swift: '5.9'
            container: swift:5.9-jammy
          - os: ubuntu-latest
            swift: '6.2'
            container: swiftlang/swift:nightly-6.2-noble
          
          # macOS SPM Matrix
          - os: macos-14
            xcode: /Applications/Xcode_15.1.app
          - os: macos-15
            xcode: /Applications/Xcode_16.4.app
          
          # iOS Matrix
          - os: macos-14
            type: ios
            xcode: /Applications/Xcode_15.1.app
            device: iPhone 15
            version: '17.0'
          - os: macos-15
            type: ios
            xcode: /Applications/Xcode_16.4.app
            device: iPhone 16 Pro
            version: '18.5'
          
          # Apple Platform Matrix
          - os: macos-15
            type: watchos
            xcode: /Applications/Xcode_16.4.app
            device: Apple Watch Ultra 2 (49mm)
            version: '11.5'
          - os: macos-15
            type: tvos
            xcode: /Applications/Xcode_16.4.app
            device: Apple TV 4K (3rd generation)
            version: '18.5'
          - os: macos-15
            type: visionos
            xcode: /Applications/Xcode_16.4.app
            device: Apple Vision Pro
            version: '2.5'

    runs-on: ${{ matrix.os }}
    container: ${{ matrix.container }}
    
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyPackage
          type: ${{ matrix.type }}
          xcode: ${{ matrix.xcode }}
          deviceName: ${{ matrix.device }}
          osVersion: ${{ matrix.version }}
```

### Multi-Platform Matrix with xcbeautify

```yaml
name: Comprehensive Swift Testing with Enhanced Output
on: [push, pull_request]

jobs:
  test-cross-platform-enhanced:
    strategy:
      matrix:
        include:
          # iOS with xcbeautify
          - os: macos-14
            type: ios
            xcode: /Applications/Xcode_15.1.app
            device: iPhone 15
            version: '17.0'
            use-xcbeautify: true
            renderer: github-actions
          - os: macos-15
            type: ios
            xcode: /Applications/Xcode_16.4.app
            device: iPhone 16 Pro
            version: '18.5'
            use-xcbeautify: true
            renderer: github-actions
          
          # watchOS with xcbeautify
          - os: macos-15
            type: watchos
            xcode: /Applications/Xcode_16.4.app
            device: Apple Watch Ultra 2 (49mm)
            version: '11.5'
            use-xcbeautify: true
            renderer: github-actions
          
          # visionOS with xcbeautify
          - os: macos-15
            type: visionos
            xcode: /Applications/Xcode_16.4.app
            device: Apple Vision Pro
            version: '2.5'
            use-xcbeautify: true
            renderer: github-actions

    runs-on: ${{ matrix.os }}
    
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyPackage
          type: ${{ matrix.type }}
          xcode: ${{ matrix.xcode }}
          deviceName: ${{ matrix.device }}
          osVersion: ${{ matrix.version }}
          use-xcbeautify: ${{ matrix.use-xcbeautify || 'false' }}
          xcbeautify-renderer: ${{ matrix.renderer }}
```

### Monorepo with Multiple Packages

```yaml
name: Monorepo Testing
on: [push, pull_request]

jobs:
  test-packages:
    strategy:
      matrix:
        package:
          - { path: 'packages/core', scheme: 'CorePackage' }
          - { path: 'packages/networking', scheme: 'NetworkingKit' }
          - { path: 'packages/ui', scheme: 'UIComponents' }
        platform:
          - { os: ubuntu-latest, container: swift:6.1 }
          - { os: macos-latest }
          - { os: macos-latest, type: ios, device: iPhone 15, version: '17.5' }

    runs-on: ${{ matrix.platform.os }}
    container: ${{ matrix.platform.container }}
    
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          working-directory: ${{ matrix.package.path }}
          scheme: ${{ matrix.package.scheme }}
          type: ${{ matrix.platform.type }}
          deviceName: ${{ matrix.platform.device }}
          osVersion: ${{ matrix.platform.version }}
```

### Beta/Nightly Platform Testing

```yaml
name: Beta Platform Testing
on: 
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM
  workflow_dispatch:

jobs:
  test-beta-platforms:
    runs-on: macos-15
    strategy:
      fail-fast: false
      matrix:
        include:
          - type: ios
            device: iPhone 16 Pro
            version: '26.0'
          - type: watchos
            device: Apple Watch Ultra 2 (49mm)
            version: '26.0'
          - type: tvos
            device: Apple TV 4K (3rd generation)
            version: '26.0'
          - type: visionos
            device: Apple Vision Pro
            version: '3.0'

    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyApp
          type: ${{ matrix.type }}
          xcode: /Applications/Xcode_26_beta.app
          deviceName: ${{ matrix.device }}
          osVersion: ${{ matrix.version }}
          download-platform: true
```

### Performance-Optimized Large Project

```yaml
name: Large Project Optimization
on: [push, pull_request]

jobs:
  test-optimized:
    runs-on: macos-latest
    strategy:
      matrix:
        target: [UnitTests, IntegrationTests, UITests]
        
    steps:
      - uses: actions/checkout@v4
      
      # Warm up build cache
      - name: Cache Dependencies
        uses: actions/cache@v4
        with:
          path: |
            ~/Library/Developer/Xcode/DerivedData
            ~/.swiftpm/cache
          key: xcode-${{ runner.os }}-${{ hashFiles('**/Package.resolved', '**/Podfile.lock') }}
          
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: ${{ matrix.target }}
          type: ios
          deviceName: iPhone 15
          osVersion: '17.5'
        env:
          # Enable deterministic builds for consistent results
          SWIFT_DETERMINISTIC_HASHING: 1
```

### Integration with Other Actions

```yaml
name: Complete CI/CD Pipeline
on: [push, pull_request]

jobs:
  quality-gates:
    runs-on: ubuntu-latest
    container: swift:6.1
    steps:
      - uses: actions/checkout@v4
      
      # Code quality checks
      - name: SwiftLint
        uses: norio-nomura/action-swiftlint@3.2.1
        
      - name: SwiftFormat Check
        run: swift package plugin --allow-writing-to-package-directory swiftformat --lint .
        
      # Test with our action
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyPackageTests
          
      # Coverage reporting
      - name: Upload Coverage
        uses: codecov/codecov-action@v4
        with:
          fail_ci_if_error: true

  deploy-docs:
    needs: quality-gates
    if: github.ref == 'refs/heads/main'
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyPackage
          
      # Generate and deploy docs
      - name: Generate Documentation
        run: swift package generate-documentation
        
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: .build/documentation
```

### Custom Xcode Installation Matrix

```yaml
name: Xcode Version Matrix
on: [push, pull_request]

jobs:
  test-xcode-versions:
    strategy:
      matrix:
        include:
          - macos: macos-14
            xcode: /Applications/Xcode_15.1.app
            swift: '5.9'
          - macos: macos-14  
            xcode: /Applications/Xcode_15.4.app
            swift: '5.10'
          - macos: macos-15
            xcode: /Applications/Xcode_16.4.app
            swift: '6.0'
          - macos: macos-15
            xcode: /Applications/Xcode_26_beta.app
            swift: '6.2-dev'
            experimental: true

    runs-on: ${{ matrix.macos }}
    continue-on-error: ${{ matrix.experimental || false }}
    
    steps:
      - uses: actions/checkout@v4
      - name: Display Swift Version
        run: swift --version
        env:
          DEVELOPER_DIR: ${{ matrix.xcode }}/Contents/Developer
          
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyPackage
          xcode: ${{ matrix.xcode }}
```

## 🔧 Troubleshooting & FAQ

### 📋 Table of Contents

- [🔍 Quick Problem Finder](#-quick-problem-finder)
- [❓ Frequently Asked Questions](#-frequently-asked-questions)
  - [📱 iOS Issues](#-ios-issues)
  - [⌚ watchOS Issues](#-watchos-issues) 
  - [📺 tvOS Issues](#-tvos-issues)
  - [🥽 visionOS Issues](#-visionos-issues)
  - [🖥️ macOS Issues](#-macos-issues)
  - [🪟 Windows Issues](#-windows-issues)
  - [⚙️ Configuration Issues](#️-configuration-issues)
  - [🔗 Simulator & Connection Issues](#-simulator--connection-issues)
- [🆘 Community Support](#-community-support)
- [🐛 Reporting Issues](#-reporting-issues)

---

### 🔍 Quick Problem Finder

**Search by Error Message:** Use Ctrl+F to search for your specific error message in this FAQ.

| Error Type | Search Terms | Quick Fix |
|------------|-------------|-----------|
| Simulator not found | `Unable to find device`, `deviceName` | [→ Device/Version Combinations](#q-what-devicenameosversion-combinations-are-valid) |
| Platform missing | `runtime is not available`, `download` | [→ Platform Downloads](#q-how-do-i-fix-platform-not-available-errors) |
| Scheme errors | `scheme`, `does not contain` | [→ Scheme Naming](#q-how-do-i-fix-scheme-not-found-errors) |
| Xcode path issues | `DEVELOPER_DIR`, `xcode-select` | [→ Xcode Paths](#q-what-xcode-path-format-should-i-use) |
| Connection failures | `Lost connection`, `Unable to connect` | [→ Simulator Connection](#q-how-do-i-fix-simulator-connection-issues) |
| Parameter validation | `Invalid input`, `requires` | [→ Parameter Rules](#q-what-are-the-parameter-validation-rules) |

---

### ❓ Frequently Asked Questions

#### 📱 iOS Issues

**Q: What deviceName/osVersion combinations are valid for iOS?**

✅ **Validated iOS combinations:**
```yaml
# Xcode 15.1 - macos-14
- deviceName: iPhone 15
  osVersion: '17.0'
- deviceName: iPhone 15 Pro  
  osVersion: '17.2'

# Xcode 16.4 - macos-15
- deviceName: iPhone 16
  osVersion: '18.0'
- deviceName: iPhone 16 Pro
  osVersion: '18.5'
```

**Q: How do I fix "Unable to find device iPhone X" errors?**

1. **Check available devices first:**
```yaml
- name: List Available iOS Devices
  run: xcrun simctl list devices available | grep iPhone
```

2. **Use validated combinations** from the table above

3. **Provide explicit `deviceName` and `osVersion`** (see validated combinations above):
```yaml
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyApp
    type: ios
    deviceName: iPhone 17
    osVersion: '26.0'
```

**Q: How do I fix iOS simulator connection issues?**

1. **Pre-boot the simulator:**
```yaml
- name: Pre-start iOS Simulator  
  run: xcrun simctl boot "iPhone 15 (17.0)" || true
```

2. **Use reliable device combinations** (see table above)

3. **Enable diagnostic logging:**
```yaml
- name: iOS Connection Diagnostics
  run: |
    xcrun simctl list devices available | grep iPhone
    xcrun simctl list runtimes | grep iOS
```

#### ⌚ watchOS Issues

**Q: How do I fix watchOS pairing issues?**

watchOS simulators require iPhone pairing. **Solution:**
```yaml
- name: Setup watchOS Pairing
  run: |
    # Create paired simulators
    IPHONE_ID=$(xcrun simctl create "iPhone-For-Watch" "iPhone 15" "iOS-17-0")
    WATCH_ID=$(xcrun simctl create "Apple-Watch-Test" "Apple Watch Ultra 2 (49mm)" "watchOS-11-0")
    xcrun simctl pair "$WATCH_ID" "$IPHONE_ID"

- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyWatchApp
    type: watchos
    deviceName: Apple Watch Ultra 2 (49mm)
    osVersion: '11.0'
```

**Q: What watchOS device names should I use?**

✅ **Valid watchOS devices:**
- `Apple Watch Series 9 (45mm)` - Xcode 15.1+
- `Apple Watch Ultra 2 (49mm)` - Xcode 15.4+  
- `Apple Watch Series 10 (46mm)` - Xcode 16.4+

#### 📺 tvOS Issues

**Q: How do I fix Apple TV simulator issues?**

**Always use this exact device name:**
```yaml
deviceName: Apple TV 4K (3rd generation)
```

**Valid tvOS versions by Xcode:**
- Xcode 15.1: `17.0`, `17.2`
- Xcode 16.4: `18.0`, `18.5`

#### 🥽 visionOS Issues

**Q: Why does visionOS say "not supported"?**

visionOS requires **Xcode 16.4+** and **macOS 15+**. Check requirements:
```yaml
- name: Validate visionOS Requirements
  run: |
    XCODE_VERSION=$(xcodebuild -version | head -1 | cut -d' ' -f2)
    if (( $(echo "$XCODE_VERSION < 16.4" | bc -l) )); then
      echo "❌ visionOS requires Xcode 16.4+, found $XCODE_VERSION"
      exit 1
    fi
```

**Q: What visionOS configurations work?**

✅ **Valid visionOS setup:**
```yaml
runs-on: macos-15  # Required: macOS 15+
steps:
  - uses: brightdigit/swift-build@v1.3.5
    with:
      scheme: MyVisionApp
      type: visionos
      xcode: /Applications/Xcode_16.4.app  # Required: Xcode 16.4+
      deviceName: Apple Vision Pro
      osVersion: '2.0'  # or '1.0', '2.5'
      download-platform: true  # Recommended for beta versions
```

#### 🖥️ macOS Issues

**Q: How do I configure macOS testing correctly?**

macOS is **native testing only** - no simulators needed:
```yaml
# ✅ Correct macOS configuration
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyMacApp
    type: macos
    # DO NOT include deviceName/osVersion for macOS

# ❌ Wrong: macOS doesn't use deviceName/osVersion
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyMacApp  
    type: macos
    deviceName: MacBook Pro  # ERROR
    osVersion: '15.0'        # ERROR
```

#### ⚙️ Configuration Issues

**Q: What are the parameter validation rules?**

| Build Type | Required Parameters | Optional | Invalid |
|------------|-------------------|----------|---------|
| **SPM Build** | `—` | `working-directory`, `scheme` (optional) | `type`, `deviceName`, `osVersion`, `use-xcbeautify`, `xcbeautify-renderer` |
| **Windows Build** | `windows-swift-version`, `windows-swift-build` | `working-directory` | `scheme`, `type`, `deviceName`, `osVersion`, `use-xcbeautify`, `xcbeautify-renderer` |
| **macOS Native** | `scheme`, `type: macos` | `xcode`, `working-directory`, `use-xcbeautify`, `xcbeautify-renderer` | `deviceName`, `osVersion` |
| **iOS Simulator** | `scheme`, `type: ios`, `deviceName`, `osVersion` | `xcode`, `download-platform`, `use-xcbeautify`, `xcbeautify-renderer` | None |
| **Other Simulators** | `scheme`, `type`, `deviceName`, `osVersion` | `xcode`, `download-platform`, `use-xcbeautify`, `xcbeautify-renderer` | None |

**Q: How do I fix xcbeautify installation issues?**

**Error:** `Error: Homebrew is not installed. xcbeautify requires Homebrew for installation.`

**Solution:** xcbeautify requires Homebrew on macOS runners. This is automatically available on GitHub's macOS runners, but if you're using self-hosted runners:

```yaml
# Add Homebrew installation step before swift-build
- name: Install Homebrew
  run: |
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "$(/opt/homebrew/bin/brew shellenv)" >> $GITHUB_ENV
    source $GITHUB_ENV

- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyApp
    type: ios
    use-xcbeautify: true
```

**Q: What xcbeautify renderers are available?**

| Renderer | When to Use | Notes |
|----------|-------------|-------|
| `default` | General use, local development | Standard colored output |
| `github-actions` | GitHub Actions workflows | Highlights errors/warnings in GitHub UI |
| `teamcity` | TeamCity CI/CD | Uses TeamCity service messages |
| `azure-devops-pipelines` | Azure DevOps Pipelines | Uses Azure DevOps logging commands |

**Q: Can I use xcbeautify on Ubuntu or Windows?**

**No.** xcbeautify only works on macOS with Xcode toolchain. It will be ignored on Ubuntu and Windows runners.

**Q: How do I fix scheme not found errors?**

1. **Check if you have a Swift Package:**
```yaml
- name: List Package Schemes
  run: |
    echo "Package targets:"
    swift package describe --type json | jq -r '.targets[].name'
    echo "SPM schemes follow pattern: PackageName-Package"
```

2. **Check if you have an Xcode project:**
```yaml  
- name: List Xcode Schemes
  run: xcodebuild -list | grep -A 10 "Schemes:"
```

3. **Use correct naming conventions:**
- **Swift Packages**: `MyPackage-Package` (note the `-Package` suffix)
- **Xcode Projects**: Use exact scheme name from `xcodebuild -list`

**Q: What Xcode path format should I use?**

✅ **Correct format:** `/Applications/Xcode_15.1.app`

❌ **Common mistakes:**
- `Xcode_15.1.app` (missing `/Applications/`)
- `/Applications/Xcode.app` (missing version)
- `~/Applications/Xcode_15.1.app` (using `~`)

**Q: How do I fix working directory errors?**

1. **Validate the directory exists:**
```yaml
- name: Check Directory Structure
  run: |
    ls -la "${{ inputs.working-directory || '.' }}"
    test -f "${{ inputs.working-directory || '.' }}/Package.swift" && echo "✅ Package.swift found"
```

2. **Use correct path format:**
```yaml
working-directory: ./MyPackage    # ✅ Relative with ./
working-directory: packages/core  # ✅ Relative without ./
working-directory: .              # ✅ Current directory
```

#### 🔗 Simulator & Connection Issues

**Q: How do I fix simulator connection issues?**

**Quick fix - Use defaults** (recommended):
```yaml
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyApp
    type: ios
    # Omit deviceName/osVersion for reliable defaults
```

**Advanced fix - Pre-start simulator:**
```yaml
- name: Pre-start Simulator
  run: xcrun instruments -w "iPhone 15 (17.0)" || true

- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyApp
    type: ios
    deviceName: iPhone 15
    osVersion: '17.0'
```

**Q: How do I fix "Platform not available" errors?**

**Enable automatic platform downloads:**
```yaml
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyApp
    type: ios
    deviceName: iPhone 16 Pro
    osVersion: '18.5'
    download-platform: true  # ✅ Auto-downloads missing platforms
```

**Q: How do I clean up simulator issues?**

```yaml
- name: Clean Simulator State
  run: |
    xcrun simctl shutdown all           # Stop all simulators
    xcrun simctl delete unavailable     # Remove broken simulators
    xcrun simctl list devices           # List clean state
```

---

### 🆘 Community Support

#### 📞 Getting Help

- **🐛 Bug Reports:** [GitHub Issues](https://github.com/brightdigit/swift-build/issues/new)
- **💬 Discussion:** [GitHub Discussions](https://github.com/brightdigit/swift-build/discussions)
- **📖 Documentation:** [README.md](https://github.com/brightdigit/swift-build#readme)
- **🔄 Examples:** [Real-world usage examples](#-real-world-examples)

#### 🤝 Community Guidelines

- **Search first:** Check existing issues and discussions before posting
- **Use templates:** Follow issue templates for faster resolution
- **Be specific:** Include error messages, configuration, and environment details
- **Share solutions:** Help others by sharing what worked for you

#### 📝 Contributing

We welcome contributions! See our [Contributing Guidelines](#contributing-to-swift-build) for:
- How to submit bug fixes
- Feature request process  
- Code style guidelines
- Testing requirements

---

### 🐛 Reporting Issues

#### 🔍 Before Reporting

1. **Search existing issues:** Check if your problem is already reported
2. **Try diagnostic commands:** Run platform-specific diagnostics from this FAQ
3. **Test with defaults:** Try omitting optional parameters
4. **Isolate the issue:** Remove optional parameters to identify root cause

#### 📋 Issue Template

**Use this template when creating issues:**

```markdown
## Problem Description
Brief description of the issue

## Environment
- Runner OS: [ubuntu-latest/macos-14/macos-15]
- Xcode Version: [15.1/16.4/etc]
- Swift Version: [5.9/6.0/etc]

## Configuration
```yaml
- uses: brightdigit/swift-build@v1.3.5
  with:
    # Your exact configuration here
```

## Error Output
```
Full error message and relevant logs here
```

## Expected Behavior
What you expected to happen

## Reproduction
Steps to reproduce the issue or link to failing workflow run
```

#### 🚀 Quick Self-Diagnosis

Before reporting, check:

| Problem | Check This First |
|---------|------------------|
| Device not found | Use [validated combinations](#q-what-devicenameosversion-combinations-are-valid-for-ios) |
| Scheme not found | Check [scheme naming rules](#q-how-do-i-fix-scheme-not-found-errors) |
| Platform missing | Enable [download-platform](#q-how-do-i-fix-platform-not-available-errors) |
| Xcode errors | Verify [Xcode path format](#q-what-xcode-path-format-should-i-use) |
| Configuration errors | Review [parameter rules](#q-what-are-the-parameter-validation-rules) |

#### 📎 Useful Diagnostic Commands

Include output from these commands in your issue:

**For Ubuntu/Linux runners:**
```yaml
# Swift and package info
- run: swift --version
- run: swift package describe
- run: ls -la Package.swift

# System information
- run: cat /etc/os-release
- run: df -h
```

**For macOS runners with simulator issues:**
```yaml
# Platform availability
- run: xcrun simctl list devices available
- run: xcodebuild -showsdks

# System information
- run: xcodebuild -version
- run: sw_vers
```

**For macOS runners with package issues:**
```yaml
# Swift and package info
- run: swift --version
- run: swift package describe
- run: xcodebuild -list

# System information
- run: xcodebuild -version
- run: sw_vers
```


## 🔧 Advanced Configuration Examples

### Custom Xcode Version Management
```yaml
name: Multi-Xcode Testing
on: [push, pull_request]

jobs:
  test-xcode-versions:
    strategy:
      matrix:
        include:
          # Production Xcode versions
          - xcode: /Applications/Xcode_15.1.app
            runner: macos-14
            swift: '5.9'
            stability: stable
          - xcode: /Applications/Xcode_15.4.app
            runner: macos-14
            swift: '5.10'
            stability: stable
          - xcode: /Applications/Xcode_16.4.app
            runner: macos-15
            swift: '6.0'
            stability: stable
          
          # Beta/RC Xcode versions
          - xcode: /Applications/Xcode_16.5_RC.app
            runner: macos-15
            swift: '6.1-rc'
            stability: experimental
          - xcode: /Applications/Xcode_26_beta.app
            runner: macos-15
            swift: '6.2-beta'
            stability: experimental

    runs-on: ${{ matrix.runner }}
    continue-on-error: ${{ matrix.stability == 'experimental' }}
    
    steps:
      - uses: actions/checkout@v4
      - name: Display Xcode and Swift Version
        run: |
          xcode-select -p
          swift --version
        env:
          DEVELOPER_DIR: ${{ matrix.xcode }}/Contents/Developer
          
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyPackage
          xcode: ${{ matrix.xcode }}
```

### Working Directory Configurations
```yaml
name: Monorepo Package Testing
on: [push, pull_request]

jobs:
  test-monorepo:
    strategy:
      matrix:
        package:
          - { path: 'packages/core', scheme: 'CorePackage' }
          - { path: 'packages/networking', scheme: 'NetworkingKit' }
          - { path: 'packages/ui', scheme: 'UIComponents' }
          - { path: 'apps/ios', scheme: 'MyiOSApp' }
          - { path: 'shared/utilities', scheme: 'SharedUtilities-Package' }

    runs-on: ubuntu-latest
    container: swift:6.1
    
    steps:
      - uses: actions/checkout@v4
      - name: Verify Package Structure
        run: |
          echo "Testing package at: ${{ matrix.package.path }}"
          ls -la ${{ matrix.package.path }}/
          cat ${{ matrix.package.path }}/Package.swift
          
      - uses: brightdigit/swift-build@v1.3.5
        with:
          working-directory: ${{ matrix.package.path }}
          scheme: ${{ matrix.package.scheme }}
```

### Platform Auto-Download for Beta Testing
```yaml
name: Beta Platform Testing
on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM UTC
  workflow_dispatch:     # Allow manual triggers

jobs:
  test-beta-platforms:
    strategy:
      fail-fast: false  # Continue testing other platforms if one fails
      matrix:
        include:
          # iOS beta platform testing
          - type: ios
            deviceName: iPhone 16 Pro
            osVersion: '26.0'
            xcode: /Applications/Xcode_26_beta.app
            platform: iOS
          
          # watchOS beta platform testing
          - type: watchos
            deviceName: Apple Watch Ultra 2 (49mm)
            osVersion: '26.0'
            xcode: /Applications/Xcode_26_beta.app
            platform: watchOS
          
          # tvOS beta platform testing
          - type: tvos
            deviceName: Apple TV 4K (3rd generation)
            osVersion: '26.0'
            xcode: /Applications/Xcode_26_beta.app
            platform: tvOS
          
          # visionOS beta platform testing
          - type: visionos
            deviceName: Apple Vision Pro
            osVersion: '3.0'
            xcode: /Applications/Xcode_26_beta.app
            platform: visionOS

    runs-on: macos-15
    timeout-minutes: 45  # Allow time for platform downloads
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Check Platform Availability
        run: |
          echo "Checking availability of ${{ matrix.platform }} platform..."
          xcodebuild -showsdks | grep ${{ matrix.platform }} || echo "Platform may need download"
        env:
          DEVELOPER_DIR: ${{ matrix.xcode }}/Contents/Developer
          
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyApp
          type: ${{ matrix.type }}
          xcode: ${{ matrix.xcode }}
          deviceName: ${{ matrix.deviceName }}
          osVersion: ${{ matrix.osVersion }}
          download-platform: true  # Automatically download missing platforms
```

### Complex Parameter Combinations
```yaml
name: Complex Configuration Testing
on: [push, pull_request]

jobs:
  test-complex-configs:
    strategy:
      matrix:
        include:
          # Nested package with custom Xcode
          - working-directory: ./MyFramework/Sources
            scheme: MyFramework
            type: ios
            xcode: /Applications/Xcode_16.4.app
            deviceName: iPhone 16 Pro
            osVersion: '18.5'
            description: "Nested iOS framework"
          
          # Custom working directory with macOS testing
          - working-directory: ./MyMacApp
            scheme: MyMacApp
            type: macos
            xcode: /Applications/Xcode_16.4.app
            description: "Custom directory macOS app"
          
          # Multi-target package with platform download
          - working-directory: ./ComplexPackage
            scheme: ComplexPackage-Package
            type: visionos
            xcode: /Applications/Xcode_26_beta.app
            deviceName: Apple Vision Pro
            osVersion: '3.0'
            download-platform: true
            description: "Beta visionOS with auto-download"

    runs-on: macos-15
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Validate Configuration
        run: |
          echo "Testing: ${{ matrix.description }}"
          echo "Working directory: ${{ matrix.working-directory }}"
          echo "Scheme: ${{ matrix.scheme }}"
          echo "Platform: ${{ matrix.type }}"
          ls -la ${{ matrix.working-directory }}/
          
      - uses: brightdigit/swift-build@v1.3.5
        with:
          working-directory: ${{ matrix.working-directory }}
          scheme: ${{ matrix.scheme }}
          type: ${{ matrix.type }}
          xcode: ${{ matrix.xcode }}
          deviceName: ${{ matrix.deviceName }}
          osVersion: ${{ matrix.osVersion }}
          download-platform: ${{ matrix.download-platform || 'false' }}
```

### Environment Variable Overrides
```yaml
name: Environment Override Testing
on: [push, pull_request]

jobs:
  test-env-overrides:
    runs-on: macos-15
    
    steps:
      - uses: actions/checkout@v4
      
      # Custom derived data location
      - name: Setup Custom Build Paths
        run: |
          mkdir -p /tmp/custom-derived-data
          echo "CUSTOM_DERIVED_DATA=/tmp/custom-derived-data" >> $GITHUB_ENV
          
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyPackage
          type: ios
          xcode: /Applications/Xcode_16.4.app
          deviceName: iPhone 16 Pro
          osVersion: '18.5'
        env:
          # Override default derived data path
          DERIVED_DATA_PATH: ${{ env.CUSTOM_DERIVED_DATA }}
          # Enable deterministic builds
          SWIFT_DETERMINISTIC_HASHING: 1
          # Increase build verbosity
          XCODE_XCCONFIG_FILE: ./build-configs/debug.xcconfig
```

## ⚡ Performance Optimization Examples

### Build Time Comparison: Before & After
```yaml
name: Performance Comparison
on: [push, pull_request]

jobs:
  # Without swift-build (manual setup) - ~8-12 minutes
  test-manual:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Manual Swift Setup
        run: |
          # Manual Xcode configuration (2-3 minutes)
          sudo xcode-select -s /Applications/Xcode_16.4.app/Contents/Developer
          xcodebuild -downloadPlatform iOS  # 5-8 minutes on fresh runner
      - name: Manual Build and Test
        run: |
          # Manual build commands (3-5 minutes without caching)
          xcodebuild clean build test -scheme MyApp -sdk iphonesimulator
          
  # With swift-build - ~2-3 minutes (with cache), ~4-5 minutes (without cache)
  test-optimized:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyApp
          type: ios
          deviceName: iPhone 16 Pro
          osVersion: '18.5'
          download-platform: true  # Handled efficiently by action
```

### Cache Strategy Optimization
```yaml
name: Optimized Caching Strategy
on: [push, pull_request]

jobs:
  test-cache-optimization:
    strategy:
      matrix:
        include:
          # Ubuntu: Optimized SPM caching
          - os: ubuntu-latest
            container: swift:6.1
            cache-strategy: "spm-ubuntu"
            expected-reduction: "65-80%"
          
          # macOS SPM: Cross-platform package caching
          - os: macos-latest
            cache-strategy: "spm-macos"
            expected-reduction: "60-75%"
          
          # macOS Xcode: Derived data caching
          - os: macos-latest
            type: ios
            deviceName: iPhone 16 Pro
            osVersion: '18.5'
            cache-strategy: "xcode-deriveddata"
            expected-reduction: "70-85%"

    runs-on: ${{ matrix.os }}
    container: ${{ matrix.container }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Cache Performance Info
        run: |
          echo "Cache strategy: ${{ matrix.cache-strategy }}"
          echo "Expected build time reduction: ${{ matrix.expected-reduction }}"
          
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyPackage
          type: ${{ matrix.type }}
          deviceName: ${{ matrix.deviceName }}
          osVersion: ${{ matrix.osVersion }}
```

### Large Project with Optimized Parallel Testing
```yaml
name: Large Project Optimization
on: [push, pull_request]

jobs:
  # Parallel test execution for large codebases
  test-parallel:
    strategy:
      matrix:
        test-suite:
          - { scheme: UnitTests, timeout: 15 }
          - { scheme: IntegrationTests, timeout: 25 }
          - { scheme: UITests, timeout: 35 }
          - { scheme: PerformanceTests, timeout: 20 }
        platform:
          - { type: ios, device: iPhone 15, version: '17.0' }
          - { type: ios, device: iPhone 16 Pro, version: '18.5' }

    runs-on: macos-15
    timeout-minutes: ${{ matrix.test-suite.timeout }}
    
    steps:
      - uses: actions/checkout@v4
      
      # Pre-warm derived data cache
      - name: Cache Build Artifacts
        uses: actions/cache@v4
        with:
          path: |
            ~/Library/Developer/Xcode/DerivedData
            ~/.swiftpm/cache
          key: xcode-${{ runner.os }}-${{ hashFiles('**/Package.resolved') }}-${{ github.sha }}
          restore-keys: |
            xcode-${{ runner.os }}-${{ hashFiles('**/Package.resolved') }}-
            xcode-${{ runner.os }}-
            
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: ${{ matrix.test-suite.scheme }}
          type: ${{ matrix.platform.type }}
          deviceName: ${{ matrix.platform.device }}
          osVersion: ${{ matrix.platform.version }}
        env:
          # Performance optimizations
          SWIFT_DETERMINISTIC_HASHING: 1
          XCODE_XCCONFIG_FILE: ./configs/performance.xcconfig
```

### Memory and Build Time Optimization
```yaml
name: Resource-Optimized Building
on: [push, pull_request]

jobs:
  test-resource-optimized:
    runs-on: macos-latest
    
    steps:
      - uses: actions/checkout@v4
      
      # Monitor resource usage
      - name: Pre-Build System Info
        run: |
          echo "Available disk space:"
          df -h
          echo "Memory usage:"
          vm_stat
          
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyLargeProject
          type: ios
          deviceName: iPhone 16 Pro
          osVersion: '18.5'
        env:
          # Optimize for memory usage
          SWIFT_EXEC: /usr/bin/swift
          # Reduce parallel compilation for memory-constrained environments
          SWIFT_BUILD_JOBS: 2
          # Enable build timing
          XCODE_ENABLE_BUILD_TIMING: YES
          
      # Post-build analysis
      - name: Post-Build Performance Analysis
        run: |
          echo "Final disk usage:"
          df -h
          echo "Derived data size:"
          du -sh ~/Library/Developer/Xcode/DerivedData/ || echo "No derived data found"
```

### Incremental Build Optimization
```yaml
name: Incremental Build Testing
on: [push, pull_request]

jobs:
  test-incremental:
    runs-on: macos-latest
    
    steps:
      - uses: actions/checkout@v4
      
      # First build (full compilation)
      - name: Initial Build
        uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyPackage
        env:
          BUILD_PHASE: initial
          
      # Simulate code change
      - name: Make Incremental Change
        run: |
          echo "// Performance test change $(date)" >> Sources/MyPackage/MyPackage.swift
          
      # Second build (should be much faster due to caching)
      - name: Incremental Build
        uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyPackage
        env:
          BUILD_PHASE: incremental
          
      # Performance comparison
      - name: Compare Build Times
        run: |
          echo "Incremental builds should show significant time reduction"
          echo "Typical reduction: 80-90% for small changes"
```

## 🔗 Related Actions & Caching Strategies

### Commonly Used Actions in Swift CI/CD

| Action | Purpose | Usage with swift-build |
|--------|---------|------------------------|
| **actions/checkout@v4** | Repository checkout | Required first step in all workflows |
| **actions/upload-artifact@v4** | Build artifact storage | For storing test results, coverage reports |
| **codecov/codecov-action@v4** | Coverage reporting | Upload coverage after swift-build tests |

### Built-in Caching Strategies

swift-build automatically implements platform-specific caching:

#### Ubuntu Caching
```yaml
# Automatically cached paths:
- .build/                    # SPM build artifacts
- .swiftpm/cache/           # SPM package cache
- ~/.cache/swift-pm/        # System SPM cache
```

#### macOS Caching  
```yaml
# Automatically cached paths:
- .build/                    # SPM build artifacts
- .swiftpm/cache/           # SPM package cache
- ~/Library/Developer/Xcode/DerivedData/  # Xcode build cache
- ~/Library/Caches/org.swift.swiftpm/     # SPM system cache
```



## 🔄 Migration Guides and Workflow Templates

### Migration from swift-actions/setup-swift

#### Basic SPM Package Migration

**Before (swift-actions/setup-swift):**
```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: swift-actions/setup-swift@v1
        with:
          swift-version: '6.1'
      - name: Build and Test
        run: |
          swift build --build-tests
          swift test --enable-code-coverage
```

**After (swift-build):**
```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    container: swift:6.1  # Direct container usage for better performance
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyPackage  # Simplified configuration
```

**Benefits:** Eliminates Swift installation step, adds intelligent caching, reduces workflow complexity.

#### Multi-Platform Migration

**Before (manual matrix with swift-actions):**
```yaml
name: Cross-Platform Tests
on: [push, pull_request]

jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
        swift: ['5.9', '6.0', '6.1']
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: swift-actions/setup-swift@v1
        with:
          swift-version: ${{ matrix.swift }}
      - name: Build and Test
        run: |
          swift build --build-tests
          swift test --enable-code-coverage
```

**After (swift-build with optimized matrix):**
```yaml
name: Cross-Platform Tests
on: [push, pull_request]

jobs:
  test:
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            container: swift:5.9-jammy
          - os: ubuntu-latest
            container: swift:6.1-noble
          - os: macos-14
            xcode: /Applications/Xcode_15.1.app
          - os: macos-15
            xcode: /Applications/Xcode_16.4.app
    runs-on: ${{ matrix.os }}
    container: ${{ matrix.container }}
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyPackage
          xcode: ${{ matrix.xcode }}
```

**Benefits:** Platform-specific optimization, better caching, explicit Xcode version control.

### Migration from Manual xcodebuild Commands

#### iOS App Testing Migration

**Before (manual xcodebuild):**
```yaml
name: iOS Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Xcode
        run: |
          sudo xcode-select -s /Applications/Xcode_16.4.app/Contents/Developer
          xcodebuild -downloadPlatform iOS
      - name: List Simulators
        run: xcrun simctl list devices available
      - name: Build and Test
        run: |
          xcodebuild clean build test \
            -scheme MyApp \
            -sdk iphonesimulator \
            -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5' \
            -enableCodeCoverage YES \
            -derivedDataPath ./DerivedData
```

**After (swift-build):**
```yaml
name: iOS Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyApp
          type: ios
          xcode: /Applications/Xcode_16.4.app
          deviceName: iPhone 16 Pro
          osVersion: '18.5'
```

**Benefits:** Eliminates 30+ lines of setup code, automatic platform downloads, optimized caching.

#### Multi-Platform App Migration

**Before (complex manual setup):**
```yaml
name: Multi-Platform App Tests
on: [push, pull_request]

jobs:
  test-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup iOS
        run: |
          sudo xcode-select -s /Applications/Xcode_16.4.app/Contents/Developer
          xcodebuild -downloadPlatform iOS
      - name: Test iOS
        run: |
          xcodebuild test -scheme MyApp -sdk iphonesimulator \
            -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5'
            
  test-watchos:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup watchOS
        run: |
          sudo xcode-select -s /Applications/Xcode_16.4.app/Contents/Developer
          xcodebuild -downloadPlatform watchOS
      - name: Test watchOS
        run: |
          xcodebuild test -scheme MyApp -sdk watchsimulator \
            -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 2 (49mm),OS=11.5'
            
  test-tvos:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup tvOS
        run: |
          sudo xcode-select -s /Applications/Xcode_16.4.app/Contents/Developer
          xcodebuild -downloadPlatform tvOS
      - name: Test tvOS
        run: |
          xcodebuild test -scheme MyApp -sdk appletvsimulator \
            -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation),OS=18.5'
```

**After (swift-build matrix):**
```yaml
name: Multi-Platform App Tests
on: [push, pull_request]

jobs:
  test-apple-platforms:
    strategy:
      matrix:
        include:
          - type: ios
            deviceName: iPhone 16 Pro
            osVersion: '18.5'
          - type: watchos
            deviceName: Apple Watch Ultra 2 (49mm)
            osVersion: '11.5'
          - type: tvos
            deviceName: Apple TV 4K (3rd generation)
            osVersion: '18.5'
    
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyApp
          type: ${{ matrix.type }}
          xcode: /Applications/Xcode_16.4.app
          deviceName: ${{ matrix.deviceName }}
          osVersion: ${{ matrix.osVersion }}
          download-platform: true  # Automatic platform management
```

**Benefits:** Reduces 60+ lines to 25 lines, eliminates duplicate setup, unified platform management.

### Migration from GitHub's Basic Templates

#### From actions/starter-workflows Swift Template

**Before (GitHub's basic Swift template):**
```yaml
name: Swift

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v4
    - name: Build
      run: swift build -v
    - name: Run tests
      run: swift test -v
```

**After (swift-build enhanced):**
```yaml
name: Swift Package Tests

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  test-cross-platform:
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            container: swift:6.1
          - os: macos-latest
    runs-on: ${{ matrix.os }}
    container: ${{ matrix.container }}
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyPackage-Package
```

**Benefits:** Adds cross-platform testing, intelligent caching, proper scheme handling.

### Copy-Paste Workflow Templates

#### Template 1: Basic Swift Package
```yaml
# Copy this template for basic Swift package testing
name: Swift Package Tests
on: [push, pull_request]

jobs:
  test:
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            container: swift:6.1
          - os: macos-latest
          - os: windows-latest
            windows-swift-version: swift-6.1-release
            windows-swift-build: 6.1-RELEASE
    runs-on: ${{ matrix.os }}
    container: ${{ matrix.container }}
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: REPLACE_WITH_YOUR_PACKAGE_NAME  # e.g., MyPackage-Package (not needed for Windows)
          windows-swift-version: ${{ matrix.windows-swift-version }}
          windows-swift-build: ${{ matrix.windows-swift-build }}
```

#### Template 2: iOS/macOS App Testing
```yaml
# Copy this template for iOS/macOS app testing
name: iOS App Tests
on: [push, pull_request]

jobs:
  test:
    strategy:
      matrix:
        include:
          - type: ios
            deviceName: iPhone 15
            osVersion: '17.0'
          - type: macos
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: REPLACE_WITH_YOUR_APP_SCHEME  # e.g., MyApp
          type: ${{ matrix.type }}
          deviceName: ${{ matrix.deviceName }}
          osVersion: ${{ matrix.osVersion }}
```

#### Template 3: Complete Apple Ecosystem
```yaml
# Copy this template for full Apple platform testing
name: Apple Ecosystem Tests
on: [push, pull_request]

jobs:
  test:
    strategy:
      matrix:
        include:
          - type: ios
            deviceName: iPhone 16 Pro
            osVersion: '18.5'
          - type: watchos
            deviceName: Apple Watch Ultra 2 (49mm)
            osVersion: '11.5'
          - type: tvos
            deviceName: Apple TV 4K (3rd generation)
            osVersion: '18.5'
          - type: visionos
            deviceName: Apple Vision Pro
            osVersion: '2.5'
          - type: macos
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: REPLACE_WITH_YOUR_APP_SCHEME  # e.g., MyUniversalApp
          type: ${{ matrix.type }}
          xcode: /Applications/Xcode_16.4.app
          deviceName: ${{ matrix.deviceName }}
          osVersion: ${{ matrix.osVersion }}
```

#### Template 4: Monorepo with Multiple Packages
```yaml
# Copy this template for monorepo with multiple Swift packages
name: Monorepo Tests
on: [push, pull_request]

jobs:
  test:
    strategy:
      matrix:
        package:
          - { path: 'REPLACE_PATH_1', scheme: 'REPLACE_SCHEME_1' }  # e.g., packages/core, CorePackage
          - { path: 'REPLACE_PATH_2', scheme: 'REPLACE_SCHEME_2' }  # e.g., packages/ui, UIComponents
          - { path: 'REPLACE_PATH_3', scheme: 'REPLACE_SCHEME_3' }  # e.g., apps/ios, MyiOSApp
    runs-on: ubuntu-latest
    container: swift:6.1
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          working-directory: ${{ matrix.package.path }}
          scheme: ${{ matrix.package.scheme }}
```

#### Template 5: Windows-Only Swift Package
```yaml
# Copy this template for Windows-only Swift package testing
# Uses compnerd/gha-setup-swift internally for Swift toolchain installation
# Parameters map to: windows-swift-version → swift-version, windows-swift-build → swift-build
name: Windows Swift Package Tests
on: [push, pull_request]

jobs:
  test:
    strategy:
      matrix:
        include:
          - windows-swift-version: swift-6.0-release
            windows-swift-build: 6.0-RELEASE
            swift: '6.0'
          - windows-swift-version: swift-6.1-release
            windows-swift-build: 6.1-RELEASE
            swift: '6.1'
          - windows-swift-version: swift-6.2-branch
            windows-swift-build: 6.2-DEVELOPMENT-SNAPSHOT-2025-09-06-a
            swift: '6.2-dev'
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Display Swift Version
        run: swift --version
      - uses: brightdigit/swift-build@v1.3.5
        with:
          windows-swift-version: ${{ matrix.windows-swift-version }}
          windows-swift-build: ${{ matrix.windows-swift-build }}
```

### Step-by-Step Migration Guide

#### Step 1: Identify Your Current Setup
1. **Find your current workflow files:** `.github/workflows/*.yml`
2. **Identify build commands:** Look for `swift build`, `swift test`, or `xcodebuild` commands
3. **Note platform requirements:** Ubuntu, macOS, iOS simulators, etc.
4. **Check scheme names:** Usually found in `xcodebuild -scheme` or Package.swift

#### Step 2: Choose the Right Template
- **Basic Swift Package:** Use Template 1 above
- **iOS/macOS Apps:** Use Template 2 above  
- **Full Apple Ecosystem:** Use Template 3 above
- **Monorepo:** Use Template 4 above

#### Step 3: Replace Placeholders
1. Replace `REPLACE_WITH_YOUR_PACKAGE_NAME` with your actual package name
2. Replace `REPLACE_WITH_YOUR_APP_SCHEME` with your app scheme
3. Update working directory paths if needed
4. Adjust Swift/Xcode versions as needed

#### Step 4: Test and Validate
1. **Run locally first:** Test your scheme names with `swift package describe` or `xcodebuild -list`
2. **Start with basic configuration:** Remove optional parameters initially
3. **Add complexity gradually:** Start with SPM, then add Apple platforms
4. **Verify caching works:** Check action logs for cache hit/miss information

### Common Migration Scenarios

#### Scenario 1: Converting Complex xcodebuild Scripts

**Before (50+ lines of custom scripts):**
```yaml
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Xcode
        run: |
          sudo xcode-select -s /Applications/Xcode_16.4.app/Contents/Developer
          xcodebuild -version
          xcodebuild -showsdks
      - name: Setup iOS Simulator
        run: |
          xcrun simctl list devices
          xcrun simctl create "TestDevice" "iPhone 16 Pro" "iOS-18-5"
          xcrun simctl boot "TestDevice"
      - name: Build for iOS
        run: |
          xcodebuild clean build \
            -project MyApp.xcodeproj \
            -scheme MyApp \
            -sdk iphonesimulator \
            -arch x86_64 \
            -derivedDataPath ./DerivedData
      - name: Test on iOS
        run: |
          xcodebuild test \
            -project MyApp.xcodeproj \
            -scheme MyApp \
            -sdk iphonesimulator \
            -destination "platform=iOS Simulator,name=TestDevice" \
            -derivedDataPath ./DerivedData
```

**After (5 lines with swift-build):**
```yaml
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: brightdigit/swift-build@v1.3.5
        with:
          scheme: MyApp
          type: ios
          xcode: /Applications/Xcode_16.4.app
          deviceName: iPhone 16 Pro
          osVersion: '18.5'
```

#### Scenario 2: Migrating from Custom Caching Setup

**Before (manual cache configuration):**
```yaml
- name: Cache SPM Dependencies
  uses: actions/cache@v4
  with:
    path: |
      .build
      ~/.cache/org.swift.swiftpm
    key: spm-${{ runner.os }}-${{ hashFiles('Package.resolved') }}
    
- name: Cache Xcode DerivedData
  uses: actions/cache@v4
  with:
    path: ~/Library/Developer/Xcode/DerivedData
    key: deriveddata-${{ runner.os }}-${{ hashFiles('Package.resolved') }}
    
- name: Build and Test
  run: |
    swift build --build-tests --cache-path .cache
    swift test --enable-code-coverage --cache-path .cache
```

**After (automatic intelligent caching):**
```yaml
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyPackage  # Caching handled automatically
```

**Benefits:** Eliminates 15+ lines of cache configuration, uses optimized cache strategies.

### Common Parameter Combinations

#### Recommended Platform Combinations

| Use Case | Platform Config | When to Use |
|----------|----------------|-------------|
| **Basic Package Testing** | `scheme: MyPackage` | Cross-platform libraries, no Apple-specific features |
| **iOS App Development** | `scheme: MyApp, type: ios, deviceName: iPhone 15, osVersion: '17.0'` | iOS-specific features, UI testing |
| **Apple Watch Apps** | `scheme: MyWatchApp, type: watchos, deviceName: Apple Watch Ultra 2 (49mm), osVersion: '11.0'` | watchOS complications, health features |
| **Apple TV Apps** | `scheme: MyTVApp, type: tvos, deviceName: Apple TV 4K (3rd generation), osVersion: '18.0'` | tvOS focus management, remote interaction |
| **Vision Pro Apps** | `scheme: MyVisionApp, type: visionos, deviceName: Apple Vision Pro, osVersion: '2.0'` | Spatial computing, immersive experiences |
| **macOS Native Apps** | `scheme: MyMacApp, type: macos` | macOS-specific APIs, desktop features |

#### Parameter Validation Examples

**✅ Valid Combinations:**
```yaml
# SPM build (cross-platform)
scheme: MyPackage
# No other parameters needed

# iOS simulator testing
scheme: MyApp
type: ios
deviceName: iPhone 15
osVersion: '17.0'

# macOS native testing  
scheme: MyMacApp
type: macos
# deviceName/osVersion not needed for macOS

# Custom Xcode with platform download
scheme: MyApp
type: visionos
xcode: /Applications/Xcode_26_beta.app
deviceName: Apple Vision Pro
osVersion: '3.0'
download-platform: true
```

**❌ Invalid Combinations:**
```yaml
# Missing required deviceName/osVersion for simulators
scheme: MyApp
type: ios
# Error: deviceName and osVersion required for simulator platforms

# deviceName/osVersion without type
scheme: MyApp
deviceName: iPhone 15
osVersion: '17.0'
# Error: type parameter required when using deviceName/osVersion

# Non-existent platform
scheme: MyApp
type: androidOS  # Invalid platform type
```



### Troubleshooting Configuration Examples

#### Issue: Scheme Not Found
**Error:** `Scheme 'MyPackage' does not exist`

**Troubleshooting steps:**
```yaml
# Step 1: List available schemes
- name: Debug Schemes
  run: |
    swift package describe --type json | jq '.targets[].name'
    # For Xcode projects: xcodebuild -list

# Step 2: Use correct scheme name
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyPackage-Package  # Note the -Package suffix
```

#### Issue: Simulator Device Not Available
**Error:** `Unable to find destination matching iPhone 17`

**Before (problematic):**
```yaml
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyApp
    type: ios
    deviceName: iPhone 17  # Device doesn't exist
    osVersion: '19.0'      # Version too new
```

**After (corrected):**
```yaml
# Option 1: Use well-supported devices
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyApp
    type: ios
    deviceName: iPhone 15  # Widely available
    osVersion: '17.0'      # Stable version

# Option 2: Let swift-build choose defaults
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyApp
    type: ios
    # Omit deviceName/osVersion for automatic selection
```

#### Issue: Platform Not Available
**Error:** `The visionOS 3.0 simulator runtime is not available`

**Before (fails on missing platform):**
```yaml
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyApp
    type: visionos
    deviceName: Apple Vision Pro
    osVersion: '3.0'  # Beta version not installed
```

**After (auto-downloads platform):**
```yaml
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyApp
    type: visionos
    xcode: /Applications/Xcode_26_beta.app
    deviceName: Apple Vision Pro
    osVersion: '3.0'
    download-platform: true  # Downloads platform if missing
```

### Configuration Decision Tree

```
Is this a Swift Package or Xcode project?
├── Swift Package (Package.swift exists)
│   ├── Cross-platform library?
│   │   └── Use: scheme only, test on Ubuntu + macOS
│   └── Apple platform specific?
│       └── Use: scheme + type + deviceName/osVersion
└── Xcode Project (.xcodeproj exists)  
    ├── macOS app?
    │   └── Use: scheme + type: macos
    └── iOS/watchOS/tvOS/visionOS app?
        └── Use: scheme + type + deviceName + osVersion
```

## 🐛 Issue Reporting and Debug Guide

### Before Reporting Issues

1. **Test against our reference implementation:** Compare your configuration with the working examples in our [public test workflow](https://github.com/brightdigit/swift-build/blob/main/.github/workflows/swift-test.yml)

2. **Run diagnostic commands to gather information:**
```yaml
- name: Debug Environment Information
  run: |
    echo "=== System Information ==="
    uname -a
    sw_vers || cat /etc/os-release
    
    echo "=== Swift/Xcode Information ==="
    swift --version
    xcode-select -p || echo "No Xcode found"
    xcodebuild -version || echo "xcodebuild not available"
    
    echo "=== Package Information ==="
    cat Package.swift
    swift package describe || echo "Not a Swift package"
    
    echo "=== Available Simulators (macOS only) ==="
    xcrun simctl list devices available || echo "No simulators available"
    
    echo "=== Available SDKs (macOS only) ==="
    xcodebuild -showsdks || echo "No SDKs available"
```

### Issue Reporting Template

When reporting issues, please include:

#### Required Information

**Environment:**
- [ ] Runner OS (ubuntu-latest, macos-14, macos-15)
- [ ] Swift version (`swift --version`)
- [ ] Xcode version (if applicable, `xcodebuild -version`)
- [ ] Container image (if Ubuntu, e.g., `swift:6.1`)

**Configuration:**
- [ ] Complete swift-build step configuration (copy from your workflow)
- [ ] Working directory structure (`ls -la` output)
- [ ] Package.swift or Xcode project structure

**Error Details:**
- [ ] Complete error message and logs
- [ ] Expected vs. actual behavior
- [ ] Steps to reproduce

#### Diagnostic Commands Output

Please run and include output from these commands:

```yaml
# For all platforms
- run: swift --version
- run: swift package describe  # If Swift package
- run: ls -la  # Show directory structure

# For macOS runners only
- run: xcodebuild -version
- run: xcodebuild -showsdks
- run: xcrun simctl list devices available  # If using simulators
- run: xcode-select -p

# For Ubuntu runners only  
- run: cat /etc/os-release
- run: which swift

# For Windows runners only
- run: Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion
- run: swift --version
- run: where swift
- run: Get-ChildItem Env: | Where-Object Name -like "*SWIFT*"
```

#### Reproduction Test

**Before reporting, test your configuration against our reference:**

1. **Compare with working examples:** Check [swift-test.yml](https://github.com/brightdigit/swift-build/blob/main/.github/workflows/swift-test.yml) for similar configurations
2. **Test minimal configuration:** Try with just `scheme` parameter first
3. **Isolate the issue:** Remove optional parameters to identify the root cause

#### Quick Self-Diagnosis

| Problem | Check This First |
|---------|------------------|
| Scheme not found | Compare with Package.swift targets or `xcodebuild -list` output |
| Device not available | Run `xcrun simctl list devices available` and match exact names |
| Platform missing | Try `download-platform: true` or check Xcode version compatibility |
| Build failures | Test locally with same Swift/Xcode versions first |
| Configuration errors | Validate against parameter combination rules in README |

#### Submit Your Issue

Create a new issue at: [https://github.com/brightdigit/swift-build/issues](https://github.com/brightdigit/swift-build/issues)

**Use this template:**

```markdown
## Problem Description
Brief description of the issue

## Environment
- Runner OS: 
- Swift version: 
- Xcode version (if applicable):
- Container (if Ubuntu):

## Configuration
```yaml
- uses: brightdigit/swift-build@v1.3.5
  with:
    # Your complete configuration here
```

## Error Output
```
Full error message and relevant logs here
```

## Diagnostic Information
```
Output from diagnostic commands above
```

## Expected Behavior
What you expected to happen

## Reproduction
Steps to reproduce the issue or link to failing workflow run
```

### Performance Configuration Guidelines

#### For Small Projects (< 10 targets)
```yaml
# Simple configuration - let swift-build optimize
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MySmallPackage
```

#### For Medium Projects (10-50 targets)
```yaml
# Add explicit Xcode version for consistency
- uses: brightdigit/swift-build@v1.3.5
  with:
    scheme: MyMediumPackage
    xcode: /Applications/Xcode_16.4.app  # Consistent toolchain
```

#### For Large Projects (50+ targets)
```yaml
# Optimize for parallel testing
strategy:
  matrix:
    test-suite: [UnitTests, IntegrationTests, UITests]
    
steps:
  - uses: brightdigit/swift-build@v1.3.5
    with:
      scheme: ${{ matrix.test-suite }}
      type: ios
      deviceName: iPhone 15
      osVersion: '17.0'
    env:
      SWIFT_BUILD_JOBS: 4  # Limit parallel compilation
```
