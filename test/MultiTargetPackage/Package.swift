// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MultiTargetPackage",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "Core",
            targets: ["Core"]),
        .library(
            name: "Utils",
            targets: ["Utils"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-testing.git", from: "0.12.0"),
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: ["Utils"]),
        .target(
            name: "Utils"),
        .testTarget(
            name: "CoreTests",
            dependencies: [
                "Core",
                .product(name: "Testing", package: "swift-testing")
            ]),
        .testTarget(
            name: "UtilsTests",
            dependencies: [
                "Utils",
                .product(name: "Testing", package: "swift-testing")
            ]),
    ]
) 