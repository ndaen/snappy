// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Snappy",
    platforms: [.macOS(.v14)],
    dependencies: [
        // Mise à jour in-app. Le framework est embarqué dans le bundle par package.sh.
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.6.0"),
    ],
    targets: [
        .executableTarget(
            name: "Snappy",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle"),
            ],
            path: "Sources/Snappy"
        )
    ]
)
