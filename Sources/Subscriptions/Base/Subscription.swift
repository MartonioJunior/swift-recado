//
//  Subscription.swift
//  Trinkets
//
//  Created by Martônio Júnior on 30/03/2026.
//

/// Cancellable representation for a single subscription.
public protocol Subscription {
    /// Cancels the subscription.
    /// 
    /// Any further calls to this method do nothing.
    func cancel()
}

// TODO: Add ownership-based ideas to the subscription (consuming, discard, etc.)
