//
//  ActionReceiver.swift
//  Recado
//
//  Created by Martônio Júnior on 13/05/2026.
//

public struct ActionReceiver<Payload> {
    var closure: (Payload) -> Void
    /// Creates a new action receiver
    /// - Parameter closure: Function to be executed
    public init(_ closure: @escaping (Payload) -> Void) {
        self.closure = closure
    }
}

// MARK: Self: Receiver
extension ActionReceiver: Receiver {
    // swiftlint:disable:next missing_docs
    public var isCancelled: Bool { false }
    // swiftlint:disable:next missing_docs
    public mutating func run(_ payload: Payload) {
        closure(payload)
    }
}

// MARK: Receiver (EX)
public extension Receiver {
    static func action<Payload>(
        _ closure: @escaping (Payload) -> Void
    ) -> Self where Self == ActionReceiver<Payload> {
        .init(closure)
    }
}
