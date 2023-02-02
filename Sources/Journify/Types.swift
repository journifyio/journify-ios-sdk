//
//  Types.swift
//  Journify
//
//

import Foundation
import Sovran

// MARK: - Event Types

public protocol RawEvent: Codable {
    var type: String? { get set }
    var anonymousId: String? { get set }
    var messageId: String? { get set }
    var userId: String? { get set }
    var timestamp: String? { get set }
    
    var context: JSON? { get set }
    var metrics: [JSON]? { get set }
}

public struct TrackEvent: RawEvent {
    public var type: String? = "track"
    public var anonymousId: String? = nil
    public var messageId: String? = nil
    public var userId: String? = nil
    public var timestamp: String? = nil
    public var context: JSON? = nil
    public var metrics: [JSON]? = nil
    
    public var event: String
    public var properties: JSON?
    public var externalId: JSON?

    public init(event: String, properties: JSON?, externalId: JSON? = nil) {
        self.event = event
        self.properties = properties
        self.externalId = externalId
    }
    
    public init(existing: TrackEvent) {
        self.init(event: existing.event, properties: existing.properties)
        applyRawEventData(event: existing)
    }
}

public struct IdentifyEvent: RawEvent {
    public var type: String? = "identify"
    public var anonymousId: String? = nil
    public var messageId: String? = nil
    public var userId: String?
    public var timestamp: String? = nil
    public var context: JSON? = nil
    public var metrics: [JSON]? = nil
    
    public var traits: JSON?
    
    
    public init(userId: String? = nil, traits: JSON? = nil) {
        self.userId = userId
        self.traits = traits
    }
    
    public init(existing: IdentifyEvent) {
        self.init(userId: existing.userId, traits: existing.traits)
        applyRawEventData(event: existing)
    }
}

public struct ScreenEvent: RawEvent {
    public var type: String? = "page"
    public var anonymousId: String? = nil
    public var messageId: String? = nil
    public var userId: String? = nil
    public var timestamp: String? = nil
    public var context: JSON? = nil
    public var metrics: [JSON]? = nil
    
    public var name: String?
    public var category: String?
    public var properties: JSON?
    
    public init(title: String? = nil, category: String?, properties: JSON? = nil) {
        self.name = title
        self.category = category
        self.properties = properties
    }
    
    public init(existing: ScreenEvent) {
        self.init(title: existing.name, category: existing.category, properties: existing.properties)
        applyRawEventData(event: existing)
    }
}

// MARK: - RawEvent data helpers

extension RawEvent {
    internal mutating func applyRawEventData(event: RawEvent?) {
        if let e = event {
            anonymousId = e.anonymousId
            messageId = e.messageId
            userId = e.userId
            timestamp = e.timestamp
            context = e.context
        }
    }

    internal func applyRawEventData(store: Store) -> Self {
        var result: Self = self
        
        guard let userInfo: UserInfo = store.currentState() else { return self }
        
        result.anonymousId = userInfo.anonymousId
        result.userId = userInfo.userId
        result.messageId = UUID().uuidString
        result.timestamp = Date().iso8601()
        
        return result
    }
}
