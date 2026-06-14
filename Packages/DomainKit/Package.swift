// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "DomainKit",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "DomainKit", targets: ["DomainKit"])
    ],
    targets: [
        .target(name: "DomainKit"),
        .testTarget(name: "DomainKitTests", dependencies: ["DomainKit"])
    ]
)
