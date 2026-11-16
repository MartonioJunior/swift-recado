//
//  MulticastDelegate.swift
//  Recado
//
//  Created by Martônio Júnior on 24/09/23.
//

// import Extensions
import Foundation

public class MulticastDelegate<T> where T: AnyObject {
    // MARK: Variables
    private var delegates = [Weak<T>]()

    // MARK: Subscripts
    /// Convenience subscript for accessing delegate by index, returns nil if there is no object found
    public subscript(index: Int) -> T? {
        delegates.indices.contains(index) ? delegates[index].value : nil
    }

    /// Searches for the delegate and returns its index
    public subscript(delegate: T) -> Int? {
        delegates.firstIndex { $0.value === delegate }
    }

    // MARK: Initializers
    deinit {}

    // MARK: Methods
    public func add(delegate: T) {
        delegates.append(Weak(wrappedValue: delegate))
    }

    private func recycle() {
        delegates.removeAll { $0.value == nil }
    }

    public func remove(delegate: T) {
        _ = self[delegate].map { delegates.remove(at: $0) }
    }

    public func update(using completion: @escaping (T) -> Void) {
        // Recycle the values that are nil so the completion closure is called for non nil values
        recycle()

        delegates.forEach { $0.value.map(completion) }
    }

    // MARK: Operators
    static func += (lhs: MulticastDelegate, rhs: T) {
        lhs.add(delegate: rhs)
    }

    static func -= (lhs: MulticastDelegate, rhs: T) {
        lhs.remove(delegate: rhs)
    }

    static func ~> (lhs: MulticastDelegate, rhs: @escaping (T) -> Void) {
        lhs.update(using: rhs)
    }
}

// MARK: Sequence
extension MulticastDelegate: Sequence {
    public func makeIterator() -> AnyIterator<T> {
        var iterator = delegates.makeIterator()

        return AnyIterator {
            while let next = iterator.next() {
                if let value = next.value {
                    return value
                }
            }

            return nil
        }
    }
}
