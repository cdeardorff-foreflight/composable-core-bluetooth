// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "composable-core-bluetooth",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v8),
    ],
    products: [
        .library(
            name: "ComposableCoreBluetooth",
            targets: ["ComposableCoreBluetooth"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            .upToNextMajor(from: "0.27.1"))
    ],
    targets: [
        .target(
            name: "ComposableCoreBluetooth",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "ComposableCoreBluetoothTests",
            dependencies: [
                "ComposableCoreBluetooth"
            ]
        ),
    ]
)
