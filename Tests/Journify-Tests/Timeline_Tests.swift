//
//  Timeline_Tests.swift
//  Timeline_Tests
//
//

import XCTest
@testable import Journify

class Timeline_Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBaseEventCreation() {
        let expectation = XCTestExpectation(description: "First")
        
        let firstDestination = MyDestination {
            expectation.fulfill()
            return true
        }

        let configuration = Configuration(writeKey: "test")
        Journify.setup(with: configuration)

        Journify.shared().add(plugin: firstDestination)

        waitUntilStarted(analytics: Journify.shared())

        Journify.shared().track(name: "Booya")

        wait(for: [expectation], timeout: 1.0)
    }

    func testTwoBaseEventCreation() {
        let expectation = XCTestExpectation(description: "First")
        let expectationTrack2 = XCTestExpectation(description: "Second")

        let firstDestination = MyDestination {
            expectation.fulfill()
            return true
        }
        let secondDestination = MyDestination {
            expectationTrack2.fulfill()
            return true
        }

        
        let configuration = Configuration(writeKey: "test")
        Journify.setup(with: configuration)
        Journify.shared().add(plugin: firstDestination)
        Journify.shared().add(plugin: secondDestination)

        waitUntilStarted(analytics: Journify.shared())

        Journify.shared().track(name: "Booya")

        wait(for: [expectation, expectationTrack2], timeout: 1.0)
    }
    
    func testTwoBaseEventCreationFirstFail() {
        let expectation = XCTestExpectation(description: "First")
        let expectationTrack2 = XCTestExpectation(description: "Second")

        let firstDestination = MyDestination {
            expectation.fulfill()
            return false
        }
        let secondDestination = MyDestination {
            expectationTrack2.fulfill()
            return true
        }

        let configuration = Configuration(writeKey: "test")
        let analytics = Journify(configuration: configuration)

        Journify.shared().add(plugin: firstDestination)
        Journify.shared().add(plugin: secondDestination)

        waitUntilStarted(analytics: analytics)

        Journify.shared().track(name: "Booya")

        wait(for: [expectation, expectationTrack2], timeout: 1.0)
    }

}
