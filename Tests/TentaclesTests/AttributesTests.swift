//
//  AttributesTests.swift
//  
//
//  Created by Patrick Fischer on 24.07.22.
//

import XCTest
@testable import Tentacles

final class AttributesTests: XCTestCase {
    private struct FailingAttribues: TentaclesAttributes {
        func encode(to encoder: Encoder) throws {
            throw NSError(domain: "Serialisation failed", code: 0)
        }
    }
    func testSerializationKeyValueAttribute() throws {
        let key = "Test", value = 123
        let keyValueAttribute = KeyValueAttribute<Int>(key: key, value: value)
        let serialisedValue = keyValueAttribute.serialiseToValue()
        XCTAssertEqual(serialisedValue.map{String($0.key) }[0], key)
        XCTAssertEqual(serialisedValue[key], value)
    }
    
    func testSerialisationEmptyAttributes() throws {
        let emptyAttributes = EmptyAttributes()
        let serialisedValue = try emptyAttributes.serialiseToValue()
        XCTAssertEqual(serialisedValue, [:])
    }
    
    func testSerialisationFailure() throws {
        let failingAttributes = FailingAttribues()
        let serialisedValue = try? failingAttributes.serialiseToValue()
        XCTAssertEqual(nil, serialisedValue)
    }
}
