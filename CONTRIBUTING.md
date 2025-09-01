# Contributing to swift-build

Thank you for your interest in contributing to swift-build! This document provides guidelines for contributing to the project.

## 🚀 Quick Start

1. **Fork** the repository
2. **Clone** your fork locally
3. **Create** a feature branch
4. **Make** your changes
5. **Test** your changes
6. **Submit** a pull request

## 🐛 Reporting Issues

Before reporting an issue:

1. **Search existing issues** to avoid duplicates
2. **Check our [FAQ](https://github.com/brightdigit/swift-build#-troubleshooting--faq)** for common solutions
3. **Use appropriate issue templates** for bug reports, feature requests, or platform support

### Issue Templates

- **🐛 Bug Report:** For reporting unexpected behavior or errors
- **✨ Feature Request:** For suggesting new features or enhancements  
- **🚀 Platform Support:** For requesting new platform/version support

## 💻 Development Guidelines

### Code Style

- Follow existing patterns in `action.yml`
- Use clear, descriptive comments
- Maintain backward compatibility
- Follow GitHub Actions best practices

### Testing Requirements

All changes must be tested with:

1. **Local testing** using test packages:
   ```bash
   cd test/SingleTargetPackage
   swift build --build-tests
   swift test
   ```

2. **CI testing** across supported platforms:
   - Ubuntu (focal, jammy, noble)
   - macOS (14, 15)
   - Multiple Swift/Xcode versions

3. **Platform-specific testing** for Apple platform changes:
   ```bash
   # Test with actual simulators
   xcodebuild test -scheme MyPackage -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0'
   ```

### Pull Request Process

1. **Create descriptive PR title** following conventional commits:
   - `feat: add support for Swift 6.2`
   - `fix: resolve iOS 18 simulator connection issues`
   - `docs: update troubleshooting FAQ`

2. **Include comprehensive description:**
   - What changes were made
   - Why the changes were necessary
   - How to test the changes
   - Any breaking changes

3. **Link related issues** using keywords:
   - `Fixes #123`
   - `Closes #456`
   - `Related to #789`

## 📋 Types of Contributions

### 🔧 Bug Fixes

- Fix platform compatibility issues
- Resolve configuration validation problems
- Improve error handling and messaging

### ✨ New Features

- Add support for new Swift versions
- Add support for new Xcode versions
- Add support for new Apple platforms
- Enhance existing functionality

### 📖 Documentation

- Improve README clarity and completeness
- Add new troubleshooting entries
- Update examples and best practices
- Fix typos and formatting

### 🧪 Testing

- Add new test scenarios
- Improve CI/CD workflows
- Add platform-specific test coverage

## 🏗️ Project Structure

```
swift-build/
├── action.yml                 # Main action definition
├── .github/
│   ├── workflows/
│   │   └── swift-test.yml     # CI testing workflow
│   └── ISSUE_TEMPLATE/        # Issue templates
├── test/
│   ├── SingleTargetPackage/   # Simple test package
│   └── MultiTargetPackage/    # Complex test package
├── README.md                  # Main documentation
└── CONTRIBUTING.md           # This file
```

## 🔍 Understanding the Action

### Core Components

- **action.yml**: Defines inputs, outputs, and build logic
- **Platform detection**: Automatically chooses build tools (SPM vs Xcode)
- **Caching strategies**: Different approaches for Ubuntu vs macOS
- **Error handling**: Comprehensive validation and error reporting

### Key Parameters

- `scheme`: Required when using Xcode builds (when `type` is specified) - the scheme to build/test
- `type`: Optional - specifies Apple platform for simulator testing
- `working-directory`: Optional - supports monorepo structures (default: '.')
- `xcode`: Optional - custom Xcode version path
- `deviceName`/`osVersion`: Optional (required when using type for simulator testing; deviceName and osVersion must be provided together)
- `download-platform`: Optional - auto-download missing platforms (default: false)

## 🧪 Testing Your Changes

### Local Testing

1. **Test with sample packages:**
   ```bash
   # Single target package
   cd test/SingleTargetPackage
   swift build && swift test
   
   # Multi-target package
   cd test/MultiTargetPackage  
   swift build && swift test
   ```

2. **Test action locally** using [act](https://github.com/nektos/act):
   ```bash
   act -j test-single-target-ubuntu
   ```

### CI Testing

The CI workflow (`swift-test.yml`) automatically tests:
- Multiple Ubuntu versions with Swift 5.9-6.2
- Multiple macOS versions with Xcode 15.1-16.4
- Platform-specific simulator testing
- Both test packages

## 🎯 Contribution Ideas

### High Priority

- **Platform support**: New Swift versions, Xcode versions, Apple platforms
- **Error handling**: Better error messages and diagnostics
- **Performance**: Optimization for large projects
- **Documentation**: More real-world examples

### Medium Priority  

- **Caching improvements**: Better cache strategies
- **Monorepo support**: Enhanced multi-package workflows
- **Testing**: Additional test scenarios and edge cases

### Low Priority

- **Code cleanup**: Refactoring and optimization
- **Automation**: Enhanced CI/CD workflows

## 📞 Getting Help

- **Questions:** Use [GitHub Discussions](https://github.com/brightdigit/swift-build/discussions)
- **Real-time chat:** Check if there's a community Slack/Discord
- **Documentation:** Consult the [README](https://github.com/brightdigit/swift-build#readme)

## 📜 License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

**Thank you for contributing to swift-build!** 🎉