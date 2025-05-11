// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "OpenRouterCreditApp",
    platforms: [
        .macOS(.v13)
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