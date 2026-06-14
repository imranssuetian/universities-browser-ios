// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "CommonUI",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "CommonUI", targets: ["CommonUI"])
    ],
    targets: [
        .target(name: "CommonUI")
    ]
)
