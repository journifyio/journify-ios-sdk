//
//  VendorSystem.swift
//  Journify
//
//

import Foundation

internal struct ScreenSize {
    let width: Double
    let height: Double
}

internal class VendorSystem {
    var manufacturer: String {
        return "unknown"
    }
    
    var type: String {
        return "unknown"
    }
    
    var model: String {
        return "unknown"
    }
    
    var name: String {
        return "unknown"
    }
    
    var identifierForVendor: String? {
        return nil
    }
    
    var systemName: String {
        return "unknown"
    }
    
    var systemVersion: String {
        return ""
    }
    
    var screenSize: ScreenSize {
        return ScreenSize(width: 0, height: 0)
    }
    
    var userAgent: String? {
        return "unknown"
    }
    
    var requiredPlugins: [PlatformPlugin] {
        return []
    }
    
    static var current: VendorSystem = {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        return iOSVendorSystem()
        #else
        return VendorSystem()
        #endif
    }()
}
