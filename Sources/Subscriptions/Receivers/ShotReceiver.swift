//
//  ShotReceiver.swift
//  Recado
//
//  Created by Martônio Júnior on 13/05/2026.
//

public struct ShotReceiver<Payload> {
    var base: any Receiver<Payload>
    var maxAmount: Int
    var count: Int

    public init<R: Receiver>(_ base: R, amount: Int = 0, startFrom count: Int = 1) where R.Payload == Payload {
        self.maxAmount = amount
        self.count = count
        self.base = base
    }

    public init(amount: Int, startFrom count: Int = 0, action: @escaping (Payload) -> Void) {
        self.maxAmount = amount
        self.count = count
        self.base = ActionReceiver(action)
    }
}

// MARK: Self: Receiver
extension ShotReceiver: Receiver {
    // swiftlint:disable:next missing_docs
    public var isCancelled: Bool { base.isCancelled || count >= maxAmount }
    // swiftlint:disable:next missing_docs
    public mutating func run(_ payload: Payload) {
        guard count < maxAmount else { return }

        count += 1
        base.run(payload)
    }
}

// MARK: ActionReceiver (EX)
public extension ActionReceiver {
    var oneShot: ShotReceiver<Payload> { repeated(by: 1) }

    func repeated(by iterations: Int) -> ShotReceiver<Payload> {
        .init(amount: iterations, startFrom: 0, action: closure)
    }
}

// MARK: Receiver (EX)
public extension Receiver {
    static func oneShot<Payload>(
        _ closure: @escaping (Payload) -> Void
    ) -> Self where Self == ShotReceiver<Payload> {
        .init(amount: 1, action: closure)
    }

    static func repeated<Payload>(
        by iterations: Int,
        startingFrom count: Int = 0,
        _ closure: @escaping (Payload) -> Void
    ) -> Self where Self == ShotReceiver<Payload> {
        .init(amount: iterations, startFrom: count, action: closure)
    }
}
