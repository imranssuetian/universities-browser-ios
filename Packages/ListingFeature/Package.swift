// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ListingFeature",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "ListingFeature", targets: ["ListingFeature"])
    ],
    dependencies: [
        .package(path: "../DomainKit"),
        .package(path: "../CommonUI")
    ],
    targets: [
        .target(
            name: "ListingFeature",
            dependencies: ["DomainKit", "CommonUI"]
        ),
        .testTarget(
            name: "ListingFeatureTests",
            dependencies: ["ListingFeature", "DomainKit"]
        )
    ]
)
