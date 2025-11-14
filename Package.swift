// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "docc2context",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Docc2contextCore",
            targets: ["Docc2contextCore"]
        ),
        .executable(
            name: "docc2context",
            targets: ["docc2context"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "Docc2contextCore",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .executableTarget(
            name: "docc2context",
            dependencies: [
                "Docc2contextCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "Docc2contextCoreTests",
            dependencies: ["Docc2contextCore"]
        )
    ]
)
