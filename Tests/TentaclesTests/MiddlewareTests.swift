//
//  MiddlewareTests.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import XCTest
@testable import Tentacles

final class MiddlewareTests: XCTestCase {
    private var reporter: AnalyticsReporterStub!
    private var tentacles: Tentacles!
    override func setUpWithError() throws {
        reporter = AnalyticsReporterStub()
        tentacles = buildTentacles(analyticsReporters: [reporter])
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        reporter = nil
        tentacles = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCapitalisedAttributeKeys() throws {
        var event = RawAnalyticsEvent()
        event.attributes["status"] = "status"
        event.attributes["trigger"] = "trigger"
        let middleware = Middleware<RawAnalyticsEvent>
            .capitalisedAttributeKeys
        let transformedEvent = middleware.transform(event)
        switch transformedEvent {
        case .some(let event):
            XCTAssertNotNil(event.attributes.contains{ $0.key == "Status" })
            XCTAssertNotNil(event.attributes.contains{ $0.key == "Trigger" })
        case .none:
            XCTFail()
        }
    }
    
    func testSkipEventForCategoryAffected() throws {
        var event = RawAnalyticsEvent()
        event.attributes[KeyAttributes.category] = TentaclesEventCategory
            .valueProposition.rawValue
        let transformedEvent = applySkipEventMiddlewareForCategory(
            with: TentaclesEventCategory.valueProposition, event: event)
        switch transformedEvent {
        case .some:
            XCTFail()
        case .none:
            XCTAssertTrue(true)
        }
    }
    
    func testSkipEventForCategoryNotAffected() throws {
        var event = RawAnalyticsEvent()
        event.attributes[KeyAttributes.category] = TentaclesEventCategory
            .screen.rawValue
        let transformedEvent = applySkipEventMiddlewareForCategory(
            with: TentaclesEventCategory.valueProposition, event: event)
        switch transformedEvent {
        case .some(let _event):
            XCTAssertEqual(event, _event)
        case .none:
            XCTFail()
        }
    }
    
    func testSkipEventForCategoryCategoryNotAvailable() throws {
        let event = RawAnalyticsEvent()
        let transformedEvent = applySkipEventMiddlewareForCategory(
            with: TentaclesEventCategory.valueProposition, event: event)
        switch transformedEvent {
        case .some(let _event):
            XCTAssertEqual(event, _event)
        case .none:
            XCTFail()
        }
    }
    
    func applySkipEventMiddlewareForCategory(
        with category: AnalyticsEventCategory,
        event: RawAnalyticsEvent)
    -> RawAnalyticsEvent? {
        return Middleware<RawAnalyticsEvent>
            .skipEvent(for: category)
            .transform(event)
    }
    
    func testEventForNameAffected() throws {
        let event = RawAnalyticsEvent(name: "Test")
        let transformedEvent = applySkipEventForNameMiddleware(
            with: ["Test"], event: event)
        switch transformedEvent {
        case.some:
            XCTFail()
        case .none:
            XCTAssertTrue(true)
        }
    }
    
    func testSkipEventForNameNotAffected() throws {
        let event = RawAnalyticsEvent(name: "OtherTest")
        let transformedEvent = applySkipEventForNameMiddleware(
            with: ["Test"], event: event)
        switch transformedEvent {
        case .some(let _event):
            XCTAssertEqual(event, _event)
        case .none:
            XCTFail()
        }
    }
    
    func applySkipEventForNameMiddleware(with names: [String],
                                         event: RawAnalyticsEvent)
    -> RawAnalyticsEvent? {
        return Middleware<RawAnalyticsEvent>
            .skipEvent(for: names).transform(event)
    }
    
    func testValuePropositionDurationStartedToCompletedTransformed() throws {
        let middleware = Middleware<RawAnalyticsEvent>
            .calculateValuePropositionDuration(
                between: .start, and: .complete)
        var event = RawAnalyticsEvent()
        event.attributes[KeyAttributes.category] = TentaclesEventCategory.valueProposition.name
        event.attributes["started"] = 1234.0
        event.attributes["completed"] = 1334.0
        let transformedEvent = middleware.transform(event)
        switch transformedEvent {
        case .some(let event):
            let durationStartedCompleted: Double = try event.getAttributeValue(
                for: "durationStartedCompleted")
            XCTAssertEqual(durationStartedCompleted, 100)
        case .none:
            XCTAssertTrue(false)
        }
    }
    
    func testValuePropositionDurationStartedToCompletedNotTransformed() throws {
        let middleware = Middleware<RawAnalyticsEvent>
            .calculateValuePropositionDuration(between: .start, and: .complete)
        let event = RawAnalyticsEvent()
        let transformedEvent = middleware.transform(event)
        switch transformedEvent {
        case.some(let event):
            let durationStartedCompleted: Double? = try? event.getAttributeValue(
                for: "durationStartedCompleted")
            XCTAssertNil(durationStartedCompleted)
        case .none:
            XCTAssertTrue(false)
        }
    }
}
