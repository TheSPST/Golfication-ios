//
//  GolficationUITests.swift
//  GolficationUITests
//
//  Created by Rishabh Sood on 20/04/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import XCTest

class GolficationUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        
//        let app = XCUIApplication()
//        setupSnapshot(app)
//        app.launch()
        XCUIApplication().launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
//    func testScreenshots() {
//        let app = XCUIApplication()
//        XCUIDevice.shared.orientation = .portrait
//
//        let tabBarsQuery = XCUIApplication().tabBars
//        // Home
//        tabBarsQuery.buttons.element(boundBy: 0).tap()
//        snapshot("Home")
//
//        // Map
//        tabBarsQuery.buttons.element(boundBy: 1).tap()
//        app.otherElements["eventlocation"].tap()
//        snapshot("Together")
//
//        // Twitter
//        tabBarsQuery.buttons.element(boundBy: 2).tap()
//        snapshot("Profile")
//    }
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
