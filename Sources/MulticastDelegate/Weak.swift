//
//  Weak.swift
//  Implementation of Weak Reference pattern
//
//  Created by Martônio Júnior on 24/09/23.
//

import Foundation

@propertyWrapper
public struct Weak<T: AnyObject> {
    // MARK: Variables
    weak var value: T?

    // MARK: Properties
    public var wrappedValue: T? {
        get { value }
        set { value = newValue }
    }

    public var projectedValue: Self {
        get { self }
        set { self = newValue }
    }

    // MARK: Initializers
    public init(wrappedValue: T?) {
        self.value = wrappedValue
    }
}
