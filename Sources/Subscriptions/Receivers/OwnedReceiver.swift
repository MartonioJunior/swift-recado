//
//  OwnedAction.swift
//  Recado
//
//  Created by Martônio Júnior on 13/05/2026.
//

/// Action that executes as long as it's owner exists.
public struct OwnedReceiver<Payload> {
    /// Owner of the action.
    weak var owner: AnyObject?
    /// Action to be executed.
    var handler: (AnyObject, Payload) -> Void
    /// Does the owner still exist?
    var isAlive: Bool { owner != nil }
    // MARK: Initializers
    /// Creates a new owned receiver.
    /// - Parameters:
    ///   - owner: Owner of the action.
    ///   - action: Closure to be executed when a notification is sent.
    public init<T: AnyObject>(owner: T, action: @escaping (Payload) -> Void) {
        self.owner = owner
        self.handler = { _, payload in
            action(payload)
        }
    }
    /// Creates a new owned receiver.
    /// - Parameters:
    ///   - owner: Owner of the action.
    ///   - handler: Closure to be executed when a notification is sent.
    public init<T: AnyObject>(owner: T, handler: @escaping (T, Payload) -> Void) {
        self.owner = owner
        self.handler = {
            guard let owner = $0 as? T else { return }

            handler(owner, $1)
        }
    }

    // MARK: Methods
    public func belongs<T: AnyObject>(to instance: T) -> Bool {
        owner === instance
    }

    public func belongs(to instanceID: ObjectIdentifier) -> Bool {
        guard let owner else { return false }

        return ObjectIdentifier(owner) == instanceID
    }
}

// MARK: Self: Receiver
extension OwnedReceiver: Receiver {
    // swiftlint:disable:next missing_docs
    public var isCancelled: Bool { !isAlive }
    // swiftlint:disable:next missing_docs
    public mutating func run(_ payload: Payload) {
        guard let owner else { return }

        handler(owner, payload)
    }
}

// MARK: ActionReceiver (EX)
public extension ActionReceiver {
    /// Wraps a traditional action under a ownership.
    /// - Parameter owner: Owner of the action.
    /// - Returns: A new `OwnedReceiver` instance.
    func owned<T: AnyObject>(by owner: T) -> OwnedReceiver<Payload> {
        .init(owner: owner, action: closure)
    }
}

// MARK: Receiver (EX)
public extension Receiver {
    static func owned<Owner: AnyObject, Payload>(
        by owner: Owner,
        action: @escaping (Payload) -> Void
    ) -> Self where Self == OwnedReceiver<Payload> {
        .init(owner: owner, action: action)
    }

    static func owned<Owner: AnyObject, Payload>(
        by owner: Owner,
        handler: @escaping (Owner, Payload) -> Void
    ) -> Self where Self == OwnedReceiver<Payload> {
        .init(owner: owner, handler: handler)
    }
}
