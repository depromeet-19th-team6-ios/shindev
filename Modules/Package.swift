// swift-tools-version: 6.1
import PackageDescription

let tca: Target.Dependency = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
let package = Package(
    name: "SocialLedgerModules",
    platforms: [.iOS(.v17)],
    products: [.library(name: "AppFeature", targets: ["AppFeature"])],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.26.2"),
        .package(url: "https://github.com/swiftlang/swift-syntax", exact: "603.0.2"),
        .package(url: "https://github.com/pointfreeco/swift-perception", exact: "2.0.10"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "1.13.0")
    ],
    targets: [
        .target(name: "LedgerDomain"),
        .target(name: "LedgerData", dependencies: ["LedgerDomain"]),
        .target(name: "CalendarFeature", dependencies: ["LedgerDomain", tca]),
        .target(name: "TransactionFeature", dependencies: ["LedgerDomain", tca]),
        .target(name: "AppFeature", dependencies: ["LedgerDomain", "LedgerData", "CalendarFeature", "TransactionFeature", tca])
    ],
    swiftLanguageModes: [.v5]
)
