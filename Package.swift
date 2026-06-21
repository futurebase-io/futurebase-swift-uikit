// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FutureBaseUIKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(name: "FutureBaseUIKit", targets: ["FutureBaseUIKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/futurebase-io/futurebase-swift", exact: "0.1.0"),
    ],
    targets: [
        .target(
            name: "FutureBaseUIKit",
            dependencies: [
                .product(name: "FutureBase", package: "futurebase-swift"),
            ]
        ),
        .testTarget(name: "FutureBaseUIKitTests", dependencies: ["FutureBaseUIKit"]),
    ]
)
