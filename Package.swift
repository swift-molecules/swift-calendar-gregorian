// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-calendar-gregorian",
    platforms: [.macOS(.v27), .iOS(.v27), .tvOS(.v27), .watchOS(.v27), .visionOS(.v27)],
    products: [
        .library(name: "Calendar Gregorian", targets: ["Calendar Gregorian"]),
    ],
    traits: [
        .trait(name: "Julian", description: "Julian integration"),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-polarity.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-translation.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-rational.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-calendar.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-difference.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-magnitude.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-cardinal.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-tagged.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-time.git", branch: "main"),
    ],
    targets: [
        .target(name: "Calendar Gregorian", dependencies: [
            .product(name: "Cardinal", package: "swift-cardinal"),
            .product(name: "Magnitude", package: "swift-magnitude"),
            .product(name: "Polarity", package: "swift-polarity"),
            .product(name: "Translation", package: "swift-translation"),
            .product(name: "Difference", package: "swift-difference"),
            .product(name: "Tagged", package: "swift-tagged"),
            .product(name: "Calendar", package: "swift-calendar"),
            .product(name: "Time", package: "swift-time"),
            ]),
        .testTarget(name: "Calendar Gregorian Tests", dependencies: [
            .product(name: "Rational", package: "swift-rational"),
            .target(name: "Calendar Gregorian"),
            .product(name: "Cardinal", package: "swift-cardinal"),
            .product(name: "Magnitude", package: "swift-magnitude"),
            .product(name: "Tagged", package: "swift-tagged"),
            .product(name: "Calendar", package: "swift-calendar"),
            .product(name: "Difference", package: "swift-difference"),
            .product(name: "Time", package: "swift-time"),
        ]),
        .testTarget(name: "Gregorian Julian Tests", dependencies: [.target(name: "Calendar Gregorian"), .product(name: "Calendar", package: "swift-calendar"), .product(name: "Time", package: "swift-time"), .product(name: "Tagged", package: "swift-tagged")], path: "Tests/Gregorian Julian Tests"),
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
