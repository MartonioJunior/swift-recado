//
//  MainActorReceiver.swift
//  Recado
//
//  Created by Martônio Júnior on 13/05/2026.
//

/// Receiver that only executes on the main thread.
public struct MainActorReceiver<Payload: Sendable> {
    // MARK: Variables
    /// Base receiver used in this operation
    var base: any Receiver<Payload>
    // MARK: Initializers
    /// Creates a new Main Actor receiver.
    /// - Parameter base: Receiver used as the base.
    public init<R: Receiver>(_ base: R) where R.Payload == Payload {
        self.base = base
    }
    /// Creates a new Main Actor receiver.
    /// - Parameter action: Action to be executed on the main thread.
    public init(_ action: @escaping (Payload) -> Void) {
        self.base = ActionReceiver(action)
    }
}

// MARK: Self: Receiver
extension MainActorReceiver: Receiver {
    // swiftlint:disable:next missing_docs
    public var isCancelled: Bool { base.isCancelled }
    // swiftlint:disable:next missing_docs
    public mutating func run(_ payload: Payload) {
        nonisolated(unsafe) let receiver = base
        Task { @MainActor [isCancelled] in
            if isCancelled { return }

            var temp = receiver
            temp.run(payload)
        }
    }
}

// MARK: ActionReceiver (EX)

// MARK: Receiver (EX)
public extension Receiver {
    static func mainActor<Payload>(
        _ closure: @escaping (Payload) -> Void
    ) -> Self where Self == MainActorReceiver<Payload> {
        .init(closure)
    }
}
