// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "docc2context",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "docc2context", targets: ["docc2context"]),
        .library(name: "docc2contextCore", targets: ["docc2contextCore"])
    ],
    targets: [
        .executableTarget(
            name: "docc2context",
            dependencies: ["docc2contextCore"]
        ),
        .target(
            name: "docc2contextCore"
        ),
        .testTarget(
            name: "docc2contextTests",
            dependencies: ["docc2contextCore"]
        )
    ]
)
