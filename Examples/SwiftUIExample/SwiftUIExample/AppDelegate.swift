//
//  AppDelegate.swift
//  SwiftUIExample
//
//  Created by Bendnaiba on 2/23/23.
//

import UIKit
import Journify

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Journify.debugLogsEnabled = true
        let configuration = Configuration(writeKey: "Your_Key")
            .trackApplicationLifecycleEvents(true)
            .flushInterval(10)
        
        Journify.setup(with: configuration)
        Journify.shared().track(name: "First Event")
        return true
    }
}
