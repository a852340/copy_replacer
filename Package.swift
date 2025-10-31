// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "CommaReplacer",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "CommaReplacer",
            targets: ["CommaReplacer"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "CommaReplacer",
            dependencies: []
        ),
        .testTarget(
            name: "CommaReplacerTests",
            dependencies: ["CommaReplacer"]
        )
    ]
)
