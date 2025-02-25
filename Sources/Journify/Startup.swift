//
//  Startup.swift
//  Journify
//
//

import Foundation

extension Journify: Subscriber {
        
    internal func platformStartup() {
        add(plugin: JournifyLog())
        add(plugin: StartupQueue())
        add(plugin: InjectTraitsPlugin())
        // add journify destination plugin unless
        // asked not to via configuration.
        if configuration.values.autoAddSegmentDestination {
            let journifyDestination = JournifyDestination()
            journifyDestination.analytics = self
            add(plugin: journifyDestination)
        }
        
        // setup IDFA and IDFV plugin
#if os(iOS) || os(tvOS)
        if #available(iOS 14, *) {
            add(plugin: IDFACollection())
        }
#endif
        
        // Setup platform specific plugins
        if let platformPlugins = platformPlugins() {
            for plugin in platformPlugins {
                add(plugin: plugin)
            }
        }
        
        // plugins will receive any settings we currently have as they are added.
        // ... but lets go check if we have new stuff ....
        // start checking periodically for settings changes from segment.com
        setupSettingsCheck()
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

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
import UIKit
extension Journify {
    internal func setupSettingsCheck() {
        // do the first one
        checkSettings()
        // set up return-from-background to do it again.
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            guard let app = notification.object as? UIApplication else { return }
            if app.applicationState == .background {
                self?.checkSettings()
            }
        }
    }
}
#elseif os(watchOS)
extension Journify {
    internal func setupSettingsCheck() {
        // TBD: we don't know what to do here yet.
        checkSettings()
    }
}
#elseif os(macOS)
import Cocoa
extension Journify {
    internal func setupSettingsCheck() {
        // do the first one
        checkSettings()
        // now set up a timer to do it every 24 hrs.
        // mac apps change focus a lot more than iOS apps, so this
        // seems more appropriate here.
        QueueTimer.schedule(interval: .days(1), queue: .main) { [weak self] in
            self?.checkSettings()
        }
    }
}
#elseif os(Linux)
extension Journify {
    internal func setupSettingsCheck() {
        checkSettings()
    }
}
#endif

