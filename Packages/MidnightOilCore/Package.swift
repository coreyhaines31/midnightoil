// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MidnightOilCore",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "MidnightOilCore", targets: ["MidnightOilCore"])
    ],
    targets: [
        .target(name: "MidnightOilCore"),
        .testTarget(name: "MidnightOilCoreTests", dependencies: ["MidnightOilCore"])
    ]
)
