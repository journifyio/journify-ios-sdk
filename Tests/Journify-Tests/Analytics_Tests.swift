import XCTest
@testable import Journify

final class Analytics_Tests: XCTestCase {
    
    func testBaseEventCreation() {
        let analytics = Journify(configuration: Configuration(writeKey: "test"))
        let myDestination = MyDestination()
        myDestination.add(plugin: GooberPlugin())
        
        analytics.add(plugin: ZiggyPlugin())
        analytics.add(plugin: myDestination)
        
        let traits = MyTraits(email: "brandon@redf.net")
        analytics.identify(userId: "brandon", traits: traits)
    }
    
    func testPluginConfigure() {
        let analytics = Journify(configuration: Configuration(writeKey: "test"))
        let ziggy = ZiggyPlugin()
        let myDestination = MyDestination()
        let goober = GooberPlugin()
        myDestination.add(plugin: goober)

        analytics.add(plugin: ziggy)
        analytics.add(plugin: myDestination)
        
        XCTAssertNotNil(ziggy.analytics)
        XCTAssertNotNil(myDestination.analytics)
        XCTAssertNotNil(goober.analytics)
    }
    
    func testPluginRemove() {
        let analytics = Journify(configuration: Configuration(writeKey: "test"))
        let myDestination = MyDestination()
        myDestination.add(plugin: GooberPlugin())
        
        let expectation = XCTestExpectation(description: "Ziggy Expectation")
        let ziggy = ZiggyPlugin()
        ziggy.completion = {
            expectation.fulfill()
        }
        analytics.add(plugin: ziggy)
        analytics.add(plugin: myDestination)
        
        let traits = MyTraits(email: "brandon@redf.net")
        analytics.identify(userId: "brandon", traits: traits)
        analytics.remove(plugin: ziggy)
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testDestinationEnabled() {
        // need to clear settings for this one.
        UserDefaults.standard.removePersistentDomain(forName: "com.journify.storage.test")
        
        let expectation = XCTestExpectation(description: "MyDestination Expectation")
        let myDestination = MyDestination {
            expectation.fulfill()
            return true
        }

        let configuration = Configuration(writeKey: "test")
        let analytics = Journify(configuration: configuration)

        analytics.add(plugin: myDestination)
        
        waitUntilStarted(analytics: analytics)
        
        analytics.track(name: "testDestinationEnabled")
        
        let dest = analytics.find(key: myDestination.key)
        XCTAssertNotNil(dest)
        XCTAssertTrue(dest is MyDestination)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAnonymousId() {
        let analytics = Journify(configuration: Configuration(writeKey: "test"))
        let anonId = analytics.anonymousId
        
        XCTAssertTrue(anonId != "")
        XCTAssertTrue(anonId.count == 36) // it's a UUID y0.
    }
    
    func testContext() {
        let analytics = Journify(configuration: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        analytics.add(plugin: outputReader)

        waitUntilStarted(analytics: analytics)
        
        // add a referrer
        analytics.openURL(URL(string: "https://google.com")!)
        
        analytics.track(name: "token check")
        
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
        let analytics = Journify(configuration: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        analytics.add(plugin: outputReader)

        waitUntilStarted(analytics: analytics)
        
        analytics.setDeviceToken("1234")
        analytics.track(name: "token check")
        
        let trackEvent: TrackEvent? = outputReader.lastEvent as? TrackEvent
        let device = trackEvent?.context?.dictionaryValue
        let token = device?[keyPath: "device.token"] as? String
        XCTAssertTrue(token == "1234")
    }
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    func testDeviceTokenData() {
        let analytics = Journify(configuration: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        analytics.add(plugin: outputReader)
        
        waitUntilStarted(analytics: analytics)
        
        let dataToken = UUID().asData()
        analytics.registeredForRemoteNotifications(deviceToken: dataToken)
        analytics.track(name: "token check")
        
        let trackEvent: TrackEvent? = outputReader.lastEvent as? TrackEvent
        let device = trackEvent?.context?.dictionaryValue
        let token = device?[keyPath: "device.token"] as? String
        XCTAssertTrue(token?.count == 32) // it's a uuid w/o the dashes.  36 becomes 32.
    }
    #endif
    
    func testTrack() {
        let analytics = Journify(configuration: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        analytics.add(plugin: outputReader)
        
        waitUntilStarted(analytics: analytics)
        
        analytics.track(name: "test track")
        
        let trackEvent: TrackEvent? = outputReader.lastEvent as? TrackEvent
        XCTAssertTrue(trackEvent?.event == "test track")
        XCTAssertTrue(trackEvent?.type == "track")
    }
    
    func testIdentify() {
        let analytics = Journify(configuration: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        analytics.add(plugin: outputReader)
        
        waitUntilStarted(analytics: analytics)
        
        analytics.identify(userId: "brandon", traits: MyTraits(email: "blah@blah.com"))
        
        let identifyEvent: IdentifyEvent? = outputReader.lastEvent as? IdentifyEvent
        XCTAssertTrue(identifyEvent?.userId == "brandon")
        let traits = identifyEvent?.traits?.dictionaryValue
        XCTAssertTrue(traits?["email"] as? String == "blah@blah.com")
    }

    func testUserIdAndTraitsPersistCorrectly() {
        let analytics = Journify(configuration: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        analytics.add(plugin: outputReader)
        
        waitUntilStarted(analytics: analytics)
        
        analytics.identify(userId: "brandon", traits: MyTraits(email: "blah@blah.com"))
        
        let identifyEvent: IdentifyEvent? = outputReader.lastEvent as? IdentifyEvent
        XCTAssertTrue(identifyEvent?.userId == "brandon")
        let traits = identifyEvent?.traits?.dictionaryValue
        XCTAssertTrue(traits?["email"] as? String == "blah@blah.com")
        
        analytics.track(name: "test")
        
        let trackEvent: TrackEvent? = outputReader.lastEvent as? TrackEvent
        XCTAssertTrue(trackEvent?.userId == "brandon")
        let trackTraits = trackEvent?.context?.dictionaryValue?["traits"] as? [String: Any]
        XCTAssertNil(trackTraits)
        
        let analyticsTraits: MyTraits? = analytics.traits()
        XCTAssertEqual("blah@blah.com", analyticsTraits?.email)
    }
    

    func testScreen() {
        let analytics = Journify(configuration: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        analytics.add(plugin: outputReader)
        
        waitUntilStarted(analytics: analytics)
        
        analytics.screen(title: "screen1", category: "category1")
        
        let screen1Event: ScreenEvent? = outputReader.lastEvent as? ScreenEvent
        XCTAssertTrue(screen1Event?.name == "screen1")
        XCTAssertTrue(screen1Event?.category == "category1")
        
        analytics.screen(title: "screen2", category: "category2", properties: MyTraits(email: "blah@blah.com"))
        
        let screen2Event: ScreenEvent? = outputReader.lastEvent as? ScreenEvent
        XCTAssertTrue(screen2Event?.name == "screen2")
        XCTAssertTrue(screen2Event?.category == "category2")
        let props = screen2Event?.properties?.dictionaryValue
        XCTAssertTrue(props?["email"] as? String == "blah@blah.com")
    }
    
    func testReset() {
        let analytics = Journify(configuration: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        analytics.add(plugin: outputReader)
        
        waitUntilStarted(analytics: analytics)
        
        analytics.identify(userId: "brandon", traits: MyTraits(email: "blah@blah.com"))
        
        let identifyEvent: IdentifyEvent? = outputReader.lastEvent as? IdentifyEvent
        XCTAssertTrue(identifyEvent?.userId == "brandon")
        let traits = identifyEvent?.traits?.dictionaryValue
        XCTAssertTrue(traits?["email"] as? String == "blah@blah.com")
        
        let currentAnonId = analytics.anonymousId
        let currentUserInfo: UserInfo? = analytics.store.currentState()

        analytics.reset()
        
        let newAnonId = analytics.anonymousId
        let newUserInfo: UserInfo? = analytics.store.currentState()
        XCTAssertNotEqual(currentAnonId, newAnonId)
        XCTAssertNotEqual(currentUserInfo?.anonymousId, newUserInfo?.anonymousId)
        XCTAssertNotEqual(currentUserInfo?.userId, newUserInfo?.userId)
        XCTAssertNotEqual(currentUserInfo?.traits, newUserInfo?.traits)
    }

    func testFlush() {
        // Use a specific writekey to this test so we do not collide with other cached items.
        let analytics = Journify(configuration: Configuration(writeKey: "testFlush_do_not_reuse_this_writekey").flushInterval(9999).flushAt(9999))
        
        waitUntilStarted(analytics: analytics)
        
        analytics.storage.hardReset(doYouKnowHowToUseThis: true)
        
        analytics.identify(userId: "brandon", traits: MyTraits(email: "blah@blah.com"))
    
        let currentBatchCount = analytics.storage.eventFiles(includeUnfinished: true).count
    
        analytics.flush()
        analytics.track(name: "test")
        
        let batches = analytics.storage.eventFiles(includeUnfinished: true)
        let newBatchCount = batches.count
        // 1 new temp file
        XCTAssertTrue(newBatchCount == currentBatchCount + 1, "New Count (\(newBatchCount)) should be \(currentBatchCount) + 1")
    }
    
    func testEnabled() {
        let analytics = Journify(configuration: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        analytics.add(plugin: outputReader)

        waitUntilStarted(analytics: analytics)
        
        analytics.track(name: "enabled")
        
        let trackEvent: TrackEvent? = outputReader.lastEvent as? TrackEvent
        XCTAssertTrue(trackEvent!.event == "enabled")

        outputReader.lastEvent = nil
        analytics.enabled = false
        analytics.track(name: "notEnabled")
        
        let noEvent = outputReader.lastEvent
        XCTAssertNil(noEvent)
        
        analytics.enabled = true
        analytics.track(name: "enabled")

        let newEvent: TrackEvent? = outputReader.lastEvent as? TrackEvent
        XCTAssertTrue(newEvent!.event == "enabled")
    }
    
    func testSetFlushIntervalAfter() {
        let analytics = Journify(configuration: Configuration(writeKey: "1234"))
        
        waitUntilStarted(analytics: analytics)

        let journify = analytics.find(pluginType: JournifyDestination.self)!
        XCTAssertTrue(journify.flushTimer!.interval == 30)
        
        analytics.flushInterval = 60
        
        RunLoop.main.run(until: Date.distantPast)
        
        XCTAssertTrue(journify.flushTimer!.interval == 60)
    }
    
    func testSetFlushAtAfter() {
        let analytics = Journify(configuration: Configuration(writeKey: "1234"))
        
        waitUntilStarted(analytics: analytics)

        let journify = analytics.find(pluginType: JournifyDestination.self)!
        XCTAssertTrue(journify.flushAt == 20)
        
        analytics.flushAt = 60
        
        RunLoop.main.run(until: Date.distantPast)
        
        XCTAssertTrue(journify.flushAt == 60)
    }
    
    func testPurgeStorage() {
        // Use a specific writekey to this test so we do not collide with other cached items.
        let analytics = Journify(configuration: Configuration(writeKey: "testFlush_do_not_reuse_this_writekey_either").flushInterval(9999).flushAt(9999))
        
        waitUntilStarted(analytics: analytics)
        
        analytics.storage.hardReset(doYouKnowHowToUseThis: true)
        
        analytics.identify(userId: "brandon", traits: MyTraits(email: "blah@blah.com"))
    
        let currentPendingCount = analytics.pendingUploads!.count
        
        XCTAssertEqual(currentPendingCount, 1)
    
        analytics.flush()
        analytics.track(name: "test")
        
        analytics.flush()
        analytics.track(name: "test")
        
        analytics.flush()
        analytics.track(name: "test")
        
        var newPendingCount = analytics.pendingUploads!.count
        XCTAssertEqual(newPendingCount, 4)
        
        let pending = analytics.pendingUploads!
        analytics.purgeStorage(fileURL: pending.first!)

        newPendingCount = analytics.pendingUploads!.count
        XCTAssertEqual(newPendingCount, 3)
        
        analytics.purgeStorage()
        newPendingCount = analytics.pendingUploads!.count
        XCTAssertEqual(newPendingCount, 0)
    }
    
    func testVersion() {
        let analytics = Journify(configuration: Configuration(writeKey: "test"))
        let outputReader = OutputReaderPlugin()
        analytics.add(plugin: outputReader)
        
        waitUntilStarted(analytics: analytics)
        
        analytics.track(name: "whataversion")
        
        let trackEvent: TrackEvent? = outputReader.lastEvent as? TrackEvent
        let context = trackEvent?.context?.dictionaryValue
        let eventVersion = context?[keyPath: "library.version"] as? String
        let analyticsVersion = analytics.version()
        
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
        let analytics = Journify(configuration: config)
        analytics.storage.hardReset(doYouKnowHowToUseThis: true)
        let outputReader = OutputReaderPlugin()
        analytics.add(plugin: outputReader)
        
        waitUntilStarted(analytics: analytics)
        
        analytics.track(name: "something")
        
        analytics.flush()
        
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 5))
    }
}
