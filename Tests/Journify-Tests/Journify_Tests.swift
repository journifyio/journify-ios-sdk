import XCTest
@testable import Journify

final class Journify_Tests: XCTestCase {
    
    func testAnonymousId() {
        Journify.setup(with: Configuration(writeKey: "test"))
        let anonId = Journify.shared().anonymousId
        
        XCTAssertTrue(anonId != "")
        XCTAssertTrue(anonId.count == 36) // it's a UUID y0.
    }
    
    func testContext() {
        Journify.setup(with: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        Journify.shared().add(plugin: outputReader)

        waitUntilStarted(analytics: Journify.shared())
        
        // add a referrer
        Journify.shared().openURL(URL(string: "https://google.com")!)
        
        Journify.shared().track(name: "token check")
        
        let trackEvent: TrackEvent? = outputReader.lastEvent as? TrackEvent
        let context = trackEvent?.context?.dictionaryValue
        // Verify that context isn't empty here.
        // We need to verify the values but will do that in separate platform specific tests.
        XCTAssertNotNil(context)
        XCTAssertNotNil(context?["screen"], "screen missing!")
        XCTAssertNotNil(context?["os"], "os missing!")
        XCTAssertNotNil(context?["timezone"], "timezone missing!")
        XCTAssertNotNil(context?["library"], "library missing!")
        
        let referrer = context?["referrer"] as! [String: Any]
        XCTAssertEqual(referrer["url"] as! String, "https://google.com")

        // this key not present on watchOS (doesn't have webkit)
        #if !os(watchOS)
        XCTAssertNotNil(context?["userAgent"], "userAgent missing!")
        #endif
        
        // these keys not present on linux
        #if !os(Linux)
        XCTAssertNotNil(context?["app"], "app missing!")
        XCTAssertNotNil(context?["locale"], "locale missing!")
        #endif
    }
    
    func testDeviceToken() {
        Journify.setup(with: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        Journify.shared().add(plugin: outputReader)

        waitUntilStarted(analytics: Journify.shared())
        
        Journify.shared().setDeviceToken("1234")
        Journify.shared().track(name: "token check")
        
        let trackEvent: TrackEvent? = outputReader.lastEvent as? TrackEvent
        let device = trackEvent?.context?.dictionaryValue
        let token = device?[keyPath: "device.token"] as? String
        XCTAssertTrue(token == "1234")
    }
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    func testDeviceTokenData() {
        Journify.setup(with: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        Journify.shared().add(plugin: outputReader)
        
        waitUntilStarted(analytics: Journify.shared())
        
        let dataToken = UUID().asData()
        Journify.shared().registeredForRemoteNotifications(deviceToken: dataToken)
        Journify.shared().track(name: "token check")
        
        let trackEvent: TrackEvent? = outputReader.lastEvent as? TrackEvent
        let device = trackEvent?.context?.dictionaryValue
        let token = device?[keyPath: "device.token"] as? String
        XCTAssertTrue(token?.count == 32) // it's a uuid w/o the dashes.  36 becomes 32.
    }
    #endif
    
    func testTrack() {
        Journify.setup(with: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        Journify.shared().add(plugin: outputReader)
        
        waitUntilStarted(analytics: Journify.shared())
        
        Journify.shared().track(name: "test track")
        
        let trackEvent: TrackEvent? = outputReader.lastEvent as? TrackEvent
        XCTAssertTrue(trackEvent?.event == "test track")
        XCTAssertTrue(trackEvent?.type == "track")
    }
    
    func testIdentify() {
        Journify.setup(with: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        Journify.shared().add(plugin: outputReader)
        
        waitUntilStarted(analytics: Journify.shared())
        
        Journify.shared().identify(userId: "BenMed", traits: MyTraits(email: "ben@med.com"))
        
        let identifyEvent: IdentifyEvent? = outputReader.lastEvent as? IdentifyEvent
        XCTAssertTrue(identifyEvent?.userId == "BenMed")
        let traits = identifyEvent?.traits?.dictionaryValue
        XCTAssertTrue(traits?["email"] as? String == "ben@med.com")
    }

    func testUserIdAndTraitsPersistCorrectly() {
        Journify.setup(with: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        Journify.shared().add(plugin: outputReader)
        
        waitUntilStarted(analytics: Journify.shared())
        
        Journify.shared().identify(userId: "BenMed", traits: MyTraits(email: "ben@med.com"))
        
        let identifyEvent: IdentifyEvent? = outputReader.lastEvent as? IdentifyEvent
        XCTAssertTrue(identifyEvent?.userId == "BenMed")
        let traits = identifyEvent?.traits?.dictionaryValue
        XCTAssertTrue(traits?["email"] as? String == "ben@med.com")
        
        Journify.shared().track(name: "test")
        
        let trackEvent: TrackEvent? = outputReader.lastEvent as? TrackEvent
        XCTAssertTrue(trackEvent?.userId == "BenMed")
        let trackTraits = trackEvent?.context?.dictionaryValue?["traits"] as? [String: Any]
        XCTAssertNil(trackTraits)
        
        let analyticsTraits: MyTraits? = Journify.shared().traits()
        XCTAssertEqual("ben@med.com", analyticsTraits?.email)
    }
    

    func testScreen() {
        Journify.setup(with: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        Journify.shared().add(plugin: outputReader)
        
        waitUntilStarted(analytics: Journify.shared())
        
        Journify.shared().screen(title: "screen1", category: "category1")
        
        let screen1Event: ScreenEvent? = outputReader.lastEvent as? ScreenEvent
        XCTAssertTrue(screen1Event?.name == "screen1")
        XCTAssertTrue(screen1Event?.category == "category1")
        
        Journify.shared().screen(title: "screen2", category: "category2", properties: MyTraits(email: "ben@med.com"))
        
        let screen2Event: ScreenEvent? = outputReader.lastEvent as? ScreenEvent
        XCTAssertTrue(screen2Event?.name == "screen2")
        XCTAssertTrue(screen2Event?.category == "category2")
        let props = screen2Event?.properties?.dictionaryValue
        XCTAssertTrue(props?["email"] as? String == "ben@med.com")
    }
    
    func testTraitsExistenceInTrackEvents() {
        Journify.setup(with: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        Journify.shared().add(plugin: outputReader)
        
        waitUntilStarted(analytics: Journify.shared())
        
        Journify.shared().identify(userId: "BenMed", traits: MyTraits(email: "ben@med.com"))
        Journify.shared().track(name: "test track")
        
        let trackEvent: TrackEvent? = outputReader.lastEvent as? TrackEvent
        let traits = trackEvent?.traits?.dictionaryValue

        XCTAssertTrue(trackEvent?.event == "test track")
        XCTAssertTrue(trackEvent?.type == "track")
        XCTAssertTrue(traits?["email"] as? String == "ben@med.com")
    }
    
    func testTraitsExistenceInScreenEvents() {
        Journify.setup(with: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        Journify.shared().add(plugin: outputReader)
        
        waitUntilStarted(analytics: Journify.shared())
        
        Journify.shared().identify(userId: "BenMed", traits: MyTraits(email: "ben@med.com"))
        Journify.shared().screen(title: "screen1", category: "category1")

        let screenEvent: ScreenEvent? = outputReader.lastEvent as? ScreenEvent
        let traits = screenEvent?.traits?.dictionaryValue

        XCTAssertTrue(screenEvent?.name == "screen1")
        XCTAssertTrue(screenEvent?.type == "page")
        XCTAssertTrue(traits?["email"] as? String == "ben@med.com")
    }
    
    func testReset() {
        Journify.setup(with: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        Journify.shared().add(plugin: outputReader)
        
        waitUntilStarted(analytics: Journify.shared())
        
        Journify.shared().identify(userId: "BenMed", traits: MyTraits(email: "ben@med.com"))
        
        let identifyEvent: IdentifyEvent? = outputReader.lastEvent as? IdentifyEvent
        XCTAssertTrue(identifyEvent?.userId == "BenMed")
        let traits = identifyEvent?.traits?.dictionaryValue
        XCTAssertTrue(traits?["email"] as? String == "ben@med.com")
        
        let currentAnonId = Journify.shared().anonymousId
        let currentUserInfo: UserInfo? = Journify.shared().store.currentState()

        Journify.shared().reset()
        
        let newAnonId = Journify.shared().anonymousId
        let newUserInfo: UserInfo? = Journify.shared().store.currentState()
        XCTAssertNotEqual(currentAnonId, newAnonId)
        XCTAssertNotEqual(currentUserInfo?.anonymousId, newUserInfo?.anonymousId)
        XCTAssertNotEqual(currentUserInfo?.userId, newUserInfo?.userId)
        XCTAssertNotEqual(currentUserInfo?.traits, newUserInfo?.traits)
    }

    func testFlush() {
        // Use a specific writekey to this test so we do not collide with other cached items.
        Journify.setup(with: Configuration(writeKey: "testFlush_do_not_reuse_this_writekey").flushInterval(9999).flushAt(9999))
        
        waitUntilStarted(analytics: Journify.shared())
        
        Journify.shared().storage.hardReset(doYouKnowHowToUseThis: true)
        
        Journify.shared().identify(userId: "BenMed", traits: MyTraits(email: "ben@med.com"))
    
        let currentBatchCount = Journify.shared().storage.eventFiles(includeUnfinished: true).count
    
        Journify.shared().flush()
        Journify.shared().track(name: "test")
        
        let batches = Journify.shared().storage.eventFiles(includeUnfinished: true)
        let newBatchCount = batches.count
        // 1 new temp file
        XCTAssertTrue(newBatchCount == currentBatchCount + 1, "New Count (\(newBatchCount)) should be \(currentBatchCount) + 1")
    }
    
    func testEnabled() {
        Journify.setup(with: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        Journify.shared().add(plugin: outputReader)

        waitUntilStarted(analytics: Journify.shared())
        
        Journify.shared().track(name: "enabled")
        
        let trackEvent: TrackEvent? = outputReader.lastEvent as? TrackEvent
        XCTAssertTrue(trackEvent!.event == "enabled")

        outputReader.lastEvent = nil
        Journify.shared().enabled = false
        Journify.shared().track(name: "notEnabled")
        
        let noEvent = outputReader.lastEvent
        XCTAssertNil(noEvent)
        
        Journify.shared().enabled = true
        Journify.shared().track(name: "enabled")

        let newEvent: TrackEvent? = outputReader.lastEvent as? TrackEvent
        XCTAssertTrue(newEvent!.event == "enabled")
    }
    
    func testSetFlushIntervalAfter() {
        Journify.setup(with: Configuration(writeKey: "1234"))
        
        waitUntilStarted(analytics: Journify.shared())

        let journify = Journify.shared().find(pluginType: JournifyDestination.self)!
        XCTAssertTrue(journify.flushTimer!.interval == 30)
        
        Journify.shared().flushInterval = 60
        
        RunLoop.main.run(until: Date.distantPast)
        
        XCTAssertTrue(journify.flushTimer!.interval == 60)
    }
    
    func testSetFlushAtAfter() {
        Journify.setup(with: Configuration(writeKey: "1234"))

        waitUntilStarted(analytics: Journify.shared())

        let journify = Journify.shared().find(pluginType: JournifyDestination.self)!
        XCTAssertTrue(journify.flushAt == 20)
        
        Journify.shared().flushAt = 60
        
        RunLoop.main.run(until: Date.distantPast)
        
        XCTAssertTrue(journify.flushAt == 60)
    }
    
    func testPurgeStorage() {
        // Use a specific writekey to this test so we do not collide with other cached items.
        Journify.setup(with: Configuration(writeKey: "testFlush_do_not_reuse_this_writekey").flushInterval(9999).flushAt(9999))

        waitUntilStarted(analytics: Journify.shared())
        
        Journify.shared().storage.hardReset(doYouKnowHowToUseThis: true)
        
        Journify.shared().identify(userId: "BenMed", traits: MyTraits(email: "ben@med.com"))
    
        let currentPendingCount = Journify.shared().pendingUploads!.count
        
        XCTAssertEqual(currentPendingCount, 1)
    
        Journify.shared().flush()
        Journify.shared().track(name: "test")
        
        Journify.shared().flush()
        Journify.shared().track(name: "test")
        
        Journify.shared().flush()
        Journify.shared().track(name: "test")
        
        var newPendingCount = Journify.shared().pendingUploads!.count
        XCTAssertEqual(newPendingCount, 4)
        
        let pending = Journify.shared().pendingUploads!
        Journify.shared().purgeStorage(fileURL: pending.first!)

        newPendingCount = Journify.shared().pendingUploads!.count
        XCTAssertEqual(newPendingCount, 3)
        
        Journify.shared().purgeStorage()
        newPendingCount = Journify.shared().pendingUploads!.count
        XCTAssertEqual(newPendingCount, 0)
    }
    
    func testVersion() {
        Journify.setup(with: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        Journify.shared().add(plugin: outputReader)
        
        waitUntilStarted(analytics: Journify.shared())
        
        Journify.shared().track(name: "whataversion")
        
        let trackEvent: TrackEvent? = outputReader.lastEvent as? TrackEvent
        let context = trackEvent?.context?.dictionaryValue
        let eventVersion = context?[keyPath: "library.version"] as? String
        let analyticsVersion = Journify.shared().version()
        
        XCTAssertEqual(eventVersion, analyticsVersion)
    }
    
    class AnyDestination: DestinationPlugin {
        var timeline: Timeline
        let type: PluginType
        let key: String
        var analytics: Journify?
        
        init(key: String) {
            self.key = key
            self.type = .destination
            self.timeline = Timeline()
        }
    }
    
    func testRequestFactory() {
        let config = Configuration(writeKey: "testSequential").requestFactory { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "Accept-Encoding"), "gzip")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json; charset=utf-8")
            XCTAssertTrue(request.value(forHTTPHeaderField: "User-Agent")!.contains("analytics-ios/"))
            return request
        }.errorHandler { error in
            switch error {
            case AnalyticsError.networkServerRejected(_):
                // we expect this one; it's a bogus writekey
                break;
            default:
                XCTFail("\(error)")
            }
        }
        Journify.setup(with: config)
        Journify.shared().storage.hardReset(doYouKnowHowToUseThis: true)
        let outputReader = OutputReaderPlugin()
        Journify.shared().add(plugin: outputReader)
        
        waitUntilStarted(analytics: Journify.shared())
        
        Journify.shared().track(name: "something")
        
        Journify.shared().flush()
        
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 5))
    }
}
