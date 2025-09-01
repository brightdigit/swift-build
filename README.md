# Swift Build & Test Action

[![CI](https://github.com/swift-build/swift-build/workflows/CI/badge.svg)](https://github.com/swift-build/swift-build/actions)
[![GitHub release](https://img.shields.io/github/release/swift-build/swift-build.svg)](https://github.com/swift-build/swift-build/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**A comprehensive GitHub Action for building and testing Swift packages across all platforms with intelligent caching and zero-config setup.**

## ✨ Why Choose This Action?

🚀 **Zero Configuration** - Works out of the box with just a scheme parameter  
⚡ **Intelligent Caching** - Platform-specific caching strategies for maximum performance  
🌍 **Complete Platform Coverage** - Ubuntu (Swift 5.9-6.2) + macOS (iOS, watchOS, tvOS, visionOS, macOS)  
🎯 **Optimized Workflows** - Purpose-built for modern Swift CI/CD pipelines  
📦 **Real-World Proven** - Used by 25+ open source Swift packages including SyndiKit, DataThespian, and more  

## 🚀 Quick Start

### Basic Swift Package Testing

```yaml
name: Test Swift Package
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    container: swift:6.1
    steps:
      - uses: actions/checkout@v4
      - uses: swift-build/swift-build@v1.2.0
        with:
          scheme: YourPackageTests
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
      - uses: swift-build/swift-build@v1.2.0
        with:
          scheme: YourApp
          type: ios
          deviceName: iPhone 15
          osVersion: '17.0'
```

### Multi-Platform Matrix

```yaml
name: Cross-Platform Testing
on: [push, pull_request]

jobs:
  test:
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            container: swift:6.1
            scheme: YourPackageTests
          - os: macos-latest
            scheme: YourPackageTests
          - os: macos-latest
            scheme: YourApp
            type: ios
            deviceName: iPhone 15
            osVersion: '17.0'
    runs-on: ${{ matrix.os }}
    container: ${{ matrix.container }}
    steps:
      - uses: actions/checkout@v4
      - uses: swift-build/swift-build@v1.2.0
        with:
          scheme: ${{ matrix.scheme }}
          type: ${{ matrix.type }}
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
      - uses: swift-build/swift-build@v1.2.0
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
      - uses: swift-build/swift-build@v1.2.0
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
      - uses: swift-build/swift-build@v1.2.0
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

## 🌍 Platform Support

swift-build works seamlessly across all major platforms with zero configuration required.

### Supported Platforms

| Platform | Build Tool | What swift-build Provides |
|----------|------------|---------------------------|
| **Ubuntu Linux** | Swift Package Manager | Automatic dependency caching, optimized build paths |
| **macOS** | Swift Package Manager | Xcode integration, intelligent DerivedData management |
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
| **macos-14** | Stable Xcode versions (15.x) | iOS/watchOS/tvOS simulators, Xcode 15 support |
| **macos-15** | Latest Xcode versions (16.x+) | visionOS support, Xcode 16+ beta features |

### Platform-Specific Features

- **🔍 Auto-Detection**: Automatically detects runner OS and configures appropriate build tools
- **📦 Smart Caching**: Platform-specific caching strategies (`.build` + `.swiftpm` on Linux, DerivedData on macOS)
- **📲 Simulator Management**: Automatic iOS/watchOS/tvOS/visionOS simulator setup and device selection
- **⬇️ Platform Downloads**: Automatically downloads missing Apple platform simulators for beta/nightly Xcode
- **🛠️ Build Tool Selection**: Uses `swift` command on Linux/macOS SPM, `xcodebuild` for Apple platforms

### External Resources

- **GitHub Runner Images**: [github.com/actions/runner-images](https://github.com/actions/runner-images)
- **macOS Runner Documentation**: [GitHub Hosted Runners](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners/about-github-hosted-runners#supported-runners-and-hardware-resources)
- **Swift Docker Hub**: [Official Swift Images](https://hub.docker.com/_/swift)

## ⚙️ Configuration Reference

### Required Parameters

| Parameter | Description | Example | Notes |
|-----------|-------------|---------|-------|
| `scheme` | The scheme to build and test | `MyPackage-Package` | Required for `xcodebuild` (Apple platforms). Not required when using `swift` command (SPM) |

### Optional Parameters

#### Basic Configuration

| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `working-directory` | Directory containing the Swift package | `.` | `./MyPackage` |

#### Apple Platform Configuration

| Parameter | Description | Default | Example | Valid Values |
|-----------|-------------|---------|---------|--------------|
| `type` | Build type for Apple platforms | `null` | `ios` | `ios`, `watchos`, `visionos`, `tvos`, `macos` |
| `xcode` | Xcode version path for Apple platforms | System default | `/Applications/Xcode_15.4.app` | Any Xcode.app path |
| `deviceName` | Simulator device name | `null` | `iPhone 15` | Any available simulator |
| `osVersion` | Simulator OS version | `null` | `17.5` | Compatible OS version |
| `download-platform` | Download platform if not available | `false` | `true` | `true`, `false` |

### Configuration Examples by Use Case

#### Swift Package Manager (Ubuntu/macOS)
```yaml
- uses: swift-build/swift-build@v1.2.0
  with:
    scheme: MyPackageTests
    working-directory: ./packages/core
```

#### iOS Simulator Testing
```yaml
- uses: swift-build/swift-build@v1.2.0
  with:
    scheme: MyApp
    type: ios
    deviceName: iPhone 15 Pro
    osVersion: '17.5'
```

#### macOS Native Testing
```yaml
- uses: swift-build/swift-build@v1.2.0
  with:
    scheme: MyApp
    type: macos
```

#### Custom Xcode Version
```yaml
- uses: swift-build/swift-build@v1.2.0
  with:
    scheme: MyApp
    type: ios
    xcode: /Applications/Xcode_16.4.app
    deviceName: iPhone 16 Pro
    osVersion: '18.5'
```

#### Beta Platform Support
```yaml
- uses: swift-build/swift-build@v1.2.0
  with:
    scheme: MyApp
    type: visionos
    xcode: /Applications/Xcode_26_beta.app
    deviceName: Apple Vision Pro
    osVersion: '26.0'
    download-platform: true
```

### Parameter Combinations & Interactions

- **Ubuntu builds**: Only `scheme` and `working-directory` are used
- **macOS SPM builds**: `scheme`, `working-directory` (no `type` specified)
- **Apple platform builds**: Require `scheme`, `type`, and optionally `deviceName`/`osVersion`
- **Custom Xcode**: When `xcode` is specified, it overrides system default
- **Platform download**: Only effective with beta/nightly Xcode versions

### Default Behaviors

- **No `type`**: Uses Swift Package Manager directly with `swift` command (works on Ubuntu and macOS)
- **No `deviceName`/`osVersion`**: Uses Xcode's default simulator for the platform
- **No `xcode`**: Uses system default Xcode installation
- **No `working-directory`**: Operates in repository root

### Build Tool Selection

- **Swift Package Manager**: Uses `swift build` and `swift test` commands (Ubuntu and macOS SPM builds)
- **Xcode Build System**: Uses `xcodebuild` command when `type` is specified (iOS, watchOS, tvOS, visionOS, macOS)

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
      - uses: swift-build/swift-build@v1.2.0
        with:
          scheme: MyPackage
          type: ${{ matrix.type }}
          xcode: ${{ matrix.xcode }}
          deviceName: ${{ matrix.device }}
          osVersion: ${{ matrix.version }}
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
      - uses: swift-build/swift-build@v1.2.0
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
      - uses: swift-build/swift-build@v1.2.0
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
          
      - uses: swift-build/swift-build@v1.2.0
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
      - uses: swift-build/swift-build@v1.2.0
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
      - uses: swift-build/swift-build@v1.2.0
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
          
      - uses: swift-build/swift-build@v1.2.0
        with:
          scheme: MyPackage
          xcode: ${{ matrix.xcode }}
```

## 🔧 Troubleshooting

### Common Issues

#### ❌ Missing SDK Platform

**Error:** Platform not available for testing
```
The iOS 18.5 simulator runtime is not available.
```

**Solution:** Use `download-platform: true` to automatically download missing platforms
```yaml
- uses: swift-build/swift-build@v1.2.0
  with:
    scheme: MyApp
    type: ios
    deviceName: iPhone 16 Pro
    osVersion: '18.5'
    download-platform: true  # Downloads platform if missing
```

**Reference:** [MistKit Issue Example](https://github.com/brightdigit/MistKit/actions/runs/17333339225/job/49214277993)

---

#### ❌ Unable to Connect to Simulator

**Error:** Simulator connection failures
```
Unable to connect to destination iPhone 15
xcodebuild: error: Unable to find a destination matching the provided destination specifier
```

**Solutions:**

1. **Use default simulator settings** (Recommended)
```yaml
- uses: swift-build/swift-build@v1.2.0
  with:
    scheme: MyApp
    type: ios
    # Omit deviceName/osVersion for reliable defaults
```

2. **Pre-start the simulator**
```yaml
- name: Pre-start Simulator
  run: xcrun instruments -w "iPhone 15 (17.0)" || true
  
- uses: swift-build/swift-build@v1.2.0
  with:
    scheme: MyApp
    type: ios
    deviceName: iPhone 15
    osVersion: '17.0'
```

3. **List and verify available simulators**
```yaml
- name: List Available Simulators
  run: xcrun simctl list devices available
  
- uses: swift-build/swift-build@v1.2.0
  with:
    scheme: MyApp
    type: ios
    deviceName: iPhone 15  # Verify this matches output above
    osVersion: '17.0'
```

4. **Use well-supported device combinations**
```yaml
- uses: swift-build/swift-build@v1.2.0
  with:
    scheme: MyApp
    type: ios
    deviceName: iPhone 15
    osVersion: '17.0'  # Stable, widely supported version
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



### Migration Effort

#### From swift-actions/setup-swift

**Before:**
```yaml
- uses: swift-actions/setup-swift@v1
  with:
    swift-version: '5.9'
- name: Build and Test
  run: |
    swift build
    swift test
```

**After:**
```yaml
- uses: swift-build/swift-build@v1.2.0
  container: swift:5.9
  with:
    scheme: MyPackageTests
```

**Migration time:** < 5 minutes per workflow

#### From Manual Setup

**Before:**
```yaml
- name: Install Swift
  run: |
    # 20+ lines of manual Swift installation
    
- name: Setup Xcode
  run: |
    # 10+ lines of Xcode configuration
    
- name: Configure Simulator
  run: |
    # 15+ lines of simulator setup
    
- name: Build and Test
  run: |
    # Custom build commands
```

**After:**
```yaml
- uses: swift-build/swift-build@v1.2.0
  with:
    scheme: MyApp
    type: ios
    deviceName: iPhone 15
    osVersion: '17.0'
```
