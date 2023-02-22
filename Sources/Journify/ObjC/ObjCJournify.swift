//
//  File.swift
//  
//
//  Created by Cody Garvin on 6/10/21.
//

#if !os(Linux)

import Foundation

// MARK: - ObjC Compatibility

@objc(JFJournify)
public class ObjCJournify: NSObject {
    /// The underlying Analytics object we're working with
    
    private static var sharedInstance: ObjCJournify?
    private let analytics: Journify
    
    @objc
    public static func shared() -> ObjCJournify {
        if sharedInstance == nil {
            sharedInstance = ObjCJournify(configuration: ObjCConfiguration(writeKey: "Your_Key"))
        }
        return sharedInstance!
    }
    
    @objc
    public static func setup(with configuration: ObjCConfiguration) {
        sharedInstance = ObjCJournify(configuration: configuration)
    }
    
    
    private init(configuration: ObjCConfiguration) {
        self.analytics = Journify(configuration: configuration.configuration)
    }
    
    /// Get a workable ObjC instance by wrapping a Swift instance
    /// Useful when you want additional flexibility or to share
    /// a single instance between ObjC<>Swift.
    public init(wrapping analytics: Journify) {
        self.analytics = analytics
    }
    
    func getAnalyticObject() -> Journify {
        return analytics
    }
}

// MARK: - ObjC Events

@objc
extension ObjCJournify {
    @objc(track:)
    public static func track(name: String) {
        track(name: name, properties: nil)
    }
    

    @objc(track:properties:)
    public static func track(name: String, properties: [String: Any]?) {
        sharedInstance?.analytics.track(name: name, properties: properties)
    }

    /// Associate a user with their unique ID and record traits about them.
    /// - Parameters:
    ///   - userId: A database ID (or email address) for this user.
    ///     For more information on how we generate the UUID and Apple's policies on IDs, see
    ///     https://journify.io/libraries/ios#ids
    /// In the case when user logs out, make sure to call ``reset()`` to clear user's identity info.
    @objc(identify:)
    public static func identify(userId: String) {
        identify(userId: userId, traits: nil)
    }

    /// Associate a user with their unique ID and record traits about them.
    /// - Parameters:
    ///   - userId: A database ID (or email address) for this user.
    ///     For more information on how we generate the UUID and Apple's policies on IDs, see
    ///     https://journify.io/libraries/ios#ids
    ///   - traits: A dictionary of traits you know about the user. Things like: email, name, plan, etc.
    /// In the case when user logs out, make sure to call ``reset()`` to clear user's identity info.
    @objc(identify:traits:)
    public static func identify(userId: String, traits: [String: Any]?) {
        sharedInstance?.analytics.identify(userId: userId, traits: traits)
    }
    
    /// Track a screen change with a title, category and other properties.
    /// - Parameters:
    ///   - screenTitle: The title of the screen being tracked.
    @objc(screen:)
    public static func screen(title: String) {
        screen(title: title, category: nil, properties: nil)
    }
    
    /// Track a screen change with a title, category and other properties.
    /// - Parameters:
    ///   - screenTitle: The title of the screen being tracked.
    ///   - category: A category to the type of screen if it applies.
    @objc(screen:category:)
    public static func screen(title: String, category: String?) {
        sharedInstance?.analytics.screen(title: title, category: category, properties: nil)
    }
    /// Track a screen change with a title, category and other properties.
    /// - Parameters:
    ///   - screenTitle: The title of the screen being tracked.
    ///   - category: A category to the type of screen if it applies.
    ///   - properties: Any extra metadata associated with the screen. e.g. method of access, size, etc.
    @objc(screen:category:properties:)
    public static func screen(title: String, category: String?, properties: [String: Any]?) {
        sharedInstance?.analytics.screen(title: title, category: category, properties: properties)
    }
}

// MARK: - ObjC Peripheral Functionality

@objc
extension ObjCJournify {
    @objc
    public static var anonymousId: String {
        return sharedInstance?.analytics.anonymousId ?? ""
    }
    
    @objc
    public static var userId: String? {
        return sharedInstance?.analytics.userId
    }
    
    @objc
    public static func traits() -> [String: Any]? {
        return sharedInstance?.analytics.traits()
    }
    
    @objc
    public static func flush() {
        sharedInstance?.analytics.flush()
    }
    
    @objc
    public static func reset() {
        sharedInstance?.analytics.reset()
    }
    
    @objc
    public static func jfVersion() -> String {
        return sharedInstance?.analytics.version() ?? ""
    }
}

#endif
