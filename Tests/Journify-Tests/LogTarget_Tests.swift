//
//  LogTarget_Tests.swift
//  Journify-Tests
//
//  Created by Cody Garvin on 10/18/21.
//

import Foundation
import XCTest
@testable import Journify

final class LogTarget_Tests: XCTestCase {
    
    let mockLogger = LoggerMockPlugin()
    
    class LoggerMockPlugin: JournifyLog {
        var logClosure: ((LogFilterKind, LogMessage) -> Void)?
        var closure: (() -> Void)?
        
        override func log(_ logMessage: LogMessage, destination: LoggingType.LogDestination) {
            super.log(logMessage, destination: destination)
            logClosure?(logMessage.kind, logMessage)
        }
        
        override func flush() {
            super.flush()
            closure?()
        }
    }
    
    override func setUp() {
        Journify.setup(with: Configuration(writeKey: "test"))
        Journify.shared().add(plugin: mockLogger)
        
        // Enable logging for all tests
        JournifyLog.loggingEnabled = true
    }
    
    override func tearDown() {
        
        // Reset to default state the system should be in from start
        JournifyLog.loggingEnabled = false
    }

    func testMetric() {
               
        // Arrange
        let expectation = XCTestExpectation(description: "Called")
                
        // Assert
        mockLogger.logClosure = { (kind, message) in
            expectation.fulfill()
            XCTAssertEqual(message.message, "Metric of 5", "Message name not correctly passed")
            XCTAssertEqual(message.title, "Counter", "Type of metricnot correctly passed")
        }
        
        // Act
        Journify.shared().metric(MetricType.fromString("Counter"), name: "Metric of 5", value: 5, tags: ["Test"])
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testHistory() {
               
        // Arrange
        let expectation = XCTestExpectation(description: "Called")
                
        // Assert
        mockLogger.logClosure = { (kind, message) in
            expectation.fulfill()
            XCTAssertEqual(message.function, "testHistory()", "Message function not correctly passed")
            XCTAssertEqual(message.logType, .history, "Type of message not correctly passed")
        }
        
        // Act
        Journify.shared().history(event: TrackEvent(event: "Tester", properties: nil), sender: self)
        wait(for: [expectation], timeout: 1.0)
    }

    func testLoggingDisabled() {
        
        struct LogConsoleTarget: LogTarget {
            var successClosure: ((String) -> Void)
            
            func parseLog(_ log: LogMessage) {
                XCTFail("Log should not be called when logging is disabled")
            }
        }
        
        // Arrange
        JournifyLog.loggingEnabled = false
        let logConsoleTarget = LogConsoleTarget(successClosure: { (logMessage: String) in
            // Assert
            XCTFail("This should not be called")
        })
        let loggingType = LoggingType.log
        Journify.shared().add(target: logConsoleTarget, type: loggingType)
        
        // Act
        Journify.shared().log(message: "Should hit our proper target")
    }

    func testMetricDisabled() {
        
        struct LogConsoleTarget: LogTarget {
            var successClosure: ((String) -> Void)
            
            func parseLog(_ log: LogMessage) {
                XCTFail("Log should not be called when logging is disabled")
            }
        }
        
        // Arrange
        JournifyLog.loggingEnabled = false
        let logConsoleTarget = LogConsoleTarget(successClosure: { (logMessage: String) in
            // Assert
            XCTFail("This should not be called")
        })
        let loggingType = LoggingType.log
        Journify.shared().add(target: logConsoleTarget, type: loggingType)
        
        // Act
        Journify.shared().metric(MetricType.fromString("Counter"), name: "Metric of 5", value: 5, tags: ["Test"])
    }
    
    func testHistoryDisabled() {
        
        struct LogConsoleTarget: LogTarget {
            var successClosure: ((String) -> Void)
            
            func parseLog(_ log: LogMessage) {
                XCTFail("Log should not be called when logging is disabled")
            }
        }
        
        // Arrange
        JournifyLog.loggingEnabled = false
        let logConsoleTarget = LogConsoleTarget(successClosure: { (logMessage: String) in
            // Assert
            XCTFail("This should not be called")
        })
        let loggingType = LoggingType.log
        Journify.shared().add(target: logConsoleTarget, type: loggingType)
        
        // Act
        Journify.shared().history(event: TrackEvent(event: "Tester", properties: nil), sender: self)
    }

    func testLoggingDisabledByDefault() {
        JournifyLog.loggingEnabled = false
        XCTAssertFalse(JournifyLog.loggingEnabled, "Logging should not default to enabled")
    }
    
    func testLoggingEnabledFromAnalytics() {
        JournifyLog.loggingEnabled = false
        
        Journify.debugLogsEnabled = true
        XCTAssertTrue(JournifyLog.loggingEnabled, "Logging should change to enabled")
        
        Journify.debugLogsEnabled = false
        XCTAssertFalse(JournifyLog.loggingEnabled, "Logging should reset to disabled")
    }
    
}

