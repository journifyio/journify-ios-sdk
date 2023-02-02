import XCTest
@testable import Journify

#if os(iOS)
final class iOSLifecycle_Tests: XCTestCase {
    
    func testInstallEventCreation() {
        Journify.setup(with: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        Journify.shared().add(plugin: outputReader)
        
        let iosLifecyclePlugin = iOSLifecycleEvents()
        Journify.shared().add(plugin: iosLifecyclePlugin)
        
        waitUntilStarted(analytics: Journify.shared())
        
        UserDefaults.standard.setValue(nil, forKey: "JFBuildKeyV2")
        
        // This is a hack that needs to be dealt with
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 2))
        
        iosLifecyclePlugin.application(nil, didFinishLaunchingWithOptions: nil)
        
        let trackEvent: TrackEvent? = outputReader.events.first as? TrackEvent
        XCTAssertTrue(trackEvent?.event == "Application Installed")
        XCTAssertTrue(trackEvent?.type == "track")
    }

    func testInstallEventUpdated() {
        Journify.setup(with: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        Journify.shared().add(plugin: outputReader)
        
        let iosLifecyclePlugin = iOSLifecycleEvents()
        Journify.shared().add(plugin: iosLifecyclePlugin)
        
        waitUntilStarted(analytics: Journify.shared())
        
        UserDefaults.standard.setValue("1337", forKey: "JFBuildKeyV2")
        
        // This is a hack that needs to be dealt with
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 2))
        
        iosLifecyclePlugin.application(nil, didFinishLaunchingWithOptions: nil)
        
        let trackEvent: TrackEvent? = outputReader.events.first as? TrackEvent
        XCTAssertTrue(trackEvent?.event == "Application Updated")
        XCTAssertTrue(trackEvent?.type == "track")
    }
    
    func testInstallEventOpened() {
        Journify.setup(with: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        Journify.shared().add(plugin: outputReader)
        
        let iosLifecyclePlugin = iOSLifecycleEvents()
        Journify.shared().add(plugin: iosLifecyclePlugin)
        
        waitUntilStarted(analytics: Journify.shared())
        
        iosLifecyclePlugin.application(nil, didFinishLaunchingWithOptions: nil)
                
        let trackEvent: TrackEvent? = outputReader.events.last as? TrackEvent
        XCTAssertTrue(trackEvent?.event == "Application Opened")
        XCTAssertTrue(trackEvent?.type == "track")
    }
}

#endif
