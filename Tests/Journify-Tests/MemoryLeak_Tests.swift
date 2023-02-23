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
        
        #if !os(Linux)
        let deviceToken = Journify.shared().find(pluginType: DeviceToken.self)!
        #endif
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        let iosLifecycle = Journify.shared().find(pluginType: iOSLifecycleEvents.self)!
        let iosMonitor = Journify.shared().find(pluginType: iOSLifecycleMonitor.self)!
        #elseif os(watchOS)
        let watchLifecycle = Journify.shared().find(pluginType: watchOSLifecycleEvents.self)!
        let watchMonitor = Journify.shared().find(pluginType: watchOSLifecycleMonitor.self)!
        #elseif os(macOS)
        let macLifecycle = Journify.shared().find(pluginType: macOSLifecycleEvents.self)!
        let macMonitor = Journify.shared().find(pluginType: macOSLifecycleMonitor.self)!
        #endif

        Journify.shared().remove(plugin: startupQueue)
        Journify.shared().remove(plugin: segmentLog)
        Journify.shared().remove(plugin: journifyDest)
         
        Journify.shared().remove(plugin: context)
        #if !os(Linux)
        Journify.shared().remove(plugin: deviceToken)
        #endif
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        Journify.shared().remove(plugin: iosLifecycle)
        Journify.shared().remove(plugin: iosMonitor)
        #elseif os(watchOS)
        Journify.shared().remove(plugin: watchLifecycle)
        Journify.shared().remove(plugin: watchMonitor)
        #elseif os(macOS)
        Journify.shared().remove(plugin: macLifecycle)
        Journify.shared().remove(plugin: macMonitor)
        #endif

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))

        checkIfLeaked(segmentLog)
        checkIfLeaked(journifyDest)
        checkIfLeaked(startupQueue)
        
        checkIfLeaked(context)
        #if !os(Linux)
        checkIfLeaked(deviceToken)
        #endif
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        checkIfLeaked(iosLifecycle)
        checkIfLeaked(iosMonitor)
        #elseif os(watchOS)
        checkIfLeaked(watchLifecycle)
        checkIfLeaked(watchMonitor)
        #elseif os(macOS)
        checkIfLeaked(macLifecycle)
        checkIfLeaked(macMonitor)
        #endif
    }

}
