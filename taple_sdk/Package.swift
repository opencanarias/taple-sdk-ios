// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "taple_sdk",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "taple_sdk",
            targets: ["taple_sdk", "tapleFFI"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "taple_sdk",
            dependencies: ["tapleFFI"]
        ),
        .binaryTarget(name: "tapleFFI", path: "Sources/tapleFFI.xcframework"),
        .testTarget(
            name: "taple_sdkTests",
            dependencies: ["taple_sdk"]
        ),
    ]
)
