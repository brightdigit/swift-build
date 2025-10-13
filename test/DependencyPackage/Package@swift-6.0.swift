// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DependencyPackage",
    products: [
        .library(
            name: "DependencyPackage",
            targets: ["DependencyPackage"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "DependencyPackage",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms")
            ]),
        .testTarget(
            name: "DependencyPackageTests",
            dependencies: ["DependencyPackage"])
    ]
)
