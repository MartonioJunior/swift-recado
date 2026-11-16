//
//  AnyReceiver.swift
//  Trinkets
//
//  Created by Martônio Júnior on 13/05/2026.
//

/// Type-erased receiver.
public struct AnyReceiver<Payload> {
    // MARK: Variables
    /// Base receiver used in this operation
    var base: any Receiver<Payload>
    // MARK: Initializers
    /// Creates an erased receiver.
    /// - Parameter base: Receiver used as the base.
    public init<R: Receiver>(_ base: R) where R.Payload == Payload {
        self.base = base
    }
    // MARK: Methods
    /// Retrives the internal receiver cast to it's type.
    /// - Returns: The unwrapped receiver, `nil` otherwise.
    public func unwrapped<R: Receiver>(_: R.Type = R.self) -> R? {
        base as? R
    }
    /// Erases the receiver.
    /// - Returns: `AnyReceiver` instance wrapping the type.
    func erased() -> Self { self }
}

// MARK: Self: Receiver
extension AnyReceiver: Receiver {
    // swiftlint:disable:next missing_docs
    public var isCancelled: Bool { base.isCancelled }
    // swiftlint:disable:next missing_docs
    public mutating func run(_ payload: Payload) {
        base.run(payload)
    }
}

// MARK: Receiver (EX)
public extension Receiver {
    /// Erases the receiver.
    /// - Returns: `AnyReceiver` instance wrapping the type.
    func erased() -> AnyReceiver<Payload> { .init(self) }
}
