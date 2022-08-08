//
//  AnalyticsEventReportingTests.swift
//  
//
//  Created by Patrick Fischer on 02.08.22.
//

import Combine
import XCTest
import Tentacles

final class AnalyticsEventReportingTests: XCTestCase {
    private var reporter: AnalyticsReporterStub!
    private var otherReporter: AnalyticsReporterStub!
    private var tentacles: Tentacles!
    private var eventResultsSub: AnyCancellable!
    private var otherEventResultsSub: AnyCancellable!
    override func setUpWithError() throws {
        self.reporter = AnalyticsReporterStub()
        self.otherReporter = AnalyticsReporterStub()
        self.tentacles = Tentacles()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        reporter = nil
        otherReporter = nil
        tentacles = nil
        eventResultsSub = nil
        otherEventResultsSub = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    

    func testAnalyticsEventTracking() throws {
        let event = AnalyticsEventStub()
        let expectation = expectation(description: "testAnalyticsEvent")
        var results = [Result<RawAnalyticsEvent, Error>]()
        tentacles.register(reporter)
        eventResultsSub = reporter
            .analyticsEventPublisher
            .sink { result in
                results.append(result)
                if results.count == 1 {
                    expectation.fulfill()
                }
            }
        tentacles.track(event)
        wait(for: [expectation], timeout: 1)
        switch results[0] {
        case .success(let event):
            XCTAssertEqual(event.name, AnalyticsEventStub.eventName)
        case .failure:
            XCTFail()
        }
    }
    
    func testSessionUUIDAddedAsAttribute() throws {
        let event = AnalyticsEventStub()
        let expectation = expectation(description: "testAnalyticsEvent")
        var results = [Result<RawAnalyticsEvent, Error>]()
        tentacles.register(reporter)
        eventResultsSub = reporter
            .analyticsEventPublisher
            .sink { result in
                results.append(result)
                if results.count == 1 {
                    expectation.fulfill()
                }
            }
        tentacles.track(event)
        wait(for: [expectation], timeout: 1)
        switch results[0] {
        case .success(let event):
            let uuid: String = try event.getAttributeValue(
                for: KeyAttributes.sessionUUID)
            XCTAssertNotNil(UUID(uuidString: uuid))
        case .failure:
            XCTFail()
        }
    }
    
    func testAnalyticsEventTrackingWithOneGeneralMiddleware() throws {
        let event = AnalyticsEventStub()
        let expectation = expectation(
            description: "testWithOneGeneralMiddleware")
        var results = [Result<RawAnalyticsEvent, Error>]()
        tentacles.register(.lowercaseEventName)
        tentacles.register(reporter)
        eventResultsSub = reporter.analyticsEventPublisher
            .sink { result in
                results.append(result)
                if results.count == 1 {
                    expectation.fulfill()
                }
            }
        tentacles.track(event)
        wait(for: [expectation], timeout: 1)
        switch results[0] {
        case .success(let event):
            XCTAssertEqual(event.name, AnalyticsEventStub.eventName.lowercased())
        case .failure:
            XCTFail()
        }
    }
    
    // this covers this case as well: testAnalyticsEventTrackingTwoReportersOneHasSpecificMiddleware
    func testTwoReporterSkipEventForOneSpecificReporter() throws {
        let eventWillBeSkipped = AnalyticsEventStub()
        let skipExpectation = expectation(
            description: "skipEventForReporter")
        skipExpectation.isInverted = true
        let noSkipExpectation = expectation(
            description: "noSkipEventForReporter")
        var results = [Result<RawAnalyticsEvent, Error>]()
        var otherResults = [Result<RawAnalyticsEvent, Error>]()
        tentacles.register(reporter, with: [.skipTestEvent])
        tentacles.register(otherReporter)
        eventResultsSub = reporter.analyticsEventPublisher
            .sink { result in
                results.append(result)
                if results.count == 2 {
                    skipExpectation.fulfill()
                }
            }
        otherEventResultsSub = otherReporter.analyticsEventPublisher
            .sink { result in
                otherResults.append(result)
                if otherResults.count == 2 {
                    noSkipExpectation.fulfill()
                }
            }
        tentacles.track(eventWillBeSkipped)
        let screenEvent = AnalyticsScreenEventStub()
        tentacles.track(screenEvent)
        wait(for: [skipExpectation, noSkipExpectation], timeout: 1)
        switch results[0] {
        case .success(let event):
            XCTAssertEqual(event.name, screenEvent.name)
        case .failure:
            XCTFail()
        }
        switch otherResults[0] {
        case .success(let event):
            XCTAssertEqual(event.name, AnalyticsEvent.eventName)
        case .failure:
            XCTFail()
        }
        switch otherResults[1] {
        case .success(let event):
            XCTAssertEqual(event.name, screenEvent.name)
        case .failure:
            XCTFail()
        }
    }
    
    func testSkipEventForAllReporters() throws {
        let eventWillBeSkipped = AnalyticsEventStub()
        let skipExpectation = expectation(
            description: "skipEventForReporter")
        skipExpectation.isInverted = true
        let noSkipExpectation = expectation(
            description: "noSkipEventForReporter")
        noSkipExpectation.isInverted = true
        var results = [Result<RawAnalyticsEvent, Error>]()
        var otherResults = [Result<RawAnalyticsEvent, Error>]()
        tentacles.register(reporter)
        tentacles.register(otherReporter)
        tentacles.register(.skipTestEvent)
        eventResultsSub = reporter.analyticsEventPublisher
            .sink { result in
                results.append(result)
                if results.count == 1 {
                    skipExpectation.fulfill()
                }
            }
        otherEventResultsSub = otherReporter.analyticsEventPublisher
            .sink { result in
                otherResults.append(result)
                if otherResults.count == 1 {
                    noSkipExpectation.fulfill()
                }
            }
        tentacles.track(eventWillBeSkipped)
        wait(for: [skipExpectation, noSkipExpectation], timeout: 1)
    }
    
    func testAnalyticsEventTrackingWithTwoGeneralMiddlewares() throws {
        tentacles.register(reporter)
        tentacles.register(.appendStringToName("A"))
        tentacles.register(.lowercaseEventName)
        makesResultsForOneReporterTwoMiddlewares()
    }
    
    func testAnalyticsEventTrackingWithOneGeneralAndOneSpecificMiddleware() throws {
        tentacles.register(.appendStringToName("A"))
        tentacles.register(reporter, with: [.lowercaseEventName])
        makesResultsForOneReporterTwoMiddlewares()
    }
    
    func testAnalyticsEventTrackingWithTwoSpecificMiddlewares() throws {
        tentacles.register(reporter, with: [.appendStringToName("A"),
                                            .lowercaseEventName])
        makesResultsForOneReporterTwoMiddlewares()
    }
    
    func makesResultsForOneReporterTwoMiddlewares() {
        let expectation = expectation(description: "testTwoMiddlewares")
        var results = [Result<RawAnalyticsEvent, Error>]()
        eventResultsSub = reporter.analyticsEventPublisher
            .sink { result in
                results.append(result)
                if results.count == 1 {
                    expectation.fulfill()
                }
            }
        tentacles.track(AnalyticsEventStub())
        wait(for: [expectation], timeout: 1)
        switch results[0] {
        case .success(let event):
            XCTAssertEqual(event.name, AnalyticsEventStub.eventName.lowercased() + "a")
        case .failure:
            XCTFail()
        }
    }
    
    func testAnalyticsEventTrackingTwoReporters() throws {
        let event = AnalyticsEventStub()
        let analyticsEventTrackedExpectation = expectation(
            description: "testAnalyticsEvent")
        let otherAnalyticsEventTrackedExpectation = expectation(
            description: "testAnalyticsEvent")
        var results = [Result<RawAnalyticsEvent, Error>]()
        var otherResults = [Result<RawAnalyticsEvent, Error>]()
        tentacles.register(reporter)
        tentacles.register(otherReporter)
        eventResultsSub = reporter.analyticsEventPublisher
            .sink { result in
                results.append(result)
                if results.count == 1 {
                    analyticsEventTrackedExpectation.fulfill()
                }
            }
        otherEventResultsSub = otherReporter.analyticsEventPublisher
            .sink { result in
                otherResults.append(result)
                if otherResults.count == 1 {
                    otherAnalyticsEventTrackedExpectation.fulfill()
                }
            }
        tentacles.track(event)
        wait(for: [analyticsEventTrackedExpectation, otherAnalyticsEventTrackedExpectation], timeout: 1)
        func evaluateEvent(_ event: RawAnalyticsEvent) throws {
            let category: String = try event.getAttributeValue(for: KeyAttributes.category)
            let trigger: String = try event.getAttributeValue(for: KeyAttributes.trigger)
            let testAttribute: Int = try event.getAttributeValue(for: "test")
            XCTAssertEqual(event.name, AnalyticsEventStub.eventName)
            XCTAssertEqual(category, TentaclesEventCategory.interaction.name)
            XCTAssertEqual(trigger, TentaclesEventTrigger.clicked.name)
            XCTAssertEqual(testAttribute, 123)
        }
        switch results[0] {
        case .success(let event):
            try evaluateEvent(event)
        case .failure:
            XCTFail()
        }
        switch otherResults[0] {
        case .success(let event):
            try evaluateEvent(event)
        case .failure:
            XCTFail()
        }
    }
    
    /// Name got two long: test case:
    /// Two reporter connected
    /// One general middleware connected
    /// Reporter A has one specific middleware
    /// Reporter B has two specific middlewares
    func testAnalyticsEventTrackingTwoReportersMultipleMiddlewares() throws {
        tentacles.register(.appendStringToName("A"))
        tentacles.register(reporter, with: [.lowercaseEventName,
                                            .appendStringToName("B")])
        let otherReporter = AnalyticsReporterStub()
        tentacles.register(otherReporter, with: [.appendStringToName("C")])
        var results = [Result<RawAnalyticsEvent, Error>]()
        var otherResults = [Result<RawAnalyticsEvent, Error>]()
        let eventsReportedExpectation = expectation(
            description: "eventsReportedExpectation")
        let otherEventsReportedExpectation = expectation(
            description: "otherEventsReportedExpectation")
        eventResultsSub = reporter.analyticsEventPublisher
            .sink { result in
                results.append(result)
                if results.count == 1 {
                    eventsReportedExpectation.fulfill()
                }
            }
        otherEventResultsSub = otherReporter.analyticsEventPublisher
            .sink { result in
                otherResults.append(result)
                if otherResults.count == 1 {
                    otherEventsReportedExpectation.fulfill()
                }
            }
        let event = AnalyticsEventStub()
        tentacles.track(event)
        wait(for: [eventsReportedExpectation,
                   otherEventsReportedExpectation], timeout: 1)
        switch results[0] {
        case .success(let event):
            XCTAssertEqual(event.name, "testaB")
        case .failure: XCTFail()
        }
        switch otherResults[0] {
        case .success(let event):
            XCTAssertEqual(event.name, "TestAC")
        case .failure: XCTFail()
        }
    }
}
