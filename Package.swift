// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "docc2context",
    platforms: [
        .macOS(.v13),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Docc2contextCore",
            targets: ["Docc2contextCore"]
        ),
        .executable(
            name: "docc2context",
            targets: ["docc2context"]
        ),
        .executable(
            name: "repository-validation",
            targets: ["repository-validation"]
        ),
        .executable(
            name: "docc2context-benchmark",
            targets: ["docc2context-benchmark"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-crypto", from: "3.8.0")
    ],
    targets: [
        .target(
            name: "Docc2contextCore",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Crypto", package: "swift-crypto")
            ]
        ),
        .executableTarget(
            name: "docc2context",
            dependencies: [
                "Docc2contextCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .executableTarget(
            name: "repository-validation",
            dependencies: [
                "Docc2contextCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .executableTarget(
            name: "docc2context-benchmark",
            dependencies: [
                "Docc2contextCore"
            ]
        ),
        .testTarget(
            name: "Docc2contextCoreTests",
            dependencies: ["Docc2contextCore"]
        )
    ]
)
