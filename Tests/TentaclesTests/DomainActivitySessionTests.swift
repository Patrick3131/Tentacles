//
//  DomainActivitySessionTests.swift
//  
//
//  Created by Patrick Fischer on 06.08.22.
//

import XCTest
@testable import Tentacles

final class DomainActivitySessionTests: XCTestCase {
    private var session: DomainActivitySession!
    override func setUpWithError() throws {
        let domainActivity = DomainActivityStub()
        let rawDomainActivity = RawDomainActivity(from: domainActivity)
        session = DomainActivitySession(
            for: rawDomainActivity)
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
        let openedUUID = try getDomainActivitySessionUUID()
        session.status = .started
        let startedUUID = try getDomainActivitySessionUUID()
        XCTAssertEqual(openedUUID, startedUUID)
    }
    
    func testReset() throws {
        let openedUUID = try getDomainActivitySessionUUID()
        session.status = .started
        let _ = try getTimestamp(for: .started)
        session.reset()
        let otherOpenedUUID = try getDomainActivitySessionUUID()
        XCTAssertNotEqual(openedUUID, otherOpenedUUID)
        XCTAssertThrowsError(try getTimestamp(for: .started))
    }
    
    func testMakeRawAnalyticsEventWithAction() throws {
        let testKey = "testKey"
        let testValue = 123
        let actionAttributes = KeyValueAttribute(key: testKey, value: testValue)
        let action = DomainActivityAction(status: .open, trigger: TentaclesEventTrigger.screenDidAppear, attributes: actionAttributes)
        let event = try session.makeRawAnalyticsEvent(action: action)
        try evaluateDefaultValues(event: event, status: .opened)
        let stringProperty: String = try event.getAttributeValue(
            for: TentaclesAttributesStub.Key.stringProperty)
        let doubleProperty: Double = try event.getAttributeValue(
            for: TentaclesAttributesStub.Key.doubleProperty)
        let boolProperty: Bool = try event.getAttributeValue(
            for: TentaclesAttributesStub.Key.boolProperty)
        let enumProperty: String = try event.getAttributeValue(
            for: TentaclesAttributesStub.Key.enumProperty)
        let nestedProperty: [String: AnyHashable] = try event.getAttributeValue(
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
        let actionValue: Int = try event.getAttributeValue(for: testKey)
        XCTAssertEqual(stringProperty, TentaclesAttributesStub.stringPropertyValue)
        XCTAssertEqual(doubleProperty, TentaclesAttributesStub.doublePropertyValue)
        XCTAssertEqual(boolProperty, TentaclesAttributesStub.boolPropertyValue)
        XCTAssertEqual(enumProperty, TentaclesAttributesStub.enumPropertyValue.rawValue)
        XCTAssertEqual(nestedStringProperty, TentaclesAttributesStub.Nested.stringPropertyValue)
        XCTAssertEqual(nestedDoubleProperty, TentaclesAttributesStub.Nested.doublePropertyValue)
        XCTAssertEqual(nestedBoolProperty, TentaclesAttributesStub.boolPropertyValue)
        XCTAssertEqual(actionValue, testValue)
        /**
         Keys that should be available for this event.
         ["testKey", "status", "enumProperty", "stringProperty", "category", "boolProperty", "trigger", "domainActivitySessionId", "doubleProperty", "opened", "nestedProperty"]
         */
        XCTAssertEqual(event.attributes.keys.count, 11)
    }
    
    func testMakeRawAnalyticsEventWithTrigger() throws {
        let event = try session.makeRawAnalyticsEvent(trigger: TentaclesEventTrigger.screenDidAppear)
        try evaluateDefaultValues(event: event, status: .opened)
        XCTAssertEqual(event.attributes.keys.count, 10)
    }
    
    func evaluateDefaultValues(event: RawAnalyticsEvent,
                               status: DomainActivitySession.Status)
    throws {
        let _status: String = try event.getAttributeValue(for: KeyAttributes.status)
        let trigger: String = try event.getAttributeValue(for: KeyAttributes.trigger)
        let category: String = try event.getAttributeValue(for: KeyAttributes.category)
        let uuid: String = try event.getAttributeValue(for: KeyAttributes.domainActivitySessionUUID)
        XCTAssertNotNil(UUID(uuidString: uuid))
        XCTAssertEqual(_status, status.rawValue)
        XCTAssertEqual(trigger, TentaclesEventTrigger.screenDidAppear.rawValue)
        XCTAssertEqual(category, TentaclesEventCategory.domainActivity.rawValue)
        XCTAssertEqual(event.name, DomainActivityStub.name)
    }
    
    private func statusIsMoreRecent(
        _ status: DomainActivitySession.Status,
        than otherStatus: DomainActivitySession.Status)
    throws -> Bool {
        let timestamp = try getTimestamp(for: status)
        let otherTimestamp = try getTimestamp(for: otherStatus)
        return timestamp > otherTimestamp
    }
    
    private func getTimestamp(for status: DomainActivitySession.Status)
    throws -> Double {
        let event = try session.makeRawAnalyticsEvent(action: .open())
        return try getTimestamp(for: status, in: event)
    }
    
    private func getTimestamp(for status: DomainActivitySession.Status,
                              in event: RawAnalyticsEvent)
    throws -> Double {
        return try event.getAttributeValue(for: status.rawValue)
    }
    
    private func getDomainActivitySessionUUID()
    throws -> String {
        let event =  try session.makeRawAnalyticsEvent(action: .open())
        return try getDomainActivitySessionUUID(in: event)
    }
    
    private func getDomainActivitySessionUUID(in event: RawAnalyticsEvent)
    throws -> String {
        try event.getAttributeValue(for: KeyAttributes.domainActivitySessionUUID)
    }
}
