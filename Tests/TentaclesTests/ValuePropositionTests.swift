//
//  ValuePropositionTests.swift
//  
//
//  Created by Patrick Fischer on 23.07.22.
//

import XCTest
import Tentacles

final class ValuePropositionTests: XCTestCase {
    enum EventStatus: String {
        case opened
        case started
        case paused
        case completed
        case canceled
    }
    enum Result {
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
        tentacles = Tentacles()
        tentacles?.register(analyticsReporter: reporterStub)
        tentacles?.register(errorReporter: reporterStub)
        let attributes = WatchingVideoValueProposition
            .Attributes(videoName: videoName, language: language, duration: duration)
        watchingVideovalueProposition = WatchingVideoValueProposition(attributes: attributes)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        tentacles = nil
        watchingVideovalueProposition = nil
        reporterStub = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testOpenPauseCompleteEvents() throws {
        testValueProposition(for: [.open(),.pause(), .complete()],
                             with: [.success, .error, .error],
                             numberOfEventsThatShouldBeReported: 1)
    }
    
    func testOpenStartCompleteEvents() throws {
        testValueProposition(for: [.open(),.start(),.complete()],
                             with: [.success, .success, .success],
                             numberOfEventsThatShouldBeReported: 3)
    }
    
    func testOpenStartPauseStartCompleteEvents() throws {
        testValueProposition(for: [.open(), .start(), .pause(), .start(), .complete()],
                             with: [.success, .success, .success, .success, .success],
                             numberOfEventsThatShouldBeReported: 5)
    }
    
    func testOpenStartPauseStartPauseStartCompleteEvents() throws {
        testValueProposition(for: [.open(),.start(),.pause(),.start(),.pause(),.start(),.complete()],
                             with: [.success, .success, .success, .success, .success, .success, .success],
                             numberOfEventsThatShouldBeReported: 7)
    }
    
    func testOpenStartPauseStartPauseStartCancelEvents() throws {
        testValueProposition(for: [.open(),.start(),.pause(),.start(),.pause(),.start(),.cancel()],
                             with: [.success, .success, .success, .success, .success, .success, .success],
                             numberOfEventsThatShouldBeReported: 7)
    }
    
    func testOpenStartCancelEvents() throws {
        testValueProposition(for: [.open(),.start(),.cancel()],
                             with: [.success, .success, .success],
                             numberOfEventsThatShouldBeReported: 3)
    }
    
    func testStartCompleteEvents() throws {
        testValueProposition(for: [.start(), .complete()],
                             with: [.error, .error],
                             numberOfEventsThatShouldBeReported: 0)
    }
    
    func testStartCancelEvents() throws {
        testValueProposition(for: [.start(),.cancel()],
                             with: [.error, .error],
                             numberOfEventsThatShouldBeReported: 0)
    }
    
    func testOpenEvent() throws {
        testValueProposition(for: [.open()],
                             with: [.success],
                             numberOfEventsThatShouldBeReported: 1)
    }
    
    func testOpenCancelEvent() throws {
        testValueProposition(for: [.open(), .cancel()],
                             with: [.success, .success],
                             numberOfEventsThatShouldBeReported: 2)
    }
    
    func testOpenCompleteEvent() throws {
        testValueProposition(for: [.open(), .complete()],
                             with: [.success, .error],
                             numberOfEventsThatShouldBeReported: 1)
    }
    
    func testOpenPauseEvent() throws {
        testValueProposition(for: [.open(), .pause()],
                             with: [.success, .error],
                             numberOfEventsThatShouldBeReported: 1)
    }
    
    func testStartEvent() throws {
        testValueProposition(for: [.open()],
                             with: [.success],
                             numberOfEventsThatShouldBeReported: 1)
    }
    
    func testPauseEvent() throws {
        testValueProposition(for: [.pause()],
                             with: [.error],
                             numberOfEventsThatShouldBeReported: 0)
    }
    
    func testCancelEvent() throws {
        testValueProposition(for: [.cancel()],
                             with: [.error],
                             numberOfEventsThatShouldBeReported: 0)
    }
    
    func testCompleteEvent() throws {
        testValueProposition(for: [.cancel()],
                             with: [.error],
                             numberOfEventsThatShouldBeReported: 0)
    }
    
    func testDeallocationAfterCancel() throws {
        
    }
    
    func testDeallocationAfterComplete() throws {
        
    }
    
    /// events derived from the same session share the same uuid
    func testRelationBetweenEvents() throws {
        
    }
    
    func testValueProposition(for actions: [ValuePropositionAction],
                              with expectedResults: [Result],
                              numberOfEventsThatShouldBeReported: Int) {
        testPreConditionCeroEventsReported()
        trackValueProposition(for: actions)
        let statuses = actions.map { action -> EventStatus in
            switch action.status {
            case .open: return .opened
            case .start: return .started
            case .pause: return .paused
            case .complete: return .completed
            case .cancel: return .canceled
            }
        }
        statuses.enumerated().forEach { index, status in
            let result = expectedResults[index]
            evaluateEvent(for: status,
                          with: result,
                          at: index)
        }
        evaluateNumberOfEventsReported(numberOfEventsThatShouldBeReported)
    }
    
    func trackValueProposition(for actions: [ValuePropositionAction]) {
        trackValueProposition(for: watchingVideovalueProposition, with: actions)
    }
    
    func trackValueProposition(for valueProposition: some ValueProposition,
                               with actions: [ValuePropositionAction]) {
        actions.forEach { tentacles.track(for: valueProposition, with: $0) }
    }
    
    func evaluateEvent(for status: EventStatus,
                       with result: Result,
                       at index: Int) {
        let event = reporterStub.results[index]
        switch result {
        case .success:
            if let event = event as? RawAnalyticsEvent {
                evaluate(event: event, for: status)
            }
        case .error:
            if let error = event as? Error {
                print(error.localizedDescription)
            }
        }
    }
    
    func testPreConditionCeroEventsReported() {
        XCTAssertEqual(reporterStub.results.count, 0)
    }
    
    func evaluateNumberOfEventsReported(_ count: Int) {
        let countAnalyticsEvents = reporterStub.results.filter { ($0 as? RawAnalyticsEvent) != nil }.count
        XCTAssertEqual(countAnalyticsEvents, count)
    }
    
    func evaluate(event: RawAnalyticsEvent, for status: EventStatus) {
        XCTAssertEqual(event.name,"watchingVideo")
        XCTAssertEqual(event.attributes["duration"] as? Double, duration)
        XCTAssertEqual(event.attributes["videoName"] as? String, videoName)
        XCTAssertEqual(event.attributes["language"] as? String, language)
        XCTAssertEqual(event.attributes["category"] as? String, .valueProposition)
        XCTAssertEqual(event.attributes["trigger"] as? String, .clicked)
        XCTAssertEqual(event.attributes["status"] as? String, status.rawValue)
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
    
    func extractUUIDFromEvent(event: any AnalyticsEvent) -> UUID? {
        let attributesSession = event.otherAttributes?.serialiseToValue()["valuePropostionAttributes"] as? [String: AnyHashable]
        let attributesValuePropostion = attributesSession?["uuid"] as? UUID
        return attributesValuePropostion
    }
}
