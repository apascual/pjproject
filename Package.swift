// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "pjproject",
  platforms: [
    .iOS(.v13)
  ],
  products: [
    .library(
      name: "pjproject",
      targets: ["libpjproject"]),
  ],
  dependencies: [ ],
  targets: [
    .binaryTarget(
      name: "libpjproject",
      url: "https://github.com/apascual/pjproject/releases/download/v1.0.2/libpjproject.xcframework.zip",
      checksum: "25050719d8513d60ae1896e165b03dd5af33d5c995c9a3a1561118a32c3a5ca1"
    ),
  ]
)
