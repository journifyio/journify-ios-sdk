//
//  AppDelegate.swift
//  IOSApp
//
//  Created by Mohammed on 1/9/23.
//

import UIKit
import Journify

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let configuration = Configuration(writeKey: "Your_Key")
            .trackApplicationLifecycleEvents(true)
            .flushInterval(10)

        Journify.setup(with: configuration)

        Journify.shared().track(name: "New Event", properties: ["Name": "Mohamed"], externalId: ["testKey": "test"])
        Journify.shared().screen(title: "New Screen", properties: ["title": "Growth as a service", "url": "https://journify.io", "path": "/"])

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

