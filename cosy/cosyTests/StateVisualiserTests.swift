//
//  StateVisualiserTests.swift
//  cosy
//
//  Created by James Bampoe on 14/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import XCTest
@testable import cosy

class StateVisualiserTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testIdleStateVisualiser() {
    let visualiser = IdleStateVisualiser()
    XCTAssertTrue(!visualiser.circularImageName.isEmpty, "The idle state visualiser should have a circular image name defined")
  }
  
  func testHeatingStateVisualiser() {
    let visualiser = HeatingStateVisualiser()
    XCTAssertTrue(!visualiser.circularImageName.isEmpty, "The heating state visualiser should have a circular image name defined")
  }
  
  func testCoolingStateVisualiser() {
    let visualiser = CoolingStateVisualiser()
    XCTAssertTrue(!visualiser.circularImageName.isEmpty, "The cooling state visualiser should have a circular image name defined")
  }
  
  func testIdleStateVisualiserTextColor() {
    XCTAssertTrue(IdleStateVisualiser().textColor == UIColor.blackColor())
  }
  
  func testHeatingStateVisualiserTextColor() {
    XCTAssertTrue(HeatingStateVisualiser().textColor == UIColor.whiteColor())
  }
  
  func testCoolingStateVisualiserTextColor() {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
    XCTAssertTrue(CoolingStateVisualiser().textColor == UIColor.whiteColor())
  }
  
  func testColorOfStateVisualisersShouldBeDifferent() {
    let idleVisualiser = IdleStateVisualiser()
    let heatingVisualiser = HeatingStateVisualiser()
    let coolingVisualiser = CoolingStateVisualiser()
    
    XCTAssertNotEqual(idleVisualiser.color, heatingVisualiser.color)
    XCTAssertNotEqual(idleVisualiser.color, coolingVisualiser.color)
    XCTAssertNotEqual(coolingVisualiser.color, heatingVisualiser.color)
  }
  
  func testCircularImageNameOfStateVisualisersShouldBeDifferent() {
    let idleVisualiser = IdleStateVisualiser()
    let heatingVisualiser = HeatingStateVisualiser()
    let coolingVisualiser = CoolingStateVisualiser()
    
    XCTAssertNotEqual(idleVisualiser.circularImageName, heatingVisualiser.circularImageName)
    XCTAssertNotEqual(idleVisualiser.circularImageName, coolingVisualiser.circularImageName)
    XCTAssertNotEqual(coolingVisualiser.circularImageName, heatingVisualiser.circularImageName)
  }

}
