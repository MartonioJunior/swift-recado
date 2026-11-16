//
//  EventListener.swift
//  Trinkets
//
//  Created by Martônio Júnior on 30/03/2026.
//

import Subscriptions

/// Data structure that manages a list of subscribers to an event.
public struct EventListener<E: Event>: ~Copyable {
    // MARK: Variables
    var subscriber: Subscriber<E, AnyReceiver<E>>
    // MARK: Initializer
    /// Creates a new event listener using a subscriber instance.
    /// - Parameter subscriber: Subscriber that registers a closure for execution.
    public init(_ subscriber: consuming Subscriber<E, AnyReceiver<E>>) {
        self.subscriber = subscriber
    }
    /// Deregisters all listeners from the base subscriber.
    deinit {}
    // MARK: Methods
    /// Registers callbacks to a given source of notifications.
    /// - Parameter source: Source to register callbacks to.
    public mutating func listen(to source: inout EventManager) {
        guard var publisher = source[E.self] else { return }

        subscriber.subscribe(to: &publisher)
    }
    /// De-registers callbacks from all sources of notifications.
    public mutating func stopListening() {
        subscriber.unsubscribeAll()
    }
}
