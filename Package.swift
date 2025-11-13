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
    dependencies: [],
    targets: [
        .target(
            name: "Docc2contextCore",
            dependencies: []
        ),
        .executableTarget(
            name: "docc2context",
            dependencies: ["Docc2contextCore"]
        ),
        .testTarget(
            name: "Docc2contextCoreTests",
            dependencies: ["Docc2contextCore"]
        )
    ]
)
