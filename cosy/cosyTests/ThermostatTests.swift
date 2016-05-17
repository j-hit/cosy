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
  
  func testSettingThermostatAttributes() {
    let thermostat = Thermostat(identifier: "myIdentifier")
    let currentTemperature = 16
    let isInAutoMode = false
    let isMarkedAsFavourite = true
    let isOccupied = true
    let name = "myThermostat"
    let temperatureSetPoint = 20
    
    thermostat.currentTemperature = currentTemperature
    thermostat.isInAutoMode = isInAutoMode
    thermostat.isMarkedAsFavourite = isMarkedAsFavourite
    thermostat.isOccupied = isOccupied
    thermostat.name = name
    thermostat.temperatureSetPoint = temperatureSetPoint
    
    XCTAssertEqual(currentTemperature, thermostat.currentTemperature)
    XCTAssertEqual(isInAutoMode, thermostat.isInAutoMode)
    XCTAssertEqual(isMarkedAsFavourite, thermostat.isMarkedAsFavourite)
    XCTAssertEqual(isOccupied, thermostat.isOccupied)
    XCTAssertEqual(name, thermostat.name)
    XCTAssertEqual(temperatureSetPoint, thermostat.temperatureSetPoint)
  }
  
  func testThermostatShouldBeInCoolingState() {
    let thermostat = Thermostat(identifier: "myIdentifier")
    thermostat.currentTemperature = 20
    thermostat.temperatureSetPoint = 16
    let state = thermostat.state
    XCTAssertTrue(thermostat.currentTemperature > thermostat.temperatureSetPoint)
    XCTAssertTrue(state == .Cooling)
  }
  
  func testThermostatShouldBeInHeatingState() {
    let thermostat = Thermostat(identifier: "myIdentifier")
    thermostat.currentTemperature = 14
    thermostat.temperatureSetPoint = 20
    let state = thermostat.state
    XCTAssertTrue(thermostat.currentTemperature < thermostat.temperatureSetPoint)
    XCTAssertTrue(state == .Heating)
  }
  
  func testThermostatShouldBeInIdleState() {
    let thermostat = Thermostat(identifier: "myIdentifier")
    thermostat.currentTemperature = 12
    thermostat.temperatureSetPoint = 12
    let state = thermostat.state
    XCTAssertTrue(thermostat.currentTemperature == thermostat.temperatureSetPoint)
    XCTAssertTrue(state == .Idle)
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
