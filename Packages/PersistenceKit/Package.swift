// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "PersistenceKit",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "PersistenceKit", targets: ["PersistenceKit"])
    ],
    dependencies: [
        .package(path: "../DomainKit")
    ],
    targets: [
        .target(
            name: "PersistenceKit",
            dependencies: ["DomainKit"]
        ),
        .testTarget(
            name: "PersistenceKitTests",
            dependencies: ["PersistenceKit", "DomainKit"]
        )
    ]
)
