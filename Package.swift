// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TEDesk",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "TEDesk", targets: ["TEDesk"])
    ],
    targets: [
        .executableTarget(name: "TEDesk", path: "Sources/TEDesk"),
        .testTarget(name: "TEDeskTests", dependencies: ["TEDesk"], path: "Tests/TEDeskTests")
    ],
    swiftLanguageVersions: [.v5]
)
