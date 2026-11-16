// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - Utilities
public enum UpcomingFeatures: String, CaseIterable {
    case existentialAny
    case internalImportsByDefault
    case memberImportVisibility
    case nonescapableTypes
    case nonisolatedNonsendingByDefault
    case inferIsolatedConformances
    case valueGenerics
    case immutableWeakCaptures

    var asSetting: SwiftSetting { .enableUpcomingFeature(rawValue.prefix(1).uppercased() + rawValue.dropFirst()) }
}

public enum ExperimentalFeatures: String, CaseIterable {
    case fullTypedThrows
    case keyPathWithMethodMembers

    var asSetting: SwiftSetting { .enableUpcomingFeature(rawValue.prefix(1).uppercased() + rawValue.dropFirst()) }
}

public extension Array where Element == SwiftSetting {
    static var allFeatures: Self { .experimentalFeatures + .upcomingFeatures }
    static var experimentalFeatures: Self { ExperimentalFeatures.allCases.map(\.asSetting) }
    static var upcomingFeatures: Self { UpcomingFeatures.allCases.map(\.asSetting) }
}

func platformDeps(_ platforms: SupportedPlatform...) -> [SupportedPlatform] {
    platforms
}

func targetDep(name: String, package: String, condition: TargetDependencyCondition? = nil) -> Target.Dependency {
    .product(name: name, package: package, condition: condition)
}

// MARK: - Traits
var traits: Set<Trait> = []

traits.insert(
    .default(enabledTraits: Set(traits.map(\.name)))
)

// MARK: - Targets
let targets: [Target] = [
    .target(
        name: "MulticastDelegate",
        swiftSettings: .upcomingFeatures
    ),
    .target(
        name: "Recado",
        dependencies: ["MulticastDelegate", "Subscriptions"],
        swiftSettings: .upcomingFeatures
    ),
    .target(
        name: "Subscriptions",
        swiftSettings: .upcomingFeatures
    ),
]

let testTargets: [Target] = targets.map { t in
    .testTarget(name: "\(t.name)Tests", dependencies: [Target.Dependency(stringLiteral: t.name)] + t.dependencies)
}

// MARK: - Products
let products: [Product] = [
    .library(
        name: "Recado",
        targets: targets.map(\.name)
    )
]

// MARK: - PackageDescription
let package = Package(
    name: "Recado",
    products: products,
    targets: targets + testTargets,
    swiftLanguageModes: [.v6]
)
