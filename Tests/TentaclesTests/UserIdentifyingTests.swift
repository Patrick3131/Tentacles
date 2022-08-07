//
//  UserIdentifyingTests.swift
//  
//
//  Created by Patrick Fischer on 02.08.22.
//

import Combine
import Tentacles
import XCTest

final class UserIdentifyingTests: XCTestCase {
    private var reporter: AnalyticsReporterStub!
    private var tentacles: Tentacles!
    private var identifiedSub: AnyCancellable?
    private var userAttributesSub: AnyCancellable?
    private var logOutSub: AnyCancellable?
    override func setUpWithError() throws {
        reporter = AnalyticsReporterStub()
        tentacles = Tentacles()
        tentacles.register(reporter)
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        reporter = nil
        tentacles = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUserIdentified() throws {
        let expectation = expectation(description: "userLoggedIn")
        var id = ""
        identifiedSub = reporter
            .idPublisher
            .sink { _id in
                id = _id
                expectation.fulfill()
            }
        tentacles.identify(with: "123")
        wait(for: [expectation], timeout: 3)
        XCTAssertEqual(id, "123")
    }
    
    func testAddAttributes() throws {
        let expectation = expectation(description: "addUserAttributes")
        var attributes: AttributesValue!
        userAttributesSub = reporter
            .userAttributesPublisher
            .sink { _attributes in
                attributes = _attributes
                expectation.fulfill()
            }
        let attributesStub = TentaclesAttributesStub()
        tentacles.addUserAttributes(attributesStub)
        wait(for: [expectation], timeout: 3)
        XCTAssertEqual(attributes, attributesStub.serialiseToValue())
    }
    
    func testUserLoggedOut() throws {
        let expectation = expectation(description: "userLoggedOut")
        var didUserLogOut = false
        logOutSub = reporter
            .logOutPublisher
            .sink { _ in
                didUserLogOut = true
                expectation.fulfill()
            }
        tentacles.logout()
        wait(for: [expectation], timeout: 3)
        XCTAssertEqual(didUserLogOut, true)
    }
}
