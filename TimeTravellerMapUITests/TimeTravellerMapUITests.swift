//
//  TimeTravellerMapUITests.swift
//  TimeTravellerMapUITests
//
//  Created by Lingxin Gu on 26/06/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import XCTest

class TimeTravellerMapUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testGetPermission() {
        
    }
    
    func testMoveMapFromNowToOld() {
        XCUIApplication().childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).elementBoundByIndex(3).sliders["100%"].tap()
    }
    
    func testChangeAlpha() {
        
        let app = XCUIApplication()
        let alphaSlider = app.sliders["alphaSlider"]
        alphaSlider.adjustToNormalizedSliderPosition(0.7)
    }
    
    func testMoveDateSlider() {
        
        let app = XCUIApplication()
        let overlay = app.otherElements["overlayView"]
    }
    
    func testAddNewMap() {
        
    }
    
    func testAddNewAnnotation() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Annotation"].tap()
        app.navigationBars["Annotation"].buttons["Add"].tap()
        
        let tablesQuery = app.tables
        let nameCellsQuery = tablesQuery.cells.containingType(.StaticText, identifier:"Name")
        nameCellsQuery.childrenMatchingType(.TextField).element.tap()
        nameCellsQuery.childrenMatchingType(.TextField).element
        
        let dateCellsQuery = tablesQuery.cells.containingType(.StaticText, identifier:"Date")
        dateCellsQuery.childrenMatchingType(.TextField).element.tap()
        dateCellsQuery.childrenMatchingType(.TextField).element
        
        let areaCellsQuery = tablesQuery.cells.containingType(.StaticText, identifier:"Area")
        areaCellsQuery.childrenMatchingType(.TextField).element.tap()
        areaCellsQuery.childrenMatchingType(.TextField).element
        
        let cell = tablesQuery.childrenMatchingType(.Cell).elementBoundByIndex(5)
        let textView = cell.childrenMatchingType(.TextView).element
        textView.tap()
        textView.tap()
        cell.childrenMatchingType(.TextView).element
        
    }
}
