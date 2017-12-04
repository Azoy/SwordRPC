// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "SwordRPC",
  products: [
    .library(
      name: "SwordRPC",
      targets: ["SwordRPC"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/IBM-Swift/BlueSocket.git", from: "0.12.78")
  ],
  targets: [
    .target(
      name: "SwordRPC",
      dependencies: ["Socket"]
    )
  ]
)
