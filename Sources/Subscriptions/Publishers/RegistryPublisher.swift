//
//  RegistryPublisher.swift
//  Recado
//
//  Created by Martônio Júnior on 05/06/2025.
//

import Foundation

/// A simple event system that allows for subscribing to and raising events with a payload.
/// 
/// - `Payload`: The type of data that will be sent to the listeners when the event is raised.
public class RegistryPublisher<Token: Hashable, Payload> {
    // MARK: Variables
    /// Method responsible for generating new unique tokens.
    var tokenGenerator: () -> Token
    /// List of registered receivers.
    /// 
    /// Receivers are stored with a subscription token to distinguish them inside of the publisher.
    var receivers: [Token: AnyReceiver<Payload>] = [:]
    /// Action registered to a given token.
    /// - Parameter token: Token used to register the action.
    /// - Returns: The action stored at the token index. If there's no action registered, returns a no-op closure.
    public subscript(_ token: Token) -> AnyReceiver<Payload> {
        receivers[token] ?? ActionReceiver({_ in }).erased()
    }
    // MARK: Initializers
    /// Creates a new publisher registry.
    /// - Parameters:
    ///   - receivers: Dictionary of registered actions.
    ///   - tokenGenerator: Unique token generator.
    ///
    public init(
        _ receivers: [Token: AnyReceiver<Payload>] = [:],
        tokenGenerator: @escaping () -> Token
    ) {
        self.receivers = receivers
        self.tokenGenerator = tokenGenerator
    }

    deinit {}
    // MARK: Methods
    /// Clears the entire registry of receivers.
    public func clear() {
        receivers.removeAll()
    }
    /// Registers an action using the given token.
    /// - Parameters:
    ///   - receiver: Action registered for execution.
    ///   - token: Token associated with the registered action.
    ///
    /// - Returns: `Subscription` instance.
    public func subscribe<R: Receiver>(_ receiver: R, token: Token) -> some Subscription where R.Payload == Payload {
        receivers[token] = receiver.erased()
        return SubscriptionToken(token) { [weak self] in
            self?.unsubscribe(token)
        }
    }
    /// Unsubscribes a listener using its token.
    /// - Parameters:
    ///   - token: Cancellation token created on subscribe.
    public func unsubscribe(_ token: Token) {
        receivers.removeValue(forKey: token)
    }
}

// MARK: Self: Publisher
extension RegistryPublisher: Publisher {
    // swiftlint:disable:next missing_docs
    public func notify(_ payload: Payload) {
        for key in receivers.keys {
            receivers[key]?.run(payload)
        }
    }
    // swiftlint:disable:next missing_docs
    public func subscribe(_ action: AnyReceiver<Payload>) -> some Subscription {
        subscribe(action, token: tokenGenerator())
    }
}

// MARK: Self.Token == String
public extension RegistryPublisher where Token == String {
    /// Creates a new publisher registry with an UUID token generator.
    /// - Parameter listeners: Dictionary of registered actions.
    convenience init(_ listeners: [Token: AnyReceiver<Payload>] = [:]) {
        self.init(listeners) { UUID().uuidString }
    }
}
