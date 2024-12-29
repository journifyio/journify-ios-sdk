//
//  Context.swift
//  Journify
//
//

import Foundation

public protocol OpeningURLs {
    func openURL(_ url: URL, options: [String : Any])
}

extension OpeningURLs {
    func openURL(_ url: URL, options: [String : Any]) {}
}

public class Context: PlatformPlugin {
    public let type: PluginType = .before
    public weak var analytics: Journify?
    
    internal var staticContext = staticContextData()
    internal static var device = VendorSystem.current
    
    public func execute<T: RawEvent>(event: T?) -> T? {
        guard var workingEvent = event else { return event }
        
        var context = staticContext
                        
        if let userInfo: UserInfo = analytics?.store.currentState(), let referrer = userInfo.referrer {
            context["referrer"] = ["url": referrer.absoluteString]
        }
        
        // if this event came in with context data already
        // let it take precedence over our values.
        if let eventContext = workingEvent.context?.dictionaryValue {
            context.merge(eventContext) { (_, new) in new }
        }
        
        do {
            workingEvent.context = try JSON(context)
        } catch {
            analytics?.reportInternalError(error)
        }
        
        return workingEvent
    }
    
    internal static func staticContextData() -> [String: Any] {
        var staticContext = [String: Any]()
        
        // library name
        staticContext["library"] = [
            "name": "analytics-swift",
            "version": __journify_version,
        ]
        
        // app info
        let info = Bundle.main.infoDictionary
        let localizedInfo = Bundle.main.localizedInfoDictionary
        var app = [String: Any]()
        if let info = info {
            app.merge(info) { (_, new) in new }
        }
        if let localizedInfo = localizedInfo {
            app.merge(localizedInfo) { (_, new) in new }
        }
        if app.count != 0 {
            staticContext["app"] = [
                "name": app["CFBundleDisplayName"] ?? "",
                "version": app["CFBundleShortVersionString"] ?? "",
                "build": app["CFBundleVersion"] ?? "",
                "namespace": Bundle.main.bundleIdentifier ?? ""
            ]
        }
        
        insertStaticPlatformContextData(context: &staticContext)
        
        return staticContext
    }
    
    internal static func insertStaticPlatformContextData(context: inout [String: Any]) {
        // device
        let device = Self.device
        context["device"] = [
            "manufacturer": device.manufacturer,
            "type": device.type,
            "model": device.model,
            "name": device.name,
            "id": device.identifierForVendor ?? ""
        ]
        // os
        context["os"] = [
            "name": device.systemName,
            "version": device.systemVersion
        ]
        // screen
        let screen = device.screenSize
        context["screen"] = [
            "width": screen.width,
            "height": screen.height
        ]
        // user-agent
        let userAgent = device.userAgent
        context["userAgent"] = userAgent
        // locale
        if Locale.preferredLanguages.count > 0 {
            context["locale"] = Locale.preferredLanguages[0]
        }
        // timezone
        context["timezone"] = TimeZone.current.identifier
    }
}
