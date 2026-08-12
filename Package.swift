// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MathParser",
    platforms: [
        .macOS(.v14), .iOS(.v17), .watchOS(.v10), .tvOS(.v17), .visionOS(.v1)
    ],
    products: [
        .library(name: "MathParser", targets: ["MathParser"]),
    ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "MathParser", dependencies: []),
        .testTarget(name: "MathParserTests", dependencies: ["MathParser"]),
    ]
)
