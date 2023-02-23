//
//  SwiftUIExampleApp.swift
//  SwiftUIExample
//
//  Created by Bendnaiba on 2/23/23.
//

import SwiftUI

@main
struct SwiftUIExampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
