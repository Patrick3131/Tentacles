//
//  MiddlewareTests.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import XCTest
import Tentacles

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
        tentacles.register(analyticsReporter: otherReporter, middlewares: [.capitalisedAttributeKeys])
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
    }
    
    func testCapitalisedAttributeKeys() throws {
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
    }
    


    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
