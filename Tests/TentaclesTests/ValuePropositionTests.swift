//
//  ValuePropositionTests.swift
//  
//
//  Created by Patrick Fischer on 23.07.22.
//

import XCTest
import Tentacles
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

final class ValuePropositionTests: XCTestCase {
    private enum EventStatus: String {
        case opened
        case started
        case paused
        case completed
        case canceled
    }
    private enum Result {
        case success
        case error
    }
    private let videoName = "Learning Swift"
    private let language = "English"
    private let duration = 3569.0
    private var tentacles: Tentacles!
    private var watchingVideovalueProposition: WatchingVideoValueProposition!
    private var reporterStub: AnalyticsReporterStub!
    override func setUpWithError() throws {
        reporterStub = AnalyticsReporterStub()
        tentacles = buildTentacles(analyticsReporters: [reporterStub],
                                   errorReporters: [reporterStub])
        let attributes = WatchingVideoValueProposition
            .Attributes(videoName: videoName, language: language, duration: duration)
        watchingVideovalueProposition = WatchingVideoValueProposition(attributes: attributes)
    }
    
    override func tearDownWithError() throws {
        tentacles = nil
        watchingVideovalueProposition = nil
        reporterStub = nil
    }
    
    func testOpenStartCompleteEvents() throws {
        testValueProposition(watchingVideovalueProposition,
                             for: [.open(),.start(),.complete()],
                             with: [.success, .success, .success],
                             numberOfEventsThatShouldBeReported: 3)
    }
    
    func testOpenPauseCompleteEvents() throws {
        testValueProposition(watchingVideovalueProposition,
                             for: [.open(),.pause(), .complete()],
                             with: [.success, .error, .error],
                             numberOfEventsThatShouldBeReported: 1)
    }
    
    func testOpenStartPauseStartCompleteEvents() throws {
        testValueProposition(watchingVideovalueProposition,
                             for: [.open(), .start(), .pause(), .start(), .complete()],
                             with: [.success, .success, .success, .success, .success],
                             numberOfEventsThatShouldBeReported: 5)
    }
    
    func testOpenStartPauseStartPauseStartCompleteEvents() throws {
        testValueProposition(watchingVideovalueProposition,
                             for: [.open(),.start(),.pause(),.start(),.pause(),.start(),.complete()],
                             with: [.success, .success, .success, .success, .success, .success, .success],
                             numberOfEventsThatShouldBeReported: 7)
    }
    
    func testOpenStartPauseStartPauseStartCancelEvents() throws {
        testValueProposition(watchingVideovalueProposition,
                             for: [.open(),.start(),.pause(),.start(),.pause(),.start(),.cancel()],
                             with: [.success, .success, .success, .success, .success, .success, .success],
                             numberOfEventsThatShouldBeReported: 7)
    }
    
    func testOpenStartCancelEvents() throws {
        testValueProposition(watchingVideovalueProposition,
                             for: [.open(),.start(),.cancel()],
                             with: [.success, .success, .success],
                             numberOfEventsThatShouldBeReported: 3)
    }
    
    func testStartCompleteEvents() throws {
        testValueProposition(watchingVideovalueProposition,
                             for: [.start(), .complete()],
                             with: [.error, .error],
                             numberOfEventsThatShouldBeReported: 0)
    }
    
    func testStartCancelEvents() throws {
        testValueProposition(watchingVideovalueProposition,
                             for: [.start(),.cancel()],
                             with: [.error, .error],
                             numberOfEventsThatShouldBeReported: 0)
    }
    
    func testOpenEvent() throws {
        testValueProposition(watchingVideovalueProposition,
                             for: [.open()],
                             with: [.success],
                             numberOfEventsThatShouldBeReported: 1)
    }
    
    func testOpenCancelEvent() throws {
        testValueProposition(watchingVideovalueProposition,
                             for: [.open(), .cancel()],
                             with: [.success, .success],
                             numberOfEventsThatShouldBeReported: 2)
    }
    
    func testOpenCompleteEvent() throws {
        testValueProposition(watchingVideovalueProposition,
                             for: [.open(), .complete()],
                             with: [.success, .error],
                             numberOfEventsThatShouldBeReported: 1)
    }
    
    func testOpenPauseEvent() throws {
        testValueProposition(watchingVideovalueProposition,
                             for: [.open(), .pause()],
                             with: [.success, .error],
                             numberOfEventsThatShouldBeReported: 1)
    }
    
    func testStartEvent() throws {
        testValueProposition(watchingVideovalueProposition,
                             for: [.open()],
                             with: [.success],
                             numberOfEventsThatShouldBeReported: 1)
    }
    
    func testPauseEvent() throws {
        testValueProposition(watchingVideovalueProposition,
                             for: [.pause()],
                             with: [.error],
                             numberOfEventsThatShouldBeReported: 0)
    }
    
    func testCancelEvent() throws {
        testValueProposition(watchingVideovalueProposition,
                             for: [.cancel()],
                             with: [.error],
                             numberOfEventsThatShouldBeReported: 0)
    }
    
    func testCompleteEvent() throws {
        testValueProposition(watchingVideovalueProposition,
                             for: [.cancel()],
                             with: [.error],
                             numberOfEventsThatShouldBeReported: 0)
    }
    
    func testDeallocationAfterCancel() throws {
        testValueProposition(watchingVideovalueProposition,
                             for: [.open(),.cancel(),.open()],
                             with: [.success,.success,.success],
                             numberOfEventsThatShouldBeReported: 3)
        XCTAssertTrue(isSessionSimilar(at: 0, and: 1))
        XCTAssertFalse(isSessionSimilar(at: 1, and: 2))
    }
    
    func testDeallocationAfterComplete() throws {
        testValueProposition(watchingVideovalueProposition,
                             for: [.open(),.start(),.complete(),.open()],
                             with: [.success,.success,.success,.success],
                             numberOfEventsThatShouldBeReported: 4)
        XCTAssertTrue(isSessionSimilar(at: 0, and: 2))
        XCTAssertFalse(isSessionSimilar(at: 2, and: 3))
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
        evaluatePreConditionCeroEventsReported()
        trackValueProposition(watchingVideovalueProposition,
                              for: [.open(),.start()])
        NotificationCenter.default.post(name: willResignActivePostNotification,
                                        object: nil)
        evaluateEvent(for: .opened, with: .success, at: 0)
        evaluateEvent(for: .started, with: .success, at: 1)
        evaluateEvent(for: .canceled, with: .success, trigger: .willResignActive, at: 2)
        NotificationCenter.default.post(name: didBecomeActivePostNotification, object: nil)
        evaluateEvent(for: .started, with: .success, trigger: .didEnterForeground, at: 3)

        evaluateNumberOfEventsReported(4)
    }
    #endif
    
    /// events derived from the same session share the same uuid
    func testRelationBetweenEvents() throws {
        testValueProposition(watchingVideovalueProposition,
                             for: [.open(), .start()],
                             with: [.success,.success],
                             numberOfEventsThatShouldBeReported: 2)
        XCTAssertTrue(isSessionSimilar(at: 0, and: 1))
    }
    
    func testDifferentValuePropositions() throws {
        evaluatePreConditionCeroEventsReported()
        let attributes = WatchingVideoValueProposition.Attributes(videoName: "Studying SwiftUI",
                                                                  language: "English",
                                                                  duration: 435)
        let otherValueProposition = WatchingVideoValueProposition(attributes: attributes)
        trackValueProposition(watchingVideovalueProposition, for: [.open(),.start(),.complete()])
        trackValueProposition(otherValueProposition, for: [.open(),.start(),.complete()])
        XCTAssertTrue(isSessionSimilar(at: 0, and: 2))
        XCTAssertFalse(isSessionSimilar(at: 0, and: 3))
        XCTAssertTrue(isSessionSimilar(at: 3, and: 5))
        evaluateNumberOfEventsReported(6)
    }
    
    func testValuePropositionIsEqual() throws {
        let isEqual = WatchingVideoValueProposition.stub
            .isEqual(to: WatchingVideoValueProposition.stub)
        XCTAssertTrue(isEqual)
    }
    
    func testValuePropositionIsNotEqual() throws {
        let isNotEqual = WatchingVideoValueProposition.stub
            .isEqual(to: CommentingValueProposition.stub)
        XCTAssertFalse(isNotEqual)
    }
    
    private func testValueProposition(_ valueProposition: some ValueProposition,
                              for actions: [ValuePropositionAction],
                              with expectedResults: [Result],
                              numberOfEventsThatShouldBeReported: Int) {
        evaluatePreConditionCeroEventsReported()
        trackValueProposition(valueProposition, for: actions)
        let statuses = actions.map { action -> EventStatus in
            switch action.status {
            case .open: return .opened
            case .start: return .started
            case .pause: return .paused
            case .complete: return .completed
            case .cancel: return .canceled
            }
        }
        evaluateEvents(for: statuses, with: expectedResults)
        evaluateNumberOfEventsReported(numberOfEventsThatShouldBeReported)
    }
    
    private func trackValueProposition(_ valueProposition: some ValueProposition,
                               for actions: [ValuePropositionAction]) {
        trackValueProposition(for: valueProposition, with: actions)
    }
    
    private func trackValueProposition(for valueProposition: some ValueProposition,
                               with actions: [ValuePropositionAction]) {
        actions.forEach { tentacles.track(for: valueProposition, with: $0) }
    }
    
    private func evaluateEvents(for statuses: [EventStatus],
                        with expectedResults: [Result]) {
        statuses.enumerated().forEach { index, status in
            let result = expectedResults[index]
            evaluateEvent(for: status,
                          with: result,
                          at: index)
        }
    }
    
    private func evaluateEvent(for status: EventStatus,
                       with result: Result,
                       trigger: TentaclesEventTrigger = .clicked,
                       at index: Int) {
        switch result {
        case .success:
            if let event = reporterStub.isResultEvent(index: index) {
                evaluate(event: event, for: status, trigger: trigger)
            }
        case .error:
            if let error = reporterStub.isResultError(index: index) {
                print(error.localizedDescription)
            }
        }
    }
    
    private func isSessionSimilar(at index: Int, and otherIndex: Int) -> Bool {
        guard let event = reporterStub.results[index] as? RawAnalyticsEvent,
           let otherEvent = reporterStub.results[otherIndex] as? RawAnalyticsEvent else { return false }
        return event.attributes["uuid"] == otherEvent.attributes["uuid"]
    }
    
    private func evaluatePreConditionCeroEventsReported() {
        evaluatePreConditionCeroEventsReported(reporterStub: reporterStub)
    }
    
    private func evaluateNumberOfEventsReported(_ count: Int) {
        evaluateNumberOfEventsReported(count, for: reporterStub)
    }
    
    private func evaluate(event: RawAnalyticsEvent,
                  for status: EventStatus,
                  trigger: TentaclesEventTrigger = .clicked) {
        XCTAssertEqual(event.name,"watchingVideo")
        XCTAssertEqual(event.attributes["duration"] as? Double, duration)
        XCTAssertEqual(event.attributes["videoName"] as? String, videoName)
        XCTAssertEqual(event.attributes["language"] as? String, language)
        XCTAssertEqual(event.attributes["category"] as? String, TentaclesEventCategory.valueProposition.name)
        XCTAssertEqual(event.attributes["trigger"] as? String, trigger.rawValue)
        XCTAssertEqual(event.attributes["status"] as? String, status.rawValue)
    }
}
