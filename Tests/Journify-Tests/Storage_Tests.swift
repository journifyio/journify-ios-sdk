//
//  StorageTests.swift
//  Journify-Tests
//
//

import XCTest
@testable import Journify

class StorageTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBasicWriting() throws {
        Journify.setup(with: Configuration(writeKey: "test"))
        
        Journify.shared().identify(userId: "benMed", traits: MyTraits(email: "ben@med.com"))
        
        let userInfo: UserInfo? = Journify.shared().store.currentState()
        XCTAssertNotNil(userInfo)
        XCTAssertTrue(userInfo!.userId == "benMed")
        
        // This is a hack that needs to be dealt with
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 2))
        
        if let userId = Journify.shared().storage.userDefaults?.string(forKey: Storage.Constants.userId.rawValue) {
            XCTAssertTrue(userId == "benMed")
        } else {
            XCTFail("Could not read from storage the userId")
        }
    }
    
    //TODO: The test has failed. Please check this function
    func testEventWriting() throws {
        Journify.setup(with: Configuration(writeKey: "test"))
        Journify.shared().storage.hardReset(doYouKnowHowToUseThis: true)

        var event = IdentifyEvent(userId: "benMed1", traits: try! JSON(with: MyTraits(email: "ben@med.com")))
        Journify.shared().storage.write(.events, value: event)

        event = IdentifyEvent(userId: "benMed2", traits: try! JSON(with: MyTraits(email: "ben@med.com")))
        Journify.shared().storage.write(.events, value: event)

        event = IdentifyEvent(userId: "benMed3", traits: try! JSON(with: MyTraits(email: "ben@med.com")))
        Journify.shared().storage.write(.events, value: event)

        let results: [URL]? = Journify.shared().storage.read(.events)

        XCTAssertNotNil(results)

        let fileURL = results![0]

        XCTAssertTrue(fileURL.isFileURL)
        XCTAssertTrue(fileURL.lastPathComponent == "0-journify-events.temp")
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))

        let json = try! JSONSerialization.jsonObject(with: Data(contentsOf: fileURL), options: []) as! [[String: Any]]

        let item1 = json[0]["userId"] as! String
        let item2 = json[1]["userId"] as! String
        let item3 = json[2]["userId"] as! String

        XCTAssertTrue(item1 == "benMed1")
        XCTAssertTrue(item2 == "benMed2")
        XCTAssertTrue(item3 == "benMed3")

        Journify.shared().storage.remove(file: fileURL)

        // make sure our original and temp files are named correctly, and gone.
        let originalFile = fileURL.deletingPathExtension()
        let tempFile = fileURL
        XCTAssertFalse(FileManager.default.fileExists(atPath: originalFile.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempFile.path))
    }
    
    func testFilePrepAndFinish() {
        Journify.setup(with: Configuration(writeKey: "test"))
        Journify.shared().storage.hardReset(doYouKnowHowToUseThis: true)
        
        var event = IdentifyEvent(userId: "benMed1", traits: try! JSON(with: MyTraits(email: "ben@med.com")))
        Journify.shared().storage.write(.events, value: event)
        
        var results: [URL]? = Journify.shared().storage.read(.events)

        XCTAssertNotNil(results)
        
        var fileURL = results![0]
        
        XCTAssertTrue(fileURL.isFileURL)
        XCTAssertTrue(fileURL.lastPathComponent == "0-journify-events.temp")
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
        
        event = IdentifyEvent(userId: "benMed2", traits: try! JSON(with: MyTraits(email: "ben@med.com")))
        Journify.shared().storage.write(.events, value: event)
        
        results = Journify.shared().storage.read(.events)
        
        XCTAssertNotNil(results)
        
        fileURL = results![0]
        
        XCTAssertTrue(fileURL.isFileURL)
        XCTAssertTrue(fileURL.lastPathComponent == "1-journify-events.temp")
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
    }
    
}
