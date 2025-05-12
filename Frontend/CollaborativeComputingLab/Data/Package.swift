// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Data",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Data",
            targets: ["Data"]),
    ],
    dependencies: [
        .package(name: "Domain", path: "/../Domain"),
        .package(url: "https://github.com/Romixery/SwiftStomp.git", from: "1.0.4"),
        .package(url: "https://github.com/HaishinKit/HaishinKit.swift.git", from: "2.0.8")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Data",
            dependencies: [
                "Domain",
                "SwiftStomp",
                .product(name: "HaishinKit", package: "HaishinKit.swift")
            ],
            resources: [.process("Secret.plist")]
        ),
    ]
)
