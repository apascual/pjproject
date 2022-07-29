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
      url: "https://github.com/apascual/pjproject/releases/download/latest/libpjproject.xcframework.zip",
      checksum: "24d9c33dc4a71af7de77d421261fd4afb793e4dd6051775d4231d7fc567b1d49"
    ),
  ]
)
