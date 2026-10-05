// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MidnightOilTeams",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "MidnightOilTeams", targets: ["MidnightOilTeams"])
    ],
    dependencies: [
        .package(path: "../../Packages/MidnightOilCore")
    ],
    targets: [
        .target(name: "MidnightOilTeams", dependencies: ["MidnightOilCore"]),
        .testTarget(name: "MidnightOilTeamsTests", dependencies: ["MidnightOilTeams"])
    ]
)
