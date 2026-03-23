// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "TokenPet",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "TokenPet", targets: ["TokenPet"])
    ],
    targets: [
        .executableTarget(
            name: "TokenPet"
        )
    ]
)
