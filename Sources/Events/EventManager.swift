//
//  EventManager.swift
//  Trinkets
//
//  Created by Martônio Júnior on 30/03/2026.
//

#if Variety
public import Subscriptions
public import SwiftVariety

/// Object that acts as a mediator that manages loosely coupled event notifications.
public final class EventManager {
    // MARK: Variables
    /// Default event manager available to use during runtime.
    /// 
    /// Use this if you only need one event manager.
    public static nonisolated(unsafe) let `default` = EventManager()
    /// Dictionary of publishers.
    var publishers: HeterogeneousDictionary<ObjectIdentifier>
    /// Event bus for a given event type.
    /// - Parameter event: Type of event.
    /// - Returns: A specialized event bus for the given type.
    public subscript<E: Event>(_ event: E.Type) -> Bus<E>? {
        bus(event, for: event.busKey)
    }
    // MARK: Initializers
    /// Creates a new event manager.
    public init() {
        publishers = [:]
    }

    deinit {}
    // MARK: Methods
    /// Fetches the bus for a given event type
    /// - Parameters:
    ///   - key: Key used to obtain to the event bus in the registry.
    ///
    /// - Returns: Bus registered in the event manager. If there's no bus registered, creates and registers it before returning.
    private func bus<E: Event>(_: E.Type = E.self, for key: HKey<ObjectIdentifier, Bus<E>>) -> Bus<E>? {
        do {
            return try publishers.fetch(key)
        } catch {
            switch error {
                case .invalidKey:
                    let bus = Bus<E>()
                    publishers.register(bus, on: key)
                    return bus
                case .typeMismatch:
                    return nil
            }
        }
    }
    /// Clears the event bus for a given type.
    public func clear<E: Event>(_: E.Type) {
        self[E.self]?.clear()
    }
    /// Clears all event buses for the event manager.
    public func clearAll() {
        publishers = [:]
    }
    /// Registers a closure for execution when a given event type is triggered.
    /// 
    /// Different from `subscribe(_:action:)`, this method discards the subscription token in favor of
    /// a chain-based syntax for composing the event manager.
    /// - Parameters:
    ///   - eventType: Event type.
    ///   - action: Action to be performed.
    ///
    /// - Returns: Current `EventManager` instance.
    public func onEvent<E: Event>(_ eventType: E.Type, action: @escaping (E) -> Void) -> Self {
        _ = subscribe(eventType, action: action)
        return self
    }
    /// Raises a given event.
    /// - Parameter event: Event payload to be sent.
    public func raise<E: Event>(_ event: E) {
        self[E.self]?.notify(event)
    }
    /// Registers a closure for execution when a given event type is triggered.
    /// - Parameters:
    ///   - eventType: Event type.
    ///   - action: Action to be performed.
    ///
    /// - Returns: A subscription token for cancellation
    public func subscribe<E: Event>(_ eventType: E.Type, action: @escaping (E) -> Void) -> (any Subscription)? {
        guard var registry = bus(eventType, for: eventType.busKey) else { return nil }

        let subscription = registry.subscribe(action)
        publishers.registerOrUpdate(registry)
        return subscription
    }
}

// MARK: Self.Bus
public extension EventManager {
    /// Event bus that stores all of the subscriptions of event listeners.
    typealias Bus<E: Event> = RegistryPublisher<String, E>
}

// MARK: Event (EX)
public extension Event {
    /// Heterogeneous key used to access an event bus in an `EventManager`.
    static var busKey: HKey<ObjectIdentifier, EventManager.Bus<Self>> {
        .init(ObjectIdentifier(Self.self))
    }
}
#endif
