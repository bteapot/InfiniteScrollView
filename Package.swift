// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "InfiniteScrollView",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "InfiniteScrollView",
            targets: ["InfiniteScrollView"]
        ),
    ],
    targets: [
        .target(
            name: "InfiniteScrollView"
        ),
    ]
)
