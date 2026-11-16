//
//  Receiver.swift
//  Recado
//
//  Created by Martônio Júnior on 13/05/2026.
//

/// Action registered in a publisher.
public protocol Receiver<Payload> {
    /// Type representing information stored in the notification.
    associatedtype Payload
    /// Is this notification receiver disabled?
    var isCancelled: Bool { get }
    /// Handles the response from a notification.
    /// 
    /// It does not check whether the action has been cancelled or not.
    /// 
    /// If you want to run only if the action is still valid, use `handle(_:)` instead.
    /// - Parameter payload: Notification data.
    mutating func run(_ payload: Payload)
}

// MARK: Default Implementation
public extension Receiver {
    /// Handles the response from a notification.
    /// 
    /// If the action was cancelled, it is not executed.
    /// - Parameter payload: Notification data.
    mutating func handle(_ payload: Payload) {
        if isCancelled { return }

        run(payload)
    }
}
