//
//  ThermostatTests.swift
//  cosy
//
//  Created by James Bampoe on 14/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import XCTest
@testable import cosy

class ThermostatTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testMaxTemperatureValueLargerThanMinValue() {
    XCTAssertLessThan(Thermostat.minimumTemperatureValue, Thermostat.maximumTemperatureValue)
  }
  
  func testThermostatsShouldBeEqual() {
    let thermostat1a = Thermostat(identifier: "specialIdentifier", name: "thermostat1")
    let thermostat1b = thermostat1a
    
    XCTAssertEqual(thermostat1a, thermostat1b)
  }
  
  func testThermostatsShouldNotBeEqual() {
    let thermostat1 = Thermostat(identifier: "specialIdentifier1", name: "thermostat")
    let thermostat2 = Thermostat(identifier: "specialIdentifier2", name: "thermostat")
    
    XCTAssertNotEqual(thermostat1, thermostat2)
  }
  
  func testThermostatConstructor() {
    let thermostatName = "living room"
    
    let thermostat = Thermostat(identifier: "specialIdentifier", name: thermostatName)
    
    XCTAssertEqual(thermostat.name, thermostatName)
  }
  
  func testThermostatStateCoolingVisualiser() {
    let coolingVisualiser = ThermostatState.Cooling.visualiser() as? CoolingStateVisualiser
    XCTAssertNotNil(coolingVisualiser)
  }
  
  func testThermostatStateHeatingVisualiser() {
    let heatingVisualiser = ThermostatState.Heating.visualiser() as? HeatingStateVisualiser
    XCTAssertNotNil(heatingVisualiser)
  }
  
  func testThermostatStateIdleVisualiser() {
    let idleVisualiser = ThermostatState.Idle.visualiser() as? IdleStateVisualiser
    XCTAssertNotNil(idleVisualiser)
  }
}
