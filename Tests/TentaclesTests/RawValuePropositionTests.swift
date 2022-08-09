//
//  RawDomainActivityTests.swift
//  
//
//  Created by Patrick Fischer on 07.08.22.
//

import XCTest
@testable import Tentacles

final class RawDomainActivityTests: XCTestCase {
    private var rawDomainActivity: RawDomainActivity!
    
    override func setUpWithError() throws {
        let attributes = TentaclesAttributesStub()
        let domainActivity = DomainActivityStub(
            name: "Test",
            attributes: attributes)
        self.rawDomainActivity = RawDomainActivity(from: domainActivity)
    }
    override func tearDownWithError() throws {
        self.rawDomainActivity = nil
    }
    
    func testRawDomainActivitysAreEqual() throws {
        let otherAttributes = TentaclesAttributesStub()
        let otherRawDomainActivity = RawDomainActivity(
            from: DomainActivityStub(
                name: "Test", attributes: otherAttributes))
        let isEqual = rawDomainActivity == otherRawDomainActivity
        XCTAssertTrue(isEqual)
    }
    
    func testRawDomainActivitysAreNotEqualDifferentName() throws {
        let otherAttributes = TentaclesAttributesStub()
        let otherRawDomainActivity = RawDomainActivity(
            from: DomainActivityStub(
                name: "DifferentName", attributes: otherAttributes))
        let isEqual = rawDomainActivity == otherRawDomainActivity
        XCTAssertFalse(isEqual)
    }
    
    func testRawDomainActivitysAreNotEqualDifferentAttributes() throws {
        let otherAttributes = TentaclesAttributesStub(stringProperty: "DifferentName")
        let otherRawDomainActivity = RawDomainActivity(
            from: DomainActivityStub(
                name: "Test", attributes: otherAttributes))
        let isEqual = rawDomainActivity == otherRawDomainActivity
        XCTAssertFalse(isEqual)
    }
}
