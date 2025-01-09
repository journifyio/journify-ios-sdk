//
//  AppleUtils.swift
//  Journify
//
//

import Foundation

// MARK: - iOS, tvOS, Catalyst

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import SystemConfiguration
import UIKit
#if !os(tvOS)
import WebKit
#endif

internal class iOSVendorSystem: VendorSystem {
    private let device = UIDevice.current
    
    override var manufacturer: String {
        return "Apple"
    }
        
    override var type: String {
        #if os(iOS)
        return "ios"
        #elseif os(tvOS)
        return "tvos"
        #elseif os(visionOS)
        return "visionos"
        #elseif targetEnvironment(macCatalyst)
        return "macos"
        #else
        return "unknown"
        #endif
    }
        
    override var model: String {
        // eg. "iPhone5,1"
        return deviceModel()
    }
    
    override var name: String {
        // eg. "iPod Touch"
        return device.model
    }
    
    override var identifierForVendor: String? {
        return device.identifierForVendor?.uuidString
    }
    
    override var systemName: String {
        return device.systemName
    }
    
    override var systemVersion: String {
        device.systemVersion
    }
    
    override var screenSize: ScreenSize {
        let screenSize = UIScreen.main.bounds.size
        return ScreenSize(width: Double(screenSize.width), height: Double(screenSize.height))
    }
    
    override var userAgent: String? {
        #if !os(tvOS)
        var userAgent: String?
        
        if Thread.isMainThread {
            userAgent = WKWebView().value(forKey: "userAgent") as? String
        } else {
            DispatchQueue.main.sync {
              userAgent = WKWebView().value(forKey: "userAgent") as? String
            }
        }

        return userAgent
        #else
        // webkit isn't on tvos
        return "unknown"
        #endif
    }
    
    override var requiredPlugins: [PlatformPlugin] {
        return [iOSLifecycleMonitor(), DeviceToken()]
    }
    
    private func deviceModel() -> String {
        var name: [Int32] = [CTL_HW, HW_MACHINE]
        var size: Int = 2
        sysctl(&name, 2, nil, &size, nil, 0)
        var hw_machine = [CChar](repeating: 0, count: Int(size))
        sysctl(&name, 2, &hw_machine, &size, nil, 0)
        let model = String(cString: hw_machine)
        return model
    }
}

#endif
