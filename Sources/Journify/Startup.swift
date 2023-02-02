//
//  Startup.swift
//  Journify
//
//

import Foundation
import Sovran

extension Journify: Subscriber {
        
    internal func platformStartup() {
        add(plugin: JournifyLog())
        add(plugin: StartupQueue())
        
        // add journify destination plugin unless
        // asked not to via configuration.
        let journifyDestination = JournifyDestination()
        journifyDestination.analytics = self
        add(plugin: journifyDestination)
        
        // Setup platform specific plugins
        if let platformPlugins = platformPlugins() {
            for plugin in platformPlugins {
                add(plugin: plugin)
            }
        }
        
        self.store.dispatch(action: System.ToggleRunningAction(running: true))
    }
    
    internal func platformPlugins() -> [PlatformPlugin]? {
        var plugins = [PlatformPlugin]()
        
        // add context plugin as well as it's platform specific internally.
        // this must come first.
        plugins.append(Context())
        
        plugins += VendorSystem.current.requiredPlugins

        // setup lifecycle if desired
        if configuration.values.trackApplicationLifecycleEvents {
            #if os(iOS) || os(tvOS)
            plugins.append(iOSLifecycleEvents())
            #endif
        }
        
        if plugins.isEmpty {
            return nil
        } else {
            return plugins
        }
    }
}
