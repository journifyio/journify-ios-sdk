//
//  JournifyLog_Tests.swift
//  Journify-Tests
//
//  Created by Cody Garvin on 12/18/20.
//

import Foundation
import XCTest
@testable import Journify

final class JournifyLog_Tests: XCTestCase {
    
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
    }
    
    override func tearDown() {
        JournifyLog.loggingEnabled = true
    }

    func testLogging() {
                
        // Arrange
        let expectation = XCTestExpectation(description: "Called")
        
        // Assert
        mockLogger.logClosure = { (kind, message) in
            expectation.fulfill()
            
            XCTAssertEqual(kind, .debug, "Type not correctly passed")
            XCTAssertEqual(message.message, "Something Other Than Awesome", "Message not correctly passed")
        }
        
        // Act
        Journify.shared().log(message: "Something Other Than Awesome")
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testWarningLogging() {
                
        // Arrange
        let expectation = XCTestExpectation(description: "Called")
        
        // Assert
        mockLogger.logClosure = { (kind, message) in
            expectation.fulfill()
            XCTAssertEqual(kind, .warning, "Type not correctly passed")
        }
        
        // Act
        Journify.shared().log(message: "Something Other Than Awesome", kind: .warning)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testErrorLogging() {
                
        // Arrange
        let expectation = XCTestExpectation(description: "Called")
        
        // Assert
        mockLogger.logClosure = { (kind, message) in
            expectation.fulfill()
            
            XCTAssertEqual(kind, .error, "Type not correctly passed")
        }
        
        // Act
        Journify.shared().log(message: "Something Other Than Awesome", kind: .error)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateSettingsFalse() {
        var settings = Settings(writeKey: "123456789")
        settings.plan = try? JSON(["logging_enabled": false])
        mockLogger.update(settings: settings)
        
        XCTAssertFalse(JournifyLog.loggingEnabled, "Enabled logging was not set correctly")
    }
    
    func testUpdateSettingsTrue() {
        
        JournifyLog.loggingEnabled = false
        var settings = Settings(writeKey: "123456789")
        settings.plan = try? JSON(["logging_enabled": true])
        mockLogger.update(settings: settings)
        
        XCTAssertTrue(JournifyLog.loggingEnabled, "Enabled logging was not set correctly")
    }
    
    func testTargetSuccess() {
        
        // Arrange
        let expectation = XCTestExpectation(description: "Called")
        
        struct LogConsoleTarget: LogTarget {
            var successClosure: ((String) -> Void)
            
            func parseLog(_ log: LogMessage) {
                print("[Journify Tests - \(log.function ?? ""):\(String(log.line ?? 0))] \(log.message)\n")
                successClosure(log.message)
            }
        }
        
        let logConsoleTarget = LogConsoleTarget(successClosure: { (logMessage: String) in
            expectation.fulfill()
        })
        let loggingType = LoggingType.log
        Journify.shared().add(target: logConsoleTarget, type: loggingType)
        
        // Act
        Journify.shared().log(message: "Should hit our proper target")
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testTargetFailure() {
        
        // Arrange        
        struct LogConsoleTarget: LogTarget {
            var successClosure: ((String) -> Void)
            
            func parseLog(_ log: LogMessage) {
                print("[Journify Tests - \(log.function ?? ""):\(String(log.line ?? 0))] \(log.message)\n")
                successClosure(log.message)
            }
        }
        
        let logConsoleTarget = LogConsoleTarget(successClosure: { (logMessage: String) in
            XCTFail("Should not hit this since it was registered for history")
        })
        let loggingType = LoggingType.history
        Journify.shared().add(target: logConsoleTarget, type: loggingType)
        
        // Act
        Journify.shared().log(message: "Should hit our proper target")
    }
        
    func testFlush() {
        // Arrange
        let expectation = XCTestExpectation(description: "Called")
        
        struct LogConsoleTarget: LogTarget {
            var successClosure: ((String) -> Void)
            
            func parseLog(_ log: LogMessage) {
                XCTFail("Log should not be called when logging is disabled")
            }
        }
        
        // Arrange
        mockLogger.closure = {
            expectation.fulfill()
        }
        
        // Act
        Journify.shared().flush()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLogFlush() {
        // Arrange
        let expectation = XCTestExpectation(description: "Called")
        
        struct LogConsoleTarget: LogTarget {
            var successClosure: ((String) -> Void)
            
            func parseLog(_ log: LogMessage) {
                XCTFail("Log should not be called when logging is disabled")
            }
        }
        
        // Arrange
        mockLogger.closure = {
            expectation.fulfill()
        }
        
        // Act
        Journify.shared().logFlush()
        
        wait(for: [expectation], timeout: 1.0)
    }

    
    func testInternalLog() {
        // Arrange
        let expectation = XCTestExpectation(description: "Called")
        
        
        // Assert
        mockLogger.logClosure = { (kind, message) in
            expectation.fulfill()
            XCTAssertEqual(kind, .warning, "Type not correctly passed")
        }
        
        // Act
        Journify.journifyLog(message: "Should hit our proper target", kind: .warning)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testInternalMetricCounter() {
        // Arrange
        let expectation = XCTestExpectation(description: "Called")
                
        // Assert
        mockLogger.logClosure = { (kind, message) in
            expectation.fulfill()
            XCTAssertEqual(message.message, "Metric of 5", "Message name not correctly passed")
            XCTAssertEqual(message.title, "Counter", "Type of metric not correctly passed")
        }
        
        // Act
        Journify.journifyMetric(MetricType.fromString("Counter"), name: "Metric of 5", value: 5, tags: ["Test"])
        wait(for: [expectation], timeout: 1.0)
    }

    func testInternalMetricGauge() {
        // Arrange
        let expectation = XCTestExpectation(description: "Called")
                
        // Assert
        mockLogger.logClosure = { (kind, message) in
            expectation.fulfill()
            XCTAssertEqual(message.message, "Metric of 5", "Message name not correctly passed")
            XCTAssertEqual(message.title, "Gauge", "Type of metric not correctly passed")
        }
        
        // Act
        Journify.journifyMetric(MetricType.fromString("Gauge"), name: "Metric of 5", value: 5, tags: ["Test"])
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddTargetTwice() {

        // Arrange
        struct LogConsoleTarget: LogTarget {
            func parseLog(_ log: LogMessage) {}
        }
        let expectation = XCTestExpectation(description: "Called")
        mockLogger.logClosure = { (kind, logMessage) in
            XCTAssertTrue(logMessage.message.contains("Could not add target"))
            expectation.fulfill()
        }
        
        // Arrange
        JournifyLog.loggingEnabled = false
        let logConsoleTarget = LogConsoleTarget()
        let loggingType = LoggingType.log
        
        // Act
        Journify.shared().add(target: logConsoleTarget, type: loggingType)
        // Add a second time to get a duplicate error
        Journify.shared().add(target: logConsoleTarget, type: loggingType)
        
        wait(for: [expectation], timeout: 1.0)

    }

}

