//
//  DataAccessorTests.swift
//  cosy
//
//  Created by James Bampoe on 16/05/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import XCTest
@testable import cosy

class DataAccessorTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testAccessibleDataPointRoomTemperature() {
    let datapoint = AccessibleThermostatDataPoint.roomTemperature
    XCTAssertTrue(datapoint.stringRepresentation == "RTemp")
  }
  
  func testAccessibleDataPointTemperatureSetpoint() {
    let datapoint = AccessibleThermostatDataPoint.temperatureSetPoint
    XCTAssertTrue(datapoint.stringRepresentation == "SpTR")
  }
  
  func testAccessibleDataPointOccupationMode() {
    let datapoint = AccessibleThermostatDataPoint.occupationMode
    XCTAssertTrue(datapoint.stringRepresentation == "OccMod")
  }
  
  func testAccessibleDataPointComfortMode() {
    let datapoint = AccessibleThermostatDataPoint.comfortMode
    XCTAssertTrue(datapoint.stringRepresentation == "CmfBtn")
  }
}
