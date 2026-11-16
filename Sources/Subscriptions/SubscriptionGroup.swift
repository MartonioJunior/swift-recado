//
//  SubscriptionGroup.swift
//  Trinkets
//
//  Created by Martônio Júnior on 30/03/2026.
//

/// Collection of subscription tokens grouped together.
/// 
/// Groups subscriptions together independent of their actions or payload.
public struct SubscriptionGroup: ~Copyable {
    // MARK: Variables
    /// List of registered subscriptions.
    private var elements: [any Subscription]
    // MARK: Initializers
    /// Creates a new list of subscriptions.
    /// - Parameters:
    ///   - subscriptions: List of subscriptions for a type.
    ///
    public init(_ subscriptions: [any Subscription] = []) {
        self.elements = subscriptions
    }
    /// Removes all actions from wherever they're subscribed to.
    deinit {
        elements.forEach { $0.cancel() }
    }
    // MARK: Methods
    /// Registers a subscription to the group.
    /// - Parameter subscription: Subscription to store.
    public mutating func register(_ subscription: some Subscription) {
        elements.append(subscription)
    }
    /// Cancels all registered subscriptions.
    public mutating func unsubscribeAll() {
        elements.forEach { $0.cancel() }
        elements.removeAll()
    }
}

// MARK: Subscription (EX)
public extension Subscription {
    /// Adds the subscription to a subscription group.
    /// - Parameter group: Subscription group where to store it.
    func sink(to group: inout SubscriptionGroup) {
        group.register(self)
    }
}
