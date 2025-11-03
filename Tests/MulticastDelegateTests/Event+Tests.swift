//
//  Event+Tests.swift
//  Trinkets
//
//  Created by Martônio Júnior on 08/01/25.
//

import Testing

@testable import Core

@Suite(.serialized)
struct EventTests {
    @available(macOS 14.0.0, *)
    @Test("Sends event with value to Listeners", arguments: [
        (5, 5)
    ])
    func raise_value(_ input: Int, expected: Int) async throws {
        var event = Event<Int>()
        var value: Int? = nil
        var token = event.subscribe { value = $0 }
        
        #expect(value == nil)

        try await event.raise(input)
        #expect(value == expected)
        token.cancel()
    }
    
    @available(macOS 14.0.0, *)
    @Test("Sends event to Listeners")
    func raise_noValue() async throws {
        var event = Event<Void>()
        var raised: Bool = false
        var token = event.subscribe { raised = true }
        
        #expect(!raised)
        
        try await event.raise()
        #expect(raised)
        token.cancel()
    }
    
    @available(macOS 14.0.0, *)
    @Test("Registers action into Event as a Listener", arguments: [
        ((5,9), 5)
    ])
    func subscribe_action(_ input: (Int, Int), expected: Int) async throws {
        var event = Event<Int>()
        let token = event.subscribe(Action<Int> {
            #expect($0 == expected)
        })

        try await event.raise(input.0)
        
        token.cancel()
        try await event.raise(input.1)
    }
    
    @available(macOS 14.0.0, *)
    @Test("Sends event with value to Listeners", arguments: [
        ((3,7), 3)
    ])
    func subscribe_closure(_ input: (Int, Int), expected: Int) async throws {
        var event = Event<Int>()
        var value: Int? = nil
        let token = event.subscribe { value = $0 }
        
        #expect(value == nil)

        try await event.raise(input.0)
        #expect(value == expected)
        
        token.cancel()
        try await event.raise(input.1)
        #expect(value == expected)
    }
}

// MARK:
