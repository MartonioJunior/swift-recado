//
//  SubscriptionToken.swift
//  Recado
//
//  Created by Martônio Júnior on 24/10/2025.
//

/// Subscription token used for cancelling a subscription.
/// - Token: Unique identifier of a subscription in a registration context.
public struct SubscriptionToken<Token> {
    /// Token that uniquely identifies the subscription in a given context.
    /// 
    /// This token is used for both identification of the subscription,
    /// as well as cancellation when used in some types of publishers (e.g. `RegistryPublisher`).
    let token: Token
    /// Cancellation function.
    var cancellation: () -> Void
    // MARK: Initializers
    /// Creates a new subscription token.
    /// - Parameters:
    ///   - token: Identifier for the subscription.
    ///   - cancellation: Function that cancels the subscription
    ///
    public init(
        _ token: Token,
        cancellation: @escaping () -> Void
    ) {
        self.token = token
        self.cancellation = cancellation
    }
}

// MARK: Self: Subscription
extension SubscriptionToken: Subscription {
    // swiftlint:disable:next missing_docs
    public func cancel() {
        cancellation()
    }
}
