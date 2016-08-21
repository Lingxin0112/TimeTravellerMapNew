//
//  AddEventTableViewControllerTests.swift
//  TimeTravellerMap
//
//  Created by Lingxin Gu on 15/08/2016.
//  Copyright © 2016 Lingxin Gu. All rights reserved.
//

import XCTest
import UIKit
@testable import TimeTravellerMap

class AddEventTableViewControllerTests: XCTestCase {
    
    var viewController: AddEventTableViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewController = UIStoryboard(name: "Annotation", bundle: nil).instantiateViewControllerWithIdentifier("AddEventTableViewController") as! AddEventTableViewController
        let _ = viewController.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAddNewEventIntoDatabase() {
        viewController.nameTextField.text = "TestName"
        viewController.areaTextField.text = "TestArea"
        
        viewController.done(viewController.navigationItem.rightBarButtonItem!)
    }
}
