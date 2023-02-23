//
//  MemoryLeak_Tests.swift
//  
//
//  Created by Brandon Sneed on 10/17/22.
//

import XCTest
@testable import Journify

final class MemoryLeak_Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLeaksVerbose() throws {
        Journify.setup(with: Configuration(writeKey: "test"))

        waitUntilStarted(analytics: Journify.shared())
        Journify.shared().track(name: "test")
        
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
        
        let journifyDest = Journify.shared().find(pluginType: JournifyDestination.self)!
        let startupQueue = Journify.shared().find(pluginType: StartupQueue.self)!
        let segmentLog = Journify.shared().find(pluginType: JournifyLog.self)!
         
        let context = Journify.shared().find(pluginType: Context.self)!
        
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        let iosLifecycle = Journify.shared().find(pluginType: iOSLifecycleEvents.self)!
        let iosMonitor = Journify.shared().find(pluginType: iOSLifecycleMonitor.self)!
        #endif

        Journify.shared().remove(plugin: startupQueue)
        Journify.shared().remove(plugin: segmentLog)
        Journify.shared().remove(plugin: journifyDest)
         
        Journify.shared().remove(plugin: context)
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        Journify.shared().remove(plugin: iosLifecycle)
        Journify.shared().remove(plugin: iosMonitor)
        #endif

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))

        checkIfLeaked(segmentLog)
        checkIfLeaked(journifyDest)
        checkIfLeaked(startupQueue)
        
        checkIfLeaked(context)
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        checkIfLeaked(iosLifecycle)
        checkIfLeaked(iosMonitor)
        #endif
    }

}
