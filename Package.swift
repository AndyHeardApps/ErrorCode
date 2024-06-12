// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "ErrorCode",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "ErrorCode",
            targets: ["ErrorCode"]
        ),
        .executable(
            name: "ErrorCodeClient",
            targets: ["ErrorCodeClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .macro(
            name: "ErrorCodeMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ErrorCode",
            dependencies: ["ErrorCodeMacros"],
            swiftSettings: swiftSettings
        ),
        .executableTarget(
            name: "ErrorCodeClient",
            dependencies: ["ErrorCode"],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "ErrorCodeTests",
            dependencies: [
                "ErrorCodeMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ],
            swiftSettings: swiftSettings
        )
    ],
    swiftLanguageVersions: [.v6]
)

var swiftSettings: [SwiftSetting] { [
    .enableExperimentalFeature("StrictConcurrency"),
] }
