//
//  AnalyticsRegisterTests.swift
//  
//
//  Created by Patrick Fischer on 07.08.22.
//

import Combine
import Tentacles
import XCTest

final class AnalyticsRegisterTests: XCTestCase {
    private var reporter: AnalyticsReporterStub!
    private var tentacles: Tentacles!
    private var setupSub: AnyCancellable!
    private var analyticsEventSub: AnyCancellable!
    private var eventResultsSub: AnyCancellable!
    override func setUpWithError() throws {
        reporter = AnalyticsReporterStub()
        tentacles = Tentacles()
        tentacles.register(reporter)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        reporter = nil
        tentacles = nil
        setupSub = nil
    }
    
    func testReporterReset() throws {
        let event = AnalyticsEventStub()
        let didReporterResetExpectation = expectation(
            description: "didReporterReset")
        didReporterResetExpectation.isInverted = true
        let oneEventReportedExpectation = expectation(
            description: "oneEventReported")
        var results = [Result<RawAnalyticsEvent, Error>]()
        eventResultsSub = reporter.analyticsEventPublisher
            .sink { result in
                results.append(result)
                if results.count == 1 {
                    oneEventReportedExpectation.fulfill()
                }
            }
        tentacles.track(event)
        tentacles.reset()
        tentacles.track(event)
        wait(for: [didReporterResetExpectation,oneEventReportedExpectation],
             timeout: 1)
        XCTAssertEqual(results.count, 1)
    }
    
    func testIdentityReset() throws {
        let event = AnalyticsEventStub()
        let expectation = expectation(description: "didIdentityReset")
        var results = [Result<RawAnalyticsEvent, Error>]()
        analyticsEventSub = reporter.analyticsEventPublisher
            .sink { result in
                results.append(result)
                if results.count == 2 {
                    expectation.fulfill()
                }
            }
        tentacles.track(event)
        tentacles.reset()
        tentacles.register(reporter)
        tentacles.track(event)
        wait(for: [expectation], timeout: 3)
        XCTAssertEqual(results.count, 2)
        var firstUUID = ""
        var secondUUID = ""
        switch results[0] {
        case .success(let event):
            firstUUID = try event.getValueAttribute(for: KeyAttributes.sessionUUID)
        case .failure:
            XCTFail()
        }
        switch results[1] {
        case .success(let event):
            secondUUID = try event.getValueAttribute(for: KeyAttributes.sessionUUID)
        case .failure:
            XCTFail()
        }
        XCTAssertNotEqual(firstUUID, secondUUID)
    }
    
    func testSetupReporter() throws {
        let otherReporter = AnalyticsReporterStub()
        var isSetup = false
        let expectation = expectation(description: "isReporterSetup")
        setupSub = otherReporter
            .setupPublisher
            .sink { _ in
                isSetup = true
                expectation.fulfill()
            }
        tentacles.register(otherReporter)
        wait(for: [expectation], timeout: 3)
        XCTAssertTrue(isSetup)
    }
}
