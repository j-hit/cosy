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
    XCTAssertTrue(!visualiser.description.isEmpty, "The idle state visualiser should have a description defined")
  }
  
  func testHeatingStateVisualiser() {
    let visualiser = HeatingStateVisualiser()
    XCTAssertTrue(!visualiser.description.isEmpty, "The heating state visualiser should have a description defined")
  }
  
  func testCoolingStateVisualiser() {
    let visualiser = CoolingStateVisualiser()
    XCTAssertTrue(!visualiser.description.isEmpty, "The cooling state visualiser should have a description defined")
  }
  
  func testColorOfStateVisualisersShouldBeDifferent() {
    let idleVisualiser = IdleStateVisualiser()
    let heatingVisualiser = HeatingStateVisualiser()
    let coolingVisualiser = CoolingStateVisualiser()
    
    XCTAssertNotEqual(idleVisualiser.color, heatingVisualiser.color)
    XCTAssertNotEqual(idleVisualiser.color, coolingVisualiser.color)
    XCTAssertNotEqual(coolingVisualiser.color, heatingVisualiser.color)
  }
  
  func testDescriptionOfStateVisualisersShouldBeDifferent() {
    let idleVisualiser = IdleStateVisualiser()
    let heatingVisualiser = HeatingStateVisualiser()
    let coolingVisualiser = CoolingStateVisualiser()
    
    XCTAssertNotEqual(idleVisualiser.description, heatingVisualiser.description)
    XCTAssertNotEqual(idleVisualiser.description, coolingVisualiser.description)
    XCTAssertNotEqual(coolingVisualiser.description, heatingVisualiser.description)
  }

}
