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

    func testMiddlewareForSpecificReporter() throws {
        let otherReporter = AnalyticsReporterStub()
        evaluatePreConditionCeroEventsReported(reporterStub: reporter)
        evaluatePreConditionCeroEventsReported(reporterStub: otherReporter)
        
        tentacles.register(otherReporter, with: [.capitalisedAttributeKeys])
        tentacles.track(AnalyticsEventStub())
        if let event = reporter.isResultEvent(index: 0) {
            XCTAssertNotEqual(event.attributes["Category"],
                           TentaclesEventCategory.interaction.rawValue)
            XCTAssertNotEqual(event.attributes["Trigger"],
                           TentaclesEventTrigger.clicked.rawValue)
            XCTAssertNotEqual(event.attributes["Test"],
                           123)
        }
        if let event = otherReporter.isResultEvent(index: 0) {
            XCTAssertEqual(event.attributes["Category"],
                           TentaclesEventCategory.interaction.rawValue)
            XCTAssertEqual(event.attributes["Trigger"],
                           TentaclesEventTrigger.clicked.rawValue)
            XCTAssertEqual(event.attributes["Test"],
                           123)
        }
        evaluateNumberOfEventsReported(1, for: reporter)
        evaluateNumberOfEventsReported(1, for: otherReporter)
    }
    
    func testCapitalisedAttributeKeys() throws {
        evaluatePreConditionCeroEventsReported(reporterStub: reporter)
        tentacles.register(.capitalisedAttributeKeys)
        tentacles.track(AnalyticsEventStub())
        if let event = reporter.isResultEvent(index: 0) {
            XCTAssertEqual(event.attributes["Category"],
                           TentaclesEventCategory.interaction.rawValue)
            XCTAssertEqual(event.attributes["Trigger"],
                           TentaclesEventTrigger.clicked.rawValue)
            XCTAssertEqual(event.attributes["Test"],
                           123)
        }
        evaluateNumberOfEventsReported(1, for: reporter)
    }
    
    func testSkipSpecificEvent() throws {
        evaluatePreConditionCeroEventsReported(reporterStub: reporter)
        tentacles.register(.skipTestEvent)
        tentacles.track(AnalyticsEventStub())
        tentacles.track(AnalyticsEventStub(
            category: TentaclesEventCategory.interaction,
            trigger: TentaclesEventTrigger.clicked,
            name: "Test2", otherAttributes: .init(key: "Key", value: 123)))
        if let event = reporter.isResultEvent(index: 0) {
            XCTAssertEqual(event.name, "Test2")
        }
        evaluateNumberOfEventsReported(1, for: reporter)
    }
    
    func testValuePropositionDurationStartedToCompletedTransformed() throws {
        let middleware = Middleware<RawAnalyticsEvent>
            .durationValueProposition(between: .start, and: .complete)
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
            .durationValueProposition(between: .start, and: .complete)
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
    
    func testSpecificMiddlewareForASpecificProvider() throws {
        XCTAssertTrue(false)
    }
}
