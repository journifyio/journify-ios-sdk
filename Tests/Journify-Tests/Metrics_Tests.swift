//
//  Metrics_Tests.swift
//  Journify-Tests
//
//  Created by Cody Garvin on 12/18/20.
//

import Foundation
import XCTest
@testable import Journify


final class Metrics_Tests: XCTestCase {
    
    func testBaseEventCreation() {
        let analytics = Journify(configuration: Configuration(writeKey: "test"))
        let myDestination = MyDestination()
        myDestination.add(plugin: GooberPlugin())
        
        analytics.add(plugin: ZiggyPlugin())
        analytics.add(plugin: myDestination)
        
        let traits = MyTraits(email: "ben@med.com")
        analytics.identify(userId: "benMed", traits: traits)
    }
}


