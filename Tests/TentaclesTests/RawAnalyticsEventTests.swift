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

    func testIsCategoryTrue() throws {
        let analyticsEvent = AnalyticsEventStub()
        let rawAnalyticsEvent = try RawAnalyticsEvent(analyticsEvent: analyticsEvent)
        XCTAssertTrue(rawAnalyticsEvent.isCategory(TentaclesEventCategory.interaction))
    }

    func testIsCategoryFalse() throws {
        let analyticsEvent = AnalyticsEventStub()
        let rawAnalyticsEvent = try RawAnalyticsEvent(analyticsEvent: analyticsEvent)
        XCTAssertFalse(rawAnalyticsEvent.isCategory(TentaclesEventCategory.screen))
    }

    func testCastingFailure() throws {
        do {
            let _: String = try RawAnalyticsEvent.downcast(true)
            XCTFail()
        } catch let error as RawAnalyticsEvent.Error {
            switch error {
            case .attributeValueWrongType(let firstValue, let secondValue):
                XCTAssertTrue(firstValue is Bool)
                XCTAssertTrue(secondValue is String.Type)
            case .keyNotAvailable(_), .valueIsNotData(_):
                XCTFail("Unexpected error case: .keyNotAvailable")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testCastingSuccess() throws {
        let value: Double = try RawAnalyticsEvent.downcast(123.5)
        XCTAssertEqual(value, 123.5)
    }

    func testDecodeValueSuccess() throws {
         let rawData: Data = "{\"foo\": \"bar\"}".data(using: .utf8)!
         let rawEvent = RawAnalyticsEvent(name: "testEvent", attributes: ["sampleKey": rawData])

         struct SampleDecodable: Decodable {
             let foo: String
         }

         do {
             let decodedValue: SampleDecodable = try rawEvent.decodeValue(for: "sampleKey")
             XCTAssertEqual(decodedValue.foo, "bar")
         } catch {
             XCTFail("Unexpected error: \(error)")
         }
     }

     func testDecodeValueFailure() throws {
         let rawData: Data = "{\"foo\": \"bar\"}".data(using: .utf8)!
         let rawEvent = RawAnalyticsEvent(name: "testEvent", attributes: ["sampleKey": rawData])

         struct SampleDecodable: Decodable {
             let foo: String
         }

         do {
             let _: SampleDecodable = try rawEvent.decodeValue(for: "nonexistentKey")
             XCTFail("Expected error not thrown")
         } catch let error as RawAnalyticsEvent.Error {
             switch error {
             case .attributeValueWrongType(_, _), .valueIsNotData(_):
                 XCTFail("Unexpected error case: .attributeValueWrongType")
             case .keyNotAvailable(let key):
                 XCTAssertEqual(key, "nonexistentKey")
             }
         } catch {
             XCTFail("Unexpected error type: \(error)")
         }
     }
}
