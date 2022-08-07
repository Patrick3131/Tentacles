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
        let closureAction = middleware.closure(event)
        switch closureAction {
        case .forward(let event):
            print(event)
            XCTAssertNotNil(event.attributes.contains{ $0.key == "Status" })
            XCTAssertNotNil(event.attributes.contains{ $0.key == "Trigger" })
        case .skip:
            XCTFail()
        }
    }
    
    func testSkipEventForCategoryAffected() throws {
        var event = RawAnalyticsEvent()
        event.attributes[KeyAttributes.category] = TentaclesEventCategory
            .valueProposition.rawValue
        let closureAction = makeClosureSkipEventForCategory(
            with: TentaclesEventCategory.valueProposition, event: event)
        switch closureAction {
        case .forward:
            XCTFail()
        case .skip:
            XCTAssertTrue(true)
        }
    }
    
    func testSkipEventForCategoryNotAffected() throws {
        var event = RawAnalyticsEvent()
        event.attributes[KeyAttributes.category] = TentaclesEventCategory
            .screen.rawValue
        let closureAction = makeClosureSkipEventForCategory(
            with: TentaclesEventCategory.valueProposition, event: event)
        switch closureAction {
        case .forward(let _event):
            XCTAssertEqual(event, _event)
        case .skip:
            XCTFail()
        }
    }
    
    func testSkipEventForCategoryCategoryNotAvailable() throws {
        let event = RawAnalyticsEvent()
        let closureAction = makeClosureSkipEventForCategory(
            with: TentaclesEventCategory.valueProposition, event: event)
        switch closureAction {
        case .forward(let _event):
            XCTAssertEqual(event, _event)
        case .skip:
            XCTFail()
        }
    }
    
    func makeClosureSkipEventForCategory(
        with category: AnalyticsEventCategory,
        event: RawAnalyticsEvent)
    -> Middleware<RawAnalyticsEvent>.Action {
        let middlewareClosure = Middleware<RawAnalyticsEvent>
            .skipEvent(for: category).closure
        return middlewareClosure(event)
    }
    
    func testEventForNameAffected() throws {
        let event = RawAnalyticsEvent(name: "Test")
        let closureAction = makeClosureSkipEventForName(
            with: ["Test"], event: event)
        switch closureAction {
        case.forward(_):
            XCTFail()
        case .skip:
            XCTAssertTrue(true)
        }
    }
    
    func testSkipEventForNameNotAffected() throws {
        let event = RawAnalyticsEvent(name: "OtherTest")
        let closureAction = makeClosureSkipEventForName(
            with: ["Test"], event: event)
        switch closureAction {
        case .forward(let _event):
            XCTAssertEqual(event, _event)
        case .skip:
            XCTFail()
        }
    }
    
    func makeClosureSkipEventForName(with names: [String],
                                     event: RawAnalyticsEvent)
    -> Middleware<RawAnalyticsEvent>.Action {
        let middlewareClosure = Middleware<RawAnalyticsEvent>
            .skipEvent(for: names).closure
        return middlewareClosure(event)
    }
        
    func testValuePropositionDurationStartedToCompletedTransformed() throws {
        let middleware = Middleware<RawAnalyticsEvent>
            .calculateValuePropositionDuration(
                between: .start, and: .complete)
        var event = RawAnalyticsEvent()
        event.attributes[KeyAttributes.category] = TentaclesEventCategory.valueProposition.name
        event.attributes["started"] = 1234.0
        event.attributes["completed"] = 1334.0
        let closureAction = middleware.closure(event)
        switch closureAction {
        case .forward(let event):
            let durationStartedCompleted: Double = try event.getValueAttribute(
                for: "durationStartedCompleted")
            XCTAssertEqual(durationStartedCompleted, 100)
        case .skip:
            XCTAssertTrue(false)
        }
    }
    
    func testValuePropositionDurationStartedToCompletedNotTransformed() throws {
        let middleware = Middleware<RawAnalyticsEvent>
            .calculateValuePropositionDuration(between: .start, and: .complete)
        let event = RawAnalyticsEvent()
        let closureAction = middleware.closure(event)
        switch closureAction {
        case.forward(let event):
            let durationStartedCompleted: Double? = try? event.getValueAttribute(
                for: "durationStartedCompleted")
            XCTAssertNil(durationStartedCompleted)
        case .skip:
            XCTAssertTrue(false)
        }
    }
}
