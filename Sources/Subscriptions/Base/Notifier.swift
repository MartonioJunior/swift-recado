//
//  Notifier.swift
//  Trinkets
//
//  Created by Martônio Júnior on 30/03/2026.
//

/// Notification system that can publish payloads.
/// 
/// Uses a fire-and-forget model to send notifications.
public protocol Notifier {
    /// Notification data being sent by the publisher.
    /// 
    /// When this is `Void`, the notification works similar to a trigger.
    associatedtype Payload
    /// Notifies subscribers with the given payload.
    /// - Parameters:
    ///   - payload: The data to be sent to the listeners.
    func notify(_ payload: Payload)
}

// MARK: Self.Payload == Void
public extension Publisher where Payload == Void {
    /// Notifies subscribers with a trigger.
    func notify() { notify(()) }
}
