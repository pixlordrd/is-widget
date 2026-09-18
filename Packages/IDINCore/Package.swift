// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "IDINCore",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "IDINCore", targets: ["IDINCore"])
    ],
    targets: [
        .target(
            name: "IDINCore",
            resources: [.process("Localizable.xcstrings")]
        )
    ],
    swiftLanguageModes: [.v6]
)
