// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "IDINCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "IDINCore", targets: ["IDINCore"])
    ],
    targets: [
        .target(name: "IDINCore")
    ],
    swiftLanguageModes: [.v6]
)
