//
//  Trigger.swift
//  Trinkets
//
//  Created by Martônio Júnior on 02/04/2026.
//

/// Publisher for notifications that don't have an associated payload.
@propertyWrapper
public final class Trigger {
    // MARK: Variables
    var basePublisher: RegistryPublisher<String, Void> = .init()
    /// Works the same as using the instance directly.
    ///
    /// This is used when using the property wrapper version of the instance.
    public var wrappedValue: Trigger { self }
    // MARK: Initializers
    /// Creates a new cue.
    public init() {}

    deinit {}
    // MARK: Methods
    /// Invokes the current trigger.
    func callAsFunction() { notify() }
}

// MARK: Self: Publisher
extension Trigger: Publisher {
    /// Invokes the current trigger.
    public func notify(_: Void) { basePublisher.notify() }
    // swiftlint:disable:next missing_docs
    public func subscribe(_ action: ActionReceiver<Void>) -> some Subscription {
        basePublisher.subscribe(action.closure)
    }
}
