// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SingleTargetPackage",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "SingleTargetPackage",
            targets: ["SingleTargetPackage"]),
    ],
    targets: [
        .target(
            name: "SingleTargetPackage"),
        .testTarget(
            name: "SingleTargetPackageTests",
            dependencies: ["SingleTargetPackage"]),
    ]
) 