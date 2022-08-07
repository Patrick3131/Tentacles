//
//  RawValuePropositionTests.swift
//  
//
//  Created by Patrick Fischer on 07.08.22.
//

import XCTest
@testable import Tentacles

final class RawValuePropositionTests: XCTestCase {
    private var rawValueProposition: RawValueProposition!
    
    override func setUpWithError() throws {
        let attributes = TentaclesAttributesStub()
        let valueProposition = ValuePropositionStub(
            name: "Test",
            attributes: attributes)
        self.rawValueProposition = RawValueProposition(from: valueProposition)
    }
    override func tearDownWithError() throws {
        self.rawValueProposition = nil
    }
    
    func testRawValuePropositionsAreEqual() throws {
        let otherAttributes = TentaclesAttributesStub()
        let otherRawValueProposition = RawValueProposition(
            from: ValuePropositionStub(
                name: "Test", attributes: otherAttributes))
        let isEqual = rawValueProposition == otherRawValueProposition
        XCTAssertTrue(isEqual)
    }
    
    func testRawValuePropositionsAreNotEqualDifferentName() throws {
        let otherAttributes = TentaclesAttributesStub()
        let otherRawValueProposition = RawValueProposition(
            from: ValuePropositionStub(
                name: "DifferentName", attributes: otherAttributes))
        let isEqual = rawValueProposition == otherRawValueProposition
        XCTAssertFalse(isEqual)
    }
    
    func testRawValuePropositionsAreNotEqualDifferentAttributes() throws {
        let otherAttributes = TentaclesAttributesStub(stringProperty: "DifferentName")
        let otherRawValueProposition = RawValueProposition(
            from: ValuePropositionStub(
                name: "Test", attributes: otherAttributes))
        let isEqual = rawValueProposition == otherRawValueProposition
        XCTAssertFalse(isEqual)
    }
}
