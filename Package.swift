// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NotesConverter",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(
            name: "NotesConverter",
            targets: ["NotesConverter"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.2"),
    ],
    targets: [
        .executableTarget(name: "NotesConverter", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
        .testTarget(
            name: "NotesConverterTests",
            dependencies: ["NotesConverter"]),
    ]
)
