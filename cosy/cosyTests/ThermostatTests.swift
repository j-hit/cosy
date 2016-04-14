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
    let location = ThermostatLocation(identifier: "specialIdentifier")
    let thermostat1a = Thermostat(name: "thermostat1", correspondingLocation: location)
    let thermostat1b = Thermostat(name: "thermostat1", correspondingLocation: location)
    
    location.addThermostat(thermostat1a)
    location.addThermostat(thermostat1b)
    
    XCTAssertEqual(thermostat1a, thermostat1b)
  }
  
  func testThermostatsShouldNotBeEqual() {
    let location1 = ThermostatLocation(identifier: "specialIdentifier1")
    let thermostat1 = Thermostat(name: "thermostat", correspondingLocation: location1)
    
    let location2 = ThermostatLocation(identifier: "specialIdentifier2")
    let thermostat2 = Thermostat(name: "thermostat", correspondingLocation: location2)
    
    location1.addThermostat(thermostat1)
    location2.addThermostat(thermostat2)
    
    XCTAssertNotEqual(thermostat1, thermostat2)
  }
  
  func testThermostatConstructor() {
    let thermostatName = "living room"
    
    let location = ThermostatLocation(identifier: "specialIdentifier")
    let thermostat = Thermostat(name: thermostatName, correspondingLocation: location)
    location.addThermostat(thermostat)
    
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
