// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MidnightOilTeams",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "MidnightOilTeams", targets: ["MidnightOilTeams"])
    ],
    targets: [
        .target(name: "MidnightOilTeams"),
        .testTarget(name: "MidnightOilTeamsTests", dependencies: ["MidnightOilTeams"])
    ]
)
