//
//  File.swift
//  
//
//  Created by Patrick Fischer on 03.03.24.
//

import Foundation

import XCTest
@testable import Tentacles

final class MiddlewareStandardizeForSnakeCaseTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStandardizeForCamelCase() throws {
        let event = RawAnalyticsEvent(name: "test EventName")
        let transformedEvent = Middleware.standardizeForSnakeCase.transform(event)

        switch transformedEvent {
        case .some(let event):
            XCTAssertEqual(event.name, "test_event_name")
        case .none:
            XCTFail("Event was not transformed.")
        }
    }

    func testStandardizeForSnakeCase_MixedCaseWithSpaces() throws {
        let event = RawAnalyticsEvent(name: "Test EventName ForTransformation")
        let transformedEvent = Middleware.standardizeForSnakeCase.transform(event)

        switch transformedEvent {
        case .some(let event):
            XCTAssertEqual(event.name, "test_event_name_for_transformation")
        case .none:
            XCTFail("Event was not transformed.")
        }
    }

    func testStandardizeForSnakeCase_CamelCase() throws {
        let event = RawAnalyticsEvent(name: "testEventNameForTransformation")
        let transformedEvent = Middleware.standardizeForSnakeCase.transform(event)

        switch transformedEvent {
        case .some(let event):
            XCTAssertEqual(event.name, "test_event_name_for_transformation")
        case .none:
            XCTFail("Event was not transformed.")
        }
    }

    func testStandardizeForSnakeCase_AdditionalSpaces() throws {
        let event = RawAnalyticsEvent(name: "test  EventName   ForTransformation")
        let transformedEvent = Middleware.standardizeForSnakeCase.transform(event)

        switch transformedEvent {
        case .some(let event):
            XCTAssertEqual(event.name, "test_event_name_for_transformation")
        case .none:
            XCTFail("Event was not transformed.")
        }
    }

    func testStandardizeForSnakeCase_SpecialCharacters() throws {
        let event = RawAnalyticsEvent(name: "test#Event$Name&For*Transformation")
        let transformedEvent = Middleware.standardizeForSnakeCase.transform(event)

        switch transformedEvent {
        case .some(let event):
            // Assuming special characters are not transformed/removed by the middleware.
            XCTAssertEqual(event.name, "test_event_name_for_transformation")
        case .none:
            XCTFail("Event was not transformed.")
        }
    }

    func testStandardizeForSnakeCase_AlreadySnakeCase() throws {
        let event = RawAnalyticsEvent(name: "already_snake_case_name")
        let transformedEvent = Middleware.standardizeForSnakeCase.transform(event)

        switch transformedEvent {
        case .some(let event):
            XCTAssertEqual(event.name, "already_snake_case_name")
        case .none:
            XCTFail("Event was not transformed.")
        }
    }

    func testStandardizeForSnakeCase_EmptyString() throws {
        let event = RawAnalyticsEvent(name: "")
        let transformedEvent = Middleware.standardizeForSnakeCase.transform(event)

        switch transformedEvent {
        case .some(let event):
            XCTAssertEqual(event.name, "")
        case .none:
            XCTFail("Event was not transformed.")
        }
    }

}
