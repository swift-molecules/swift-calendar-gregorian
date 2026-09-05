// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-calendar-gregorian",
    platforms: [.macOS(.v27), .iOS(.v27), .tvOS(.v27), .watchOS(.v27), .visionOS(.v27)],
    products: [
        .library(name: "Calendar Gregorian", targets: ["Calendar Gregorian"]),
    ],
    dependencies: [
        .package(path: "../../swift-atoms/swift-calendar"),
        .package(path: "../../swift-atoms/swift-time"),
    ],
    targets: [
        .target(name: "Calendar Gregorian", dependencies: [.product(name: "Calendar", package: "swift-calendar"), .product(name: "Time", package: "swift-time")]),
        .testTarget(name: "Calendar Gregorian Tests", dependencies: [.target(name: "Calendar Gregorian"), .product(name: "Calendar", package: "swift-calendar"), .product(name: "Time", package: "swift-time")]),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
