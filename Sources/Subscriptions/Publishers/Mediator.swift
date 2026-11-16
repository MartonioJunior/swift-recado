//
//  Mediator.swift
//  Recado
//
//  Created by Martônio Júnior on 23/09/23.
//

import Foundation

/// Publisher that manages both the notification and it's payload.
/// 
/// Implementation of the Mediator pattern.
public struct Mediator<Sender, Notification> {
    // swiftlint:disable:next missing_docs
    public typealias Action = AnyReceiver<Payload>
    // MARK: Variables
    /// Internal publisher used to manage subscriptions.
    var publisher: any Publisher<Payload, Action>
    // MARK: Initializers
    /// Creates a new mediator from a given publisher instance
    /// - Parameter publisher:
    public init(_ publisher: any Publisher<Payload, Action>) {
        self.publisher = publisher
    }
    // MARK: Methods
    /// Sends a notification for all other elements registered to the mediator.
    /// - Parameters:
    ///   - notification: Notification to be sent.
    ///   - sender: Notification sender.
    ///
    func notify(_ notification: Notification, sender: Sender) {
        notify(.init(notification, sender: sender))
    }
}

// MARK: Self.Payload
public extension Mediator {
    /// Notification payload for a `Mediator`.
    struct Payload {
        /// Who sent the notification?
        var sender: Sender
        /// Information about the notification.
        var notification: Notification
        /// Creates a new payload between elements.
        /// - Parameters:
        ///   - notification: Notification to be sent.
        ///   - sender: Notification sender.
        ///
        public init(_ notification: Notification, sender: Sender) {
            self.sender = sender
            self.notification = notification
        }
    }
}

// MARK: Self: Publisher
extension Mediator: Publisher {
    // swiftlint:disable:next missing_docs
    public func notify(_ payload: Payload) {
        publisher.notify(payload)
    }
    // swiftlint:disable:next missing_docs
    public mutating func subscribe(_ action: Action) -> some Subscription {
        let cancellation = publisher.subscribe(action)
        return SubscriptionToken(UUID().uuidString) {
            cancellation.cancel()
        }
    }
}
