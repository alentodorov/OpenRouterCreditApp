// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "OpenRouterCreditApp",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "OpenRouterCreditApp", targets: ["OpenRouterCreditApp"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "OpenRouterCreditApp",
            dependencies: [],
            path: "Sources"
        )
    ]
)