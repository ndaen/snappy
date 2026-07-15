// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Snappy",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "Snappy", path: "Sources/Snappy")
    ]
)
