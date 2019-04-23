// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Binaryen",
    products: [
        .library(name: "Binaryen", targets: ["Binaryen"]),
    ],
    targets: [
        .target(
            name: "Binaryen",
            dependencies: ["CBinaryen"]
        ),
        .systemLibrary(
            name: "CBinaryen",
            pkgConfig: "binaryen",
            providers: [
                .brew(["binaryen"]),
                .apt(["binaryen"]),
            ]
        ),
        .testTarget(
            name: "BinaryenTests",
            dependencies: ["Binaryen"]
        )
    ]
)
