//
//  AttributesTests.swift
//  
//
//  Created by Patrick Fischer on 24.07.22.
//

import XCTest
@testable import Tentacles

final class AttributesTests: XCTestCase {
    
    func testSerializationKeyValueAttribute() throws {
        let key = "Test", value = 5423
        let keyValueAttribute = KeyValueAttribute<Int>(key: key, value: value)
        let serialisedValue = keyValueAttribute.serialiseToValue()
        XCTAssertEqual(serialisedValue.map{String($0.key) }[0], key)
        XCTAssertEqual(serialisedValue[key], value)
    }
}
