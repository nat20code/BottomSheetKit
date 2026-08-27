// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BottomSheetKit",
  products: [
    .library(
      name: "BottomSheetKit",
      targets: ["BottomSheetKit"]
    ),
  ],
  targets: [
    .target(
      name: "BottomSheetKit"
    ),
    .testTarget(
      name: "BottomSheetKitTests",
      dependencies: ["BottomSheetKit"]
    ),
  ]
)
