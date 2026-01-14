// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "MixedFrameworkPackage",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(name: "Calculator", targets: ["Calculator"]),
        .library(name: "Validator", targets: ["Validator"]),
        .library(name: "Utils", targets: ["Utils"]),
    ],
    targets: [
        // Library targets
        .target(name: "Calculator"),
        .target(name: "Validator", dependencies: ["Utils"]),
        .target(name: "Utils"),

        // Swift Testing test targets
        .testTarget(
            name: "CalculatorSwiftTestingTests",
            dependencies: ["Calculator"]
        ),
        .testTarget(
            name: "ValidatorSwiftTestingTests",
            dependencies: ["Validator"]
        ),

        // XCTest test targets
        .testTarget(
            name: "CalculatorXCTests",
            dependencies: ["Calculator"]
        ),
        .testTarget(
            name: "UtilsXCTests",
            dependencies: ["Utils"]
        ),
    ]
)
