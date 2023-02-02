//
//  File.swift
//  
//
//

#if !os(Linux)

import Foundation

@objc(JFConfiguration)
public class ObjCConfiguration: NSObject {
    internal var configuration: Configuration
    
    @objc
    public var application: Any? {
        get {
            return configuration.values.application
        }
        set(value) {
            configuration.application(value)
        }
    }
    
    @objc
    public var trackApplicationLifecycleEvents: Bool {
        get {
            return configuration.values.trackApplicationLifecycleEvents
        }
        set(value) {
            configuration.trackApplicationLifecycleEvents(value)
        }
    }
    
    @objc
    public var flushAt: Int {
        get {
            return configuration.values.flushAt
        }
        set(value) {
            configuration.flushAt(value)
        }
    }
    
    @objc
    public var flushInterval: TimeInterval {
        get {
            return configuration.values.flushInterval
        }
        set(value) {
            configuration.flushInterval(value)
        }
    }
    
    @objc
    public var apiHost: String {
        get {
            return configuration.values.apiHost
        }
        set(value) {
            configuration.apiHost(value)
        }
    }

    @objc
    public init(writeKey: String) {
        self.configuration = Configuration(writeKey: writeKey)
    }
}

#endif

