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
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-testing.git", from: "0.12.0"),
    ],
    targets: [
        .target(
            name: "SingleTargetPackage"),
        .testTarget(
            name: "SingleTargetPackageTests",
            dependencies: [
                "SingleTargetPackage",
                .product(name: "Testing", package: "swift-testing")
            ]),
    ]
) 