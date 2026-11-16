//
//  NotificationLink.swift
//  Trinkets
//
//  Created by Martônio Júnior on 30/03/2026.
//

/// Provides a template for registering notification senders to their receivers.
/// - `Sender`: Owner of the notification source.
/// - `Target`: Responder to the notification.
public struct NotificationLink<Sender, Target> {
    // MARK: Variables
    /// Function that describes a connection between sender and receiver.
    var connect: (inout Sender, Target) -> any Subscription
    // MARK: Initializers
    /// Creates a new link through a direct closure.
    /// - Parameter connect: Function describing the connection between sender and receiver.
    /// 
    /// In the example below, a button is connected to a door so that it opens when the button is pressed:
    /// ```swift
    /// let buttonPressedOpensDoor = Link { button, door in
    ///     button.onPressed.subscribe { payload in
    ///         door.setOpen(payload)
    ///     }
    /// }
    /// ```
    public init(_ connect: @escaping (inout Sender, Target) -> any Subscription) {
        self.connect = connect
    }
    /// Creates a new link that registers an action to a publisher through a closure.
    /// 
    /// Action is connected through an `ActionReceiver` instance using the publisher's `subscribe(_:)` method.
    /// 
    /// - Parameter handler: Closure to be executed when a notification is received.
    /// 
    /// Example:
    public init<Payload>(
        _ handler: @escaping (Target, Payload) -> Void
    ) where Sender: Publisher<Payload, AnyReceiver<Payload>> {
        self.init { sender, target in
            sender.subscribe { payload in
                handler(target, payload)
            }
        }
    }
    /// Creates a new link that registers a receiver in the target to a publisher in the sender.
    /// - Parameters:
    ///   - toPublisher: Key path to the given publisher in the sender.
    ///   - toReceiver: Getter for the receiver in a target instance.
    /// 
    /// Example:
    /// ```swift
    /// let buttonPressedOpensDoor = Link(\.onPressed) { receiver, payload in
    ///     receiver.setOpen(payload)
    /// }
    /// // or
    /// let buttonPressedOpensDoor = Link(\.onPressed, to: \.setOpen)
    /// ```
    public init<P: Publisher, R: Receiver>(
        _ toPublisher: WritableKeyPath<Sender, P>,
        _ toReceiver: @escaping (Target) -> R
    ) where P.Payload == R.Payload, P.Action == AnyReceiver<P.Payload> {
        self.init { sender, target in
            sender[keyPath: toPublisher].subscribe(toReceiver(target))
        }
    }
    // MARK: Methods
    /// Connects a sender to a target.
    /// - Parameters:
    ///   - source: Notification source.
    ///   - target: Notification receiver.
    ///
    /// - Returns: Subscription associated to this connection.
    /// 
    /// Example:
    /// ```swift
    /// let eventSubscription = buttonOpensDoor.connect(&door, to: button)
    /// ```
    public func connect(_ source: inout Sender, to target: Target) -> any Subscription {
        connect(&source, target)
    }
}

// MARK: DotSyntax
public extension NotificationLink {
    /// Creates a new link to registers an action to a publisher.
    /// - Parameter toAction: Action to be registered.
    /// - Returns: A new `Link` instance.
    static func action<Payload, Action>(
        _ toAction: @escaping (Target) -> Action
    ) -> Self where Sender: Publisher<Payload, Action> {
        .init { sender, target in
            sender.subscribe(toAction(target))
        }
    }
}
