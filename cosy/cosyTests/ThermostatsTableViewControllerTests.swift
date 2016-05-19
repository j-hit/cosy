//
//  ThermostatsTableViewControllerTests.swift
//  cosy
//
//  Created by James Bampoe on 19/05/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import XCTest
@testable import cosy

class ThermostatsTableViewControllerTests: XCTestCase {
  
  var viewController: ThermostatsTableViewController!
  
  override func setUp() {
    super.setUp()
    ApplicationSettingsManager.sharedInstance.mockModeEnabled = true
    
    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    viewController = storyboard.instantiateViewControllerWithIdentifier("ThermostatView") as! ThermostatsTableViewController
    viewController.loadView()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testExample() {
    viewController.viewDidLoad()
    viewController.viewWillAppear(true)
    XCTAssertTrue(viewController.tableView.numberOfRowsInSection(0) == 3)
  }
  
  func testHeightOfRow() {
    viewController.viewDidLoad()
    viewController.viewWillAppear(true)
    let rowHeight = viewController.tableView(viewController.tableView, estimatedHeightForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
    XCTAssertTrue(rowHeight >= 44.0)
  }
  
  func testRowContent() {
    viewController.viewDidLoad()
    viewController.viewWillAppear(true)
    let row = viewController.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! ThermostatTableViewCell
    XCTAssertFalse(row.thermostatNameLabel.text!.isEmpty)
  }
  
  func testSignOutButton() {
    viewController.viewDidLoad()
    viewController.viewWillAppear(true)
    viewController.signOutPressed(viewController.signOutButton)
    XCTAssertTrue(viewController.tableView(viewController.tableView, numberOfRowsInSection: 0) == 0)
  }
}
