//
//  ObjC_Tests.swift
//  Journify-Tests
//
//  Created by Brandon Sneed on 8/13/21.
//

#if !os(Linux)

import XCTest
@testable import Journify

class ObjC_Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /*

     NOTE: These tests only cover non-trivial methods.  Most ObjC methods pass straight through to their swift counterparts
     however, there are some where some data conversion needs to happen in order to be made accessible.
     
     */

    func testWrapping() {
        let a = Journify(configuration: Configuration(writeKey: "WRITE_KEY"))
        let objc = ObjCJournify(wrapping: a)
        
        XCTAssertTrue(objc.getAnalyticObject() === a)
    }
}

#endif
