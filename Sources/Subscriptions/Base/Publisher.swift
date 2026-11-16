//
//  Publisher.swift
//  Trinkets
//
//  Created by Martônio Júnior on 30/03/2026.
//

/// Notifier that manages the subscription actions for it's subscribers.
public typealias PublisherOf<Payload> = Publisher<Payload, (Payload) -> Void>

/// Notifier that manages the subscription actions for it's subscribers.
/// - `Action`: What is executed upon receiving a notification.
/// - `Cancellation`: Subscription used to cancel an action.
public protocol Publisher<Payload, Action>: Notifier {
    /// Action to be performed when a notification is published.
    associatedtype Action: Receiver where Action.Payload == Payload
    /// Data structure that defines the cancellation for a subscription.
    associatedtype Cancellation: Subscription
    /// Registers a listener action for the notification.
    /// - Parameters
    ///   - action: Closure to be executed when a notification is sent.
    /// - Returns: `Cancellation` which can be used to unsubscribe later.
    mutating func subscribe(_ action: Action) -> Cancellation
}

// MARK: Self.Action == AnyReceiver
public extension Publisher where Action == AnyReceiver<Payload> {
    /// Subscribes to a given notification using a receiver.
    /// 
    /// - Parameters:
    ///   - receiver: Notification receiver.
    ///
    /// - Returns: `Cancellation` which can be used to unsubscribe later.
    mutating func subscribe<R: Receiver>(_ receiver: R) -> Cancellation where R.Payload == Payload {
        subscribe(receiver.erased())
    }
    /// Subscribes to a given notification using a closure.
    /// 
    /// - Parameters:
    ///   - closure: Function to handle the notification payload.
    ///
    /// - Returns: `Cancellation` which can be used to unsubscribe later.
    mutating func subscribe(_ closure: @escaping (Payload) -> Void) -> Cancellation {
        subscribe(ActionReceiver(closure))
    }
}

// MARK: AsyncStream (EX)
public extension AsyncStream where Element: Sendable {
    /// Creates an async stream based on a publisher.
    /// - Parameters:
    ///   - publisher: Publisher used as the base
    ///   - bufferingPolicy: A `Continuation.BufferingPolicy` value to set the stream's buffering behavior. By default, the stream buffers the last 100 elements.
    ///
    /// - Returns:
    static func publisher<P: Publisher>(
        _ publisher: inout P,
        bufferingPolicy: Continuation.BufferingPolicy = .bufferingNewest(100)
    ) -> Self where P.Payload == Element, P.Action == AnyReceiver<Element>, P.Cancellation: Sendable {
        var continuation: Continuation?

        let stream = Self(bufferingPolicy: bufferingPolicy) { streamContinuation in
            continuation = streamContinuation
        }

        guard let continuation else {
            return AsyncStream { $0.finish() }
        }

        let subscription = publisher.subscribe { payload in
            Task { continuation.yield(payload) }
        }

        continuation.onTermination = { @Sendable _ in
            subscription.cancel()
        }

        return stream
    }
}
