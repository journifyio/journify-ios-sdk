//
//  StressTests.swift
//  Journify-Tests
//
//

import XCTest
@testable import Journify

class StressTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // Linux doesn't know what URLProtocol is and on watchOS it somehow works differently and isn't hit.
    #if !os(Linux) && !os(watchOS)
    func testStorageStress() throws {
        // register our network blocker
        guard URLProtocol.registerClass(BlockNetworkCalls.self) else { XCTFail(); return }
                
        Journify.setup(with: Configuration(writeKey: "stressTest").errorHandler({ error in
            XCTFail("Storage Error: \(error)")
        }))
        Journify.shared().storage.hardReset(doYouKnowHowToUseThis: true)
        Journify.shared().storage.onFinish = { url in
            // check that each one is valid json
            do {
                let json = try Data(contentsOf: url)
                _ = try JSONSerialization.jsonObject(with: json)
            } catch {
                XCTFail("\(error) in \(url)")
            }
        }

        waitUntilStarted(analytics: Journify.shared())
        
        // set the httpclient to use our blocker session
        let journify = Journify.shared().find(pluginType: JournifyDestination.self)
        let configuration = URLSessionConfiguration.ephemeral
        configuration.allowsCellularAccess = true
        configuration.timeoutIntervalForResource = 30
        configuration.timeoutIntervalForRequest = 60
        configuration.httpMaximumConnectionsPerHost = 2
        configuration.protocolClasses = [BlockNetworkCalls.self]
        configuration.httpAdditionalHeaders = ["Content-Type": "application/json; charset=utf-8",
                                               "Authorization": "Basic test",
                                               "User-Agent": "analytics-ios/\(Journify.version())"]
        let blockSession = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        journify?.httpClient?.session = blockSession
        
        let writeQueue1 = DispatchQueue(label: "write queue 1")
        let writeQueue2 = DispatchQueue(label: "write queue 2")
        let flushQueue = DispatchQueue(label: "flush queue")
        
        @Atomic var ready = false
        @Atomic var queue1Done = false
        @Atomic var queue2Done = false
        
        writeQueue1.async {
            while (ready == false) { usleep(1) }
            var eventsWritten = 0
            while (eventsWritten < 10000) {
                let event = "write queue 1: \(eventsWritten)"
                Journify.shared().track(name: event)
                eventsWritten += 1
                usleep(0001)
            }
            print("queue 1 wrote \(eventsWritten) events.")
            queue1Done = true
        }
        
        writeQueue2.async {
            while (ready == false) { usleep(1) }
            var eventsWritten = 0
            while (eventsWritten < 10000) {
                let event = "write queue 2: \(eventsWritten)"
                Journify.shared().track(name: event)
                eventsWritten += 1
                usleep(0001)
            }
            print("queue 2 wrote \(eventsWritten) events.")
            queue2Done = true
        }
        
        flushQueue.async {
            while (ready == false) { usleep(1) }
            var counter = 0
            sleep(1)
            while (queue1Done == false || queue2Done == false) {
                let sleepTime = UInt32.random(in: 1..<3000)
                usleep(sleepTime)
                Journify.shared().flush()
                counter += 1
            }
            print("flushed \(counter) times.")
            ready = false
        }
        
        ready = true
        
        while (ready) {
            RunLoop.main.run(until: Date.distantPast)
        }
    }
    #endif
     
    
    /*func testStressXTimes() throws {
        for i in 0..<50 {
            print("Stress test #\(i):")
            try testStorageStress()
            print("\n")
        }
    }*/
     
}
