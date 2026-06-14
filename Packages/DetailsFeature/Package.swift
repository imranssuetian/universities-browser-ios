// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "DetailsFeature",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "DetailsFeature", targets: ["DetailsFeature"])
    ],
    dependencies: [
        .package(path: "../DomainKit"),
        .package(path: "../CommonUI")
    ],
    targets: [
        .target(
            name: "DetailsFeature",
            dependencies: ["DomainKit", "CommonUI"]
        ),
        .testTarget(
            name: "DetailsFeatureTests",
            dependencies: ["DetailsFeature", "DomainKit"]
        )
    ]
)
