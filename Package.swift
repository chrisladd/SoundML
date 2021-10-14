// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "SoundML",
    products: [
        .library(
            name: "SoundML",
            targets: ["SoundML"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SoundML",
            dependencies: []),
        .testTarget(
            name: "SoundMLTests",
            dependencies: ["SoundML"],
            resources: [
                .copy("fixtures")
            ]
        )
    ]
)
