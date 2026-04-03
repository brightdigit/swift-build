// swift-tools-version: 5.7
import PackageDescription

// This package exists to test Windows cache symlink handling (issue #90).
// swift-docc-plugin contains a "Symbolic Links" directory in its source tree.
// On Windows, git checks these out as NTFS symlinks, which tar serializes as
// plain-text stubs when saving the actions/cache. The fix in action.yml converts
// those symlinks to real directories before the cache post-job save runs.
let package = Package(
    name: "SymlinkDependencyPackage",
    products: [
        .library(name: "SymlinkDependencyPackage", targets: ["SymlinkDependencyPackage"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.6")
    ],
    targets: [
        .target(name: "SymlinkDependencyPackage"),
        .testTarget(
            name: "SymlinkDependencyPackageTests",
            dependencies: ["SymlinkDependencyPackage"]
        )
    ]
)
