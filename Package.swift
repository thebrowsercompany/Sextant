// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "Sextant",
    platforms: [
        .macOS(.v10_13), .iOS(.v11)
    ],
    products: [
        .library(name: "Sextant", targets: ["Sextant"]),
    ],
    dependencies: [
        .package(url: "https://github.com/KittyMac/Chronometer.git", from: "0.1.0"),
        .package(url: "https://github.com/KittyMac/Hitch.git", from: "0.4.0"),
        .package(url: "https://github.com/thebrowsercompany/Spanker.git", branch: "timi/v0.2.47-plus-fix"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Sextant",
            dependencies: [
                "Hitch",
                "Spanker",
                "Chronometer"
            ]),
        .testTarget(
            name: "SextantTests",
            dependencies: ["Sextant"]),
    ]
)
