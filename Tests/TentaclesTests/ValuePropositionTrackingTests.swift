//
//  DomainActivityTests.swift
//  
//
//  Created by Patrick Fischer on 23.07.22.
//

import Combine
import XCTest
import Tentacles
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

final class DomainActivityTests: XCTestCase {
    private enum EventStatus: String {
        case opened
        case started
        case paused
        case completed
        case canceled
    }
    
    /// Used to indicate if the state machine of DomainActivitySessionManager is expected to return a
    /// successful result or an error.
    private enum ExpectedResult: Equatable {
        case success
        case error
    }
    private let videoName = "Learning Swift"
    private let language = "English"
    private let duration = 3569.0
    private let watchVideo = "watchVideo"
    private var tentacles: Tentacles!
    private var watchingVideoDomainActivity: WatchingVideoDomainActivity!
    private var reporterStub: AnalyticsReporterStub!
    private var resultsSubscription: AnyCancellable?
    override func setUpWithError() throws {
        reporterStub = AnalyticsReporterStub()
        tentacles = buildTentacles(analyticsReporters: [reporterStub],
                                   errorReporters: [reporterStub])
        let attributes = WatchingVideoAttributes(videoName: videoName, language: language, duration: duration)
        watchingVideoDomainActivity = WatchingVideoDomainActivity(name: watchVideo, attributes: attributes)
    }
    
    override func tearDownWithError() throws {
        tentacles = nil
        watchingVideoDomainActivity = nil
        reporterStub = nil
        resultsSubscription = nil
    }
    
    func testOpenEvent() throws {
        let _ = testWatchVideoDomainActivity(for: [.open()],
                                               with: [.success])
    }
    
    func testOpenOpenEvent() throws {
        let _ = testWatchVideoDomainActivity(for: [.open(), .open()],
                                               with: [.success, .error])
    }
    
    func testOpenCancelEvent() throws {
        let _ = testWatchVideoDomainActivity(for: [.open(), .cancel()],
                                               with: Array(repeating: .success, count: 2))
    }
    
    func testOpenCompleteEvent() throws {
        let _ = testWatchVideoDomainActivity(for: [.open(), .complete()],
                                               with: [.success, .error])
    }
    
    func testOpenPauseEvent() throws {
        let _ = testWatchVideoDomainActivity(for: [.open(), .pause()],
                                               with: [.success, .error])
    }
    
    func testOpenStartCompleteEvents() throws {
        let _ = testWatchVideoDomainActivity(for: [.open(),.start(),.complete()],
                                               with: Array(repeating: .success, count: 3))
    }
    
    func testOpenPauseCompleteEvents() throws {
        let _ = testWatchVideoDomainActivity(for: [.open(),.pause(), .complete()],
                                               with: [.success, .error, .error])
    }
    
    func testOpenStartPauseStartCompleteEvents() throws {
        let _ = testWatchVideoDomainActivity(for: [.open(), .start(), .pause(), .start(), .complete()],
                                               with: Array(repeating: .success, count: 5))
    }
    
    func testOpenStartPauseStartPauseStartCompleteEvents() throws {
        let _ = testWatchVideoDomainActivity(for: [.open(),.start(),.pause(),.start(),.pause(),.start(),.complete()],
                                               with: Array(repeating: .success, count: 7))
    }
    
    func testOpenStartPauseStartPauseStartCancelEvents() throws {
        let _ = testWatchVideoDomainActivity(for: [.open(),.start(),.pause(),.start(),.pause(),.start(),.cancel()],
                                               with: Array(repeating: .success, count: 7))
    }
    
    func testOpenStartCancelEvents() throws {
        let _ = testWatchVideoDomainActivity(for: [.open(),.start(),.cancel()],
                                               with: Array(repeating: .success, count: 3))
    }
    
    func testStartEvent() throws {
        let _ = testWatchVideoDomainActivity(for: [.start()],
                                               with: [.error])
    }
    
    func testStartCompleteEvents() throws {
        let _ = testWatchVideoDomainActivity(for: [.start(), .complete()],
                                               with: Array(repeating: .error, count: 2))
    }
    
    func testStartCancelEvents() throws {
        let _ = testWatchVideoDomainActivity(for: [.start(),.cancel()],
                                               with: Array(repeating: .error, count: 2))
    }
    
    func testPauseEvent() throws {
        let _ = testWatchVideoDomainActivity(for: [.pause()],
                                               with: [.error])
    }
    
    func testCancelEvent() throws {
        let _ = testWatchVideoDomainActivity(for: [.cancel()],
                                               with: [.error])
    }
    
    func testCompleteEvent() throws {
        let _ = testWatchVideoDomainActivity(for: [.cancel()],
                                               with: [.error])
    }
    
    func testDeallocationAfterCancel() throws {
        let results = testWatchVideoDomainActivity(
            for: [.open(),.cancel(),.open()],
            with: Array(repeating: .success, count: 3))
        XCTAssertTrue(isSessionSimilar(at: 0, and: 1, results: results))
        XCTAssertFalse(isSessionSimilar(at: 1, and: 2, results: results))
    }
    
    func testDeallocationAfterComplete() throws {
        let results = testWatchVideoDomainActivity(
            for: [.open(),.start(),.complete(),.open()],
            with: Array(repeating: .success, count: 4))
        XCTAssertTrue(isSessionSimilar(at: 0, and: 2, results: results))
        XCTAssertFalse(isSessionSimilar(at: 2, and: 3, results: results))
    }
    
        #if canImport(UIKit) || canImport(AppKit)
        func testAppLifecycleFromBackgroundToForeground() throws {
            #if canImport(AppKit)
            let willResignActivePostNotification = NSApplication.willResignActiveNotification
            let didBecomeActivePostNotification = NSApplication.didBecomeActiveNotification
            #endif
            #if canImport(UIKit)
            let willResignActivePostNotification = UIApplication.willResignActiveNotification
            let didBecomeActivePostNotification = UIApplication.didBecomeActiveNotification
            #endif
            var results = [Swift.Result<RawAnalyticsEvent, Error>]()
            let expectation = expectation(description: "numberOfExpectedResults")
            resultsSubscription = reporterStub.analyticsEventPublisher.sink { result in
                results.append(result)
                if results.count == 5 {
                    expectation.fulfill()
                }
            }
            trackDomainActivity(for: watchingVideoDomainActivity, with: [.open(),.start()])
            Thread.sleep(forTimeInterval: TimeInterval.random(in: 0...0.010))
            NotificationCenter.default.post(name: willResignActivePostNotification, object: nil)
            Thread.sleep(forTimeInterval: TimeInterval.random(in: 0...0.010))
            NotificationCenter.default.post(name: didBecomeActivePostNotification, object: nil)
            wait(for: [expectation], timeout: 3)
            let events = evaluateResults(results, with: Array(repeating: .success, count: 5))
            evaluate(event: events[0], for: .opened, trigger: .clicked)
            evaluate(event: events[1], for: .started, trigger: .clicked)
            evaluate(event: events[2], for: .canceled, trigger: .willResignActive)
            evaluate(event: events[3], for: .opened, trigger: .didEnterForeground)
            evaluate(event: events[4], for: .started, trigger: .didEnterForeground)

            func evaluate(event: RawAnalyticsEvent, for status: EventStatus, trigger: TentaclesEventTrigger) {
                self.evaluate(event: event, for: status, trigger: trigger, name: watchingVideoDomainActivity.name,
                         videoName: videoName, language: language)
            }
        }
        #endif
    
    /// events derived from the same session share the same uuid
    func testRelationBetweenEvents() throws {
        let results = testWatchVideoDomainActivity(for: [.open(), .start()],
                                                     with: [.success,.success])
        XCTAssertTrue(isSessionSimilar(at: 0, and: 1, results: results))
    }
    
    func testDomainActivitysAreEqual() throws {
        let domainActivity = DomainActivityStub()
        let otherDomainActivity = DomainActivityStub()
        let isEqual = domainActivity == otherDomainActivity
        XCTAssertTrue(isEqual)
    }
    
    func testDomainActivitysAreNotEqual() throws {
        let domainActivity = DomainActivityStub()
        let otherDomainActivity = DomainActivityStub(name: "Other")
        let isEqual = domainActivity == otherDomainActivity
        XCTAssertFalse(isEqual)
    }
    
    func testManagingOfTwoNonEqualDomainActivitys() throws {
        let otherVideoName = "Studying SwiftUI"
        let otherLanguage = "German"
        let attributes = WatchingVideoAttributes(videoName: otherVideoName,
                        language: otherLanguage,
                        duration: 435)
        let otherDomainActivity = WatchingVideoDomainActivity(name: watchVideo, attributes: attributes)
        let expectedResults: [ExpectedResult] = [.success,.success,.success]
        let results = testWatchVideoDomainActivity(for: [.open(),.start(),.complete()],
                                                     with: expectedResults)
        let otherExpectedResults: [ExpectedResult] = [.success,.success,.success]
        let otherResults = testDomainActivity(otherDomainActivity,
                                                for: [.open(),.start(),.complete()],
                                                with: otherExpectedResults,
                                                videoName: otherVideoName,
                                                language: otherLanguage)
        XCTAssertTrue(isSessionSimilar(rhs: results[0], lhs: results[2]))
        XCTAssertFalse(isSessionSimilar(rhs: results[0], lhs: otherResults[0]))
        XCTAssertTrue(isSessionSimilar(rhs: otherResults[0], lhs: otherResults[2]))
        let eventCount = evaluateResults(results, with: expectedResults).count
        let otherEventCount = evaluateResults(otherResults, with: otherExpectedResults).count
        evaluateNumberOfEventsReported(count: (eventCount + otherEventCount),
                                       expectedCount: 6)
    }
    
    private func testWatchVideoDomainActivity(for actions: [DomainActivityAction],
                                                with expectedResults: [ExpectedResult])
    -> [Swift.Result<RawAnalyticsEvent, Error>] {
        testDomainActivity(watchingVideoDomainActivity,
                             for: actions,
                             with: expectedResults,
                             videoName: videoName,
                             language: language)
    }
    
    private func testDomainActivity(
        _ domainActivity: DomainActivity<some TentaclesAttributes>,
        for actions: [DomainActivityAction],
        with expectedResults: [ExpectedResult],
        videoName: String,
        language: String)
    -> [Swift.Result<RawAnalyticsEvent, Error>] {
        var results = [Swift.Result<RawAnalyticsEvent, Error>]()
        let expectation = expectation(description: "numberOfExpectedResults")
        resultsSubscription = reporterStub.analyticsEventPublisher.sink { result in
            results.append(result)
            if results.count == actions.count {
                expectation.fulfill()
            }
        }
        trackDomainActivity(for: domainActivity, with: actions)
        let statuses = actions.map { action -> EventStatus in
            switch action.status {
            case .open: return .opened
            case .start: return .started
            case .pause: return .paused
            case .complete: return .completed
            case .cancel: return .canceled
            }
        }
        wait(for: [expectation], timeout: 3)
        let eventIndexes = evaluateResults(results, with: expectedResults).enumerated().map { $0.offset }
        for index in eventIndexes {
            let result = results[index]
            switch result {
            case .success(let event):
                let status = statuses[index]
                evaluate(event: event,
                         for: status,
                         name: domainActivity.name,
                         videoName: videoName,
                         language: language)
            case .failure:
                XCTAssertTrue(false)
            }
        }
        let numberOfEventsThatShouldBeReported = expectedResults
            .filter { $0 == .success }.count
        evaluateNumberOfEventsReported(count: eventIndexes.count,
                                       expectedCount: numberOfEventsThatShouldBeReported)
        return results
    }
    
    
    private func trackDomainActivity(for domainActivity: DomainActivity<some TentaclesAttributes>,
                                       with actions: [DomainActivityAction]) {
        for action in actions {
            tentacles.track(domainActivity, with: action)
        }
    }
    
    /// - Returns: Indexes of results that contain successful events, successful means it is not an error.
    private func evaluateResults(_ results: [Swift.Result<RawAnalyticsEvent,Error>],
                                 with expectedResults: [ExpectedResult]) -> [RawAnalyticsEvent] {
        var events = [RawAnalyticsEvent]()
        results.enumerated().forEach { index, result in
            let expectedResult = expectedResults[index]
            if let event = evaluateResult(result,
                                      with: expectedResult) {
                events.append(event)
            }
        }
        return events
    }
    
    private func evaluateResult(_ result: Swift.Result<RawAnalyticsEvent,Error>,
                                with expectedResult: ExpectedResult) -> RawAnalyticsEvent? {
        switch result {
        case .success(let event):
            XCTAssertEqual(expectedResult, .success)
            return event
        case .failure:
            XCTAssertEqual(expectedResult, .error)
            return nil
        }
    }
    
    private func isSessionSimilar(at index: Int,
                                  and otherIndex: Int,
                                  results: [Swift.Result<RawAnalyticsEvent, Error>])
    -> Bool {
        let result = results[index]
        let otherResult = results[otherIndex]
        return isSessionSimilar(rhs: result, lhs: otherResult)
    }
    
    private func isSessionSimilar(rhs: Swift.Result<RawAnalyticsEvent, Error>,
                                  lhs: Swift.Result<RawAnalyticsEvent, Error>) -> Bool {
        switch (rhs, lhs) {
        case (.success(let event), .success(let otherEvent)):
            return event.attributes[KeyAttributes.domainActivitySessionUUID]
            == otherEvent.attributes[KeyAttributes.domainActivitySessionUUID]
        default:
            return false
        }
    }
    
    private func evaluateNumberOfEventsReported(count: Int, expectedCount: Int) {
        XCTAssertEqual(count, expectedCount)
    }
    
    private func evaluate(event: RawAnalyticsEvent,
                          for status: EventStatus,
                          trigger: TentaclesEventTrigger = .clicked,
                          name: String,
                          videoName: String,
                          language: String) {
        XCTAssertEqual(event.name, name)
        XCTAssertEqual(event.attributes["videoName"] as? String, videoName)
        XCTAssertEqual(event.attributes["language"] as? String, language)
        XCTAssertEqual(event.attributes[KeyAttributes.category]
                       as? String, TentaclesEventCategory.domainActivity.name)
        XCTAssertEqual(event.attributes[KeyAttributes.trigger]
                       as? String, trigger.rawValue)
        XCTAssertEqual(event.attributes[KeyAttributes.status]
                       as? String, status.rawValue)
    }
}
