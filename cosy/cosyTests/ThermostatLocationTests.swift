//
//  ThermostatLocationTests.swift
//  cosy
//
//  Created by James Bampoe on 14/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import XCTest
@testable import cosy

class ThermostatLocationTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testThermostatLocationConstructor() {
    let identifier = "specialIdentifier"
    let locationName = "office"
    let isOccupied = false
    let location = ThermostatLocation(identifier: identifier, locationName: locationName, isOccupied: isOccupied)
    XCTAssertEqual(location.identifier, identifier)
    XCTAssertEqual(location.locationName, locationName)
    XCTAssertEqual(location.isOccupied, isOccupied)
  }
  
  func testThermostatLocationConvenienceConstructor() {
    let identifier = "specialIdentifier"
    let locationName = "office"
    let location = ThermostatLocation(identifier: identifier, locationName: locationName)
    XCTAssertEqual(location.identifier, identifier)
    XCTAssertEqual(location.locationName, locationName)
    XCTAssertEqual(location.isOccupied, false)
  }
  
  func testThermostatLocationConvenienceConstructors() {
    let identifier = "specialIdentifier"
    let location = ThermostatLocation(identifier: identifier)
    XCTAssertEqual(location.identifier, identifier)
    XCTAssertTrue(!location.locationName.isEmpty, "The location name should not be empty")
    XCTAssertEqual(location.isOccupied, false)
  }
  
  func testAddingThermostatToLocation() {
    let location = ThermostatLocation(identifier: "specialIdentifier")
    let thermostat = Thermostat(name: "newThermostat", correspondingLocation: location)
    location.addThermostat(thermostat)
    XCTAssertTrue(location.thermostats.contains(thermostat), "the array of thermostats should contain the added thermostat")
  }
  
  func testLocationsWithDifferentIdentifiers() {
    let location1 = ThermostatLocation(identifier: "specialIdentifier1")
    let location2 = ThermostatLocation(identifier: "specialIdentifier2")
    XCTAssertNotEqual(location1, location2)
  }
  
  func testLocationsWithSameIdentifiers() {
    let location1 = ThermostatLocation(identifier: "specialIdentifier")
    let location2 = ThermostatLocation(identifier: "specialIdentifier")
    XCTAssertEqual(location1, location2)
  }
  
  func testImageNameShouldChangeAccordingToOccupiedState() {
    let location = ThermostatLocation(identifier: "specialIdentifier", locationName: "office", isOccupied: false)
    let imageNameWithLocationUnoccupied = location.imageName
    location.isOccupied = true
    let imageNameWithLocationOccupied = location.imageName
    XCTAssertNotEqual(imageNameWithLocationOccupied, imageNameWithLocationUnoccupied)
  }
}
