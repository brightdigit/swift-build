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
    targets: [
        .target(
            name: "Core",
            dependencies: ["Utils"]),
        .target(
            name: "Utils"),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"]),
        .testTarget(
            name: "UtilsTests",
            dependencies: ["Utils"]),
    ]
) 