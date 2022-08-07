//
//  ValuePropositionSessionTests.swift
//  
//
//  Created by Patrick Fischer on 06.08.22.
//

import XCTest
@testable import Tentacles

final class ValuePropositionSessionTests: XCTestCase {
    private var session: ValuePropositionSession!
    override func setUpWithError() throws {
        let valueProposition = ValuePropositionStub()
        let rawValueProposition = RawValueProposition(from: valueProposition)
        session = ValuePropositionSession(
            for: rawValueProposition)
    }

    override func tearDownWithError() throws {
        session = nil
    }

    func testStatusAtInitialisation() throws {
        XCTAssertEqual(session.status, .opened)
    }
    
    func testStatusTimestampAtInitialisation() throws {
        let timestamp = Date.timeIntervalSinceReferenceDate.rounded()
        XCTAssertEqual(timestamp.rounded(), try getTimestamp(for: .opened).rounded())
    }
    
    func testTimestampPreconditions() throws {
        XCTAssertNoThrow(try getTimestamp(for: .opened))
        XCTAssertThrowsError(try getTimestamp(for: .started))
        XCTAssertThrowsError(try getTimestamp(for: .paused))
        XCTAssertThrowsError(try getTimestamp(for: .completed))
        XCTAssertThrowsError(try getTimestamp(for: .canceled))
    }
    
    func testTimestampsOfStatusChanges() throws {
        Thread.sleep(forTimeInterval: 0.0001)
        session.status = .started
        Thread.sleep(forTimeInterval: 0.0001)
        session.status = .paused
        Thread.sleep(forTimeInterval: 0.0001)
        session.status = .completed
        Thread.sleep(forTimeInterval: 0.0001)
        session.status = .canceled
        XCTAssertTrue(try statusIsMoreRecent(.started, than: .opened))
        XCTAssertTrue(try statusIsMoreRecent(.paused, than: .started))
        XCTAssertTrue(try statusIsMoreRecent(.completed , than: .paused))
        XCTAssertTrue(try statusIsMoreRecent(.canceled, than: .completed))
    }
    
    func testUUIDAfterStatusChangeIsIdentical() throws {
        let openedUUID = try getValuePropositionSessionUUID()
        session.status = .started
        let startedUUID = try getValuePropositionSessionUUID()
        XCTAssertEqual(openedUUID, startedUUID)
    }
    
    func testReset() throws {
        let openedUUID = try getValuePropositionSessionUUID()
        session.status = .started
        let _ = try getTimestamp(for: .started)
        session.reset()
        let otherOpenedUUID = try getValuePropositionSessionUUID()
        XCTAssertNotEqual(openedUUID, otherOpenedUUID)
        XCTAssertThrowsError(try getTimestamp(for: .started))
    }
    
    func testMakeRawAnalyticsEventWithAction() throws {
        let actionAttributes = KeyValueAttribute(key: "testKey", value: 123)
        let action = ValuePropositionAction(status: .open, trigger: TentaclesEventTrigger.screenDidAppear, attributes: actionAttributes)
        let event = session.makeRawAnalyticsEvent(action: action)
        try evaluateDefaultValues(event: event, status: .opened)
        /// values added by action
        let stringProperty: String = try event.getValueAttribute(
            for: TentaclesAttributesStub.Key.stringProperty)
        let doubleProperty: Double = try event.getValueAttribute(
            for: TentaclesAttributesStub.Key.doubleProperty)
        let boolProperty: Bool = try event.getValueAttribute(
            for: TentaclesAttributesStub.Key.boolProperty)
        let enumProperty: String = try event.getValueAttribute(
            for: TentaclesAttributesStub.Key.enumProperty)
        let nestedProperty: [String: AnyHashable] = try event.getValueAttribute(
            for: TentaclesAttributesStub.Key.nestedProperty)
        let nestedStringProperty: String = try event.getValue(
            in: nestedProperty,
            for: TentaclesAttributesStub.Key.stringProperty)
        let nestedDoubleProperty: Double = try event.getValue(
            in: nestedProperty,
            for: TentaclesAttributesStub.Key.doubleProperty)
        let nestedBoolProperty: Bool = try event.getValue(
            in: nestedProperty,
            for: TentaclesAttributesStub.Key.boolProperty)
        XCTAssertEqual(stringProperty, TentaclesAttributesStub.stringPropertyValue)
        XCTAssertEqual(doubleProperty, TentaclesAttributesStub.doublePropertyValue)
        XCTAssertEqual(boolProperty, TentaclesAttributesStub.boolPropertyValue)
        XCTAssertEqual(enumProperty, TentaclesAttributesStub.enumPropertyValue.rawValue)
        XCTAssertEqual(nestedStringProperty, TentaclesAttributesStub.Nested.stringPropertyValue)
        XCTAssertEqual(nestedDoubleProperty, TentaclesAttributesStub.Nested.doublePropertyValue)
        XCTAssertEqual(nestedBoolProperty, TentaclesAttributesStub.boolPropertyValue)
    }
    
    func testMakeRawAnalyticsEventWithTrigger() throws {
        let event = session.makeRawAnalyticsEvent(trigger: TentaclesEventTrigger.screenDidAppear)
        try evaluateDefaultValues(event: event, status: .opened)
    }
    
    func evaluateDefaultValues(event: RawAnalyticsEvent,
                               status: ValuePropositionSession.Status)
    throws {
        let _status: String = try event.getValueAttribute(for: KeyAttributes.status)
        let trigger: String = try event.getValueAttribute(for: KeyAttributes.trigger)
        let category: String = try event.getValueAttribute(for: KeyAttributes.category)
        let uuid: String = try event.getValueAttribute(for: KeyAttributes.valuePropositionSessionUUID)
        XCTAssertNotNil(UUID(uuidString: uuid))
        XCTAssertEqual(_status, status.rawValue)
        XCTAssertEqual(trigger, TentaclesEventTrigger.screenDidAppear.rawValue)
        XCTAssertEqual(category, TentaclesEventCategory.valueProposition.rawValue)
        XCTAssertEqual(event.name, ValuePropositionStub.name)
    }
    
    private func statusIsMoreRecent(
        _ status: ValuePropositionSession.Status,
        than otherStatus: ValuePropositionSession.Status)
    throws -> Bool {
        let timestamp = try getTimestamp(for: status)
        let otherTimestamp = try getTimestamp(for: otherStatus)
        return timestamp > otherTimestamp
    }
    
    private func getTimestamp(for status: ValuePropositionSession.Status)
    throws -> Double {
        let event = session.makeRawAnalyticsEvent(action: .open())
        return try getTimestamp(for: status, in: event)
    }
    
    private func getTimestamp(for status: ValuePropositionSession.Status,
                              in event: RawAnalyticsEvent)
    throws -> Double {
        return try event.getValueAttribute(for: status.rawValue)
    }
    
    private func getValuePropositionSessionUUID()
    throws -> String {
        let event = session.makeRawAnalyticsEvent(action: .open())
        return try getValuePropositionSessionUUID(in: event)
    }
    
    private func getValuePropositionSessionUUID(in event: RawAnalyticsEvent)
    throws -> String {
        try event.getValueAttribute(for: KeyAttributes.valuePropositionSessionUUID)
    }
}
