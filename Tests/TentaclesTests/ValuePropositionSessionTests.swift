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
        let rawValueProposition = RawValueProposition(valueProposition: valueProposition)
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
        
    }
    
    func testMakeRawAnayticsEventWithTrigger() throws {
        
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
        guard let timestamp = (event.attributes[status.rawValue] as? Double) else {
            throw NSError(domain: "Timestamp for \(status) status not available", code: 0)
        }
        return timestamp
    }
    
    private func getValuePropositionSessionUUID()
    throws -> String {
        let event = session.makeRawAnalyticsEvent(action: .open())
        return try getValuePropositionSessionUUID(in: event)
    }
    
    private func getValuePropositionSessionUUID(in event: RawAnalyticsEvent)
    throws -> String {
        guard let uuid = (event.attributes[KeyAttributes.valuePropositionSessionUUID] as? String) else {
            throw NSError(domain: "UUID not available, this might not be a event derived by a ValueProposition", code: 1)
        }
        return uuid
    }
    
    private func getValue<T>(in event: RawAnalyticsEvent,
                             for key: String) throws -> T {
        guard let value = event.attributes[key] else {
            throw NSError(domain: "\(key) not available in \(event)", code: 2)
        }
        return try downcast(value)
        
    }
    
    private func downcast<T>(_ value: AnyHashable) throws -> T {
        guard let typedValue = value as? T else {
            throw NSError(domain: "\(value) is not of type \(T.self)", code: 3)
        }
        return typedValue
    }
    
    private func getValue<T>(in dic: AnyHashable,
                             for key: String) throws -> T {
        let dic: [String: AnyHashable] = try downcast(dic)
        return try downcast(dic)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
