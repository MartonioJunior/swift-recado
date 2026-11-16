//
//  Handler.swift
//  Recado
//
//  Created by Martônio Júnior on 23/09/23.
//

import Foundation

/// Receiver that is capable of passing handling to another receiver down the chain.
/// 
/// Acts as a quick-and-dirty implementation of the chain of responsibility pattern.
/// - Payload: Information processed by the handler.
public struct Handler<Payload> {
    // MARK: Variables
    /// Attempt to handle the notification received.
    /// - Returns:
    ///   - `true` when the process is fully handled by this instance.
    ///   - `false` when the process is delegated to the next instance.
    let handle: (Payload) -> Bool
    /// If not this instance, which one should handle the payload?
    /// 
    /// Returns `nil` when there's no remaining elements in the chain.
    var next: (Payload) -> Handler<Payload>?
    // MARK: Initializers
    /// Creates a new handler.
    /// - Parameters:
    ///   - handle: How to process a given notification payload.
    ///   - next: To which handler should this instance delegate to when it can't fully process the request?
    ///
    init(
        _ handle: @escaping (Payload) -> Bool,
        next: @escaping (Payload) -> Handler<Payload>?
    ) {
        self.handle = handle
        self.next = next
    }
    // MARK: Methods
    /// Breaks the chain by returning `nil` as the next possible handler. 
    public mutating func breakChain() {
        next = { _ in nil }
    }
    /// Redefines the next handler in the chain.
    /// - Parameter handler: Next handler in the chain.
    public mutating func followedBy(_ handler: @autoclosure @escaping () -> Handler<Payload>?) {
        next = { _ in handler() }
    }
    /// Processes a given notification payload.
    /// 
    /// Starts from the current handler, then moves on to following handlers in a non-recursive manner.
    /// 
    /// Goes until the payload is fully processed or the chain ends.
    /// - Parameter payload: Notification payload.
    public func process(_ payload: Payload) {
        var pointer: Handler<Payload>? = self

        while pointer != nil {
            if handle(payload) { break }

            pointer = next(payload)
        }
    }
}

// MARK: DotSyntax
public extension Handler {
    /// Creates a new handler by chaining together multiple handler functions linearly.
    /// - Parameter handlers: List of handler functions
    /// - Returns: A `Handler` instance that chains all the handler functions in order.
    static func chaining(
        _ handlers: (Payload) -> Bool...
    ) -> Self? {
        handlers.reversed().reduce(nil) { last, handle in
            Handler(handle) { _ in last }
        }
    }
}

// MARK: Self: Receiver
extension Handler: Receiver {
    // swiftlint:disable:next missing_docs
    public var isCancelled: Bool { false }
    // swiftlint:disable:next missing_docs
    public func run(_ payload: Payload) {
        process(payload)
    }
}

// MARK: Sequence (EX)
public extension Sequence {
    /// Applies all payloads into the same handler.
    /// - Parameter handler: Handler to receive all payloads.
    func batchProcess(using handler: Handler<Element>) {
        forEach(handler.process)
    }
    /// Processes a given notification payload.
    /// 
    /// Different from traditional processing in handler, it uses the next element in the sequence
    /// rather than looking at the `next` function.
    /// - Parameter request: Notification payload to handle
    func process<Request>(_ request: Request) where Element == Handler<Request> {
        forEach { $0.process(request) }
    }
}
