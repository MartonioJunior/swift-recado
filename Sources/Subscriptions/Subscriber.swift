//
//  Subscriber.swift
//  Trinkets
//
//  Created by Martônio Júnior on 30/03/2026.
//

/// Action that can be registered in one or more publishers.
public typealias SubscriberOf<Payload> = Subscriber<Payload, ActionReceiver<Payload>>

/// Action that can be registered in one or more publishers.
/// 
/// Manages all of it's subscriptions internally, allowing for easy coupling
/// and decoupling from/to a `Publisher` instance.
/// - `Payload`: What is received by the action.
/// - `Action`: Processes the notification
public struct Subscriber<Payload, Action: Receiver>: ~Copyable where Action.Payload == Payload {
    // MARK: Variables
    /// Action to be executed.
    var action: Action
    /// List of subscriptions associated with this action
    var subscriptions: SubscriptionGroup
    // MARK: Initializers
    /// Creates a new subscriber.
    /// - Parameters:
    ///   - subscriptions: List of subscriptions for a type.
    ///   - action: Action to be executed.
    ///
    public init(_ subscriptions: consuming SubscriptionGroup = .init(), action: Action) {
        self.subscriptions = subscriptions
        self.action = action
    }
    /// Removes all actions from wherever they're subscribed to.
    deinit {}
    // MARK: Methods
    /// Registers itself to a new publisher.
    /// - Parameter source: Publisher that it subscribes to.
    public mutating func subscribe<P: Publisher<Payload, Action>>(to source: inout P) {
        source.subscribe(action).sink(to: &subscriptions)
    }
    /// Cancels all registered subscriptions.
    public mutating func unsubscribeAll() {
        subscriptions.unsubscribeAll()
    }
}
