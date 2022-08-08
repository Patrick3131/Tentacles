//
//  RawAnalyticsEventTests.swift
//  
//
//  Created by Patrick Fischer on 08.08.22.
//

import Foundation
import XCTest
@testable import Tentacles

final class RawAnalyticsEventTests: XCTestCase {
    // Other RawAnalyticsEvent related test cases are implicitly covered by other tests
    
    func testCastingFailure() throws {
        do {
            let _: String = try RawAnalyticsEvent.downcast(true)
            XCTFail()
        } catch {
            XCTAssertEqual(error as! RawAnalyticsEvent.Error, RawAnalyticsEvent.Error.attributeValueWrongType)
        }
        
    }
    
    func testCastingSuccess() throws {
        let value: Double = try RawAnalyticsEvent.downcast(123.5)
        XCTAssertEqual(value, 123.5)
    }
}
