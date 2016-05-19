//
//  ThermostatManagerMockTests.swift
//  cosy
//
//  Created by James Bampoe on 17/05/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import XCTest
@testable import cosy

class ThermostatManagerMockTests: XCTestCase {
  
  var thermostatManager: ThermostatManagerMock?
  
  override func setUp() {
    thermostatManager = ThermostatManagerMock(settingsProvider: ApplicationSettingsManager.sharedInstance)
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testShouldFetchAtLeastOneThermostat() {
    thermostatManager?.fetchNewListOfThermostats()
    XCTAssertTrue(thermostatManager?.thermostats.count > 0)
    
    let amountOfThermostats = thermostatManager?.thermostats.count
    thermostatManager?.fetchNewListOfThermostats()
    XCTAssertTrue(amountOfThermostats == thermostatManager?.thermostats.count)
  }
  
  func testSettingFavouriteThermostat() {
    thermostatManager?.fetchNewListOfThermostats()
    let thermostatToBeFavourite = thermostatManager?.thermostats.first!
    thermostatManager?.favouriteThermostat = thermostatToBeFavourite
    
    XCTAssertTrue(thermostatManager!.favouriteThermostat!.identifier == thermostatToBeFavourite!.identifier)
  }
  
  func testShouldUpdateCurrentTemperatureOfThermostat() {
    thermostatManager?.fetchNewListOfThermostats()
    let thermostat = thermostatManager?.thermostats.first
    thermostat?.currentTemperature = 100
    thermostatManager?.updateData(ofThermostat: thermostat!)
    XCTAssertTrue(thermostat?.currentTemperature != 100)
  }
  
  func testShouldClearListOfThermostats() {
    thermostatManager?.fetchNewListOfThermostats()
    thermostatManager?.clearAllData()
    XCTAssertTrue(thermostatManager?.thermostats.count == 0)
  }
  
  func testExportImportOfData() {
    thermostatManager?.fetchNewListOfThermostats()
    let export = thermostatManager?.exportThermostatsAsNSData()
    thermostatManager?.clearAllData()
    thermostatManager?.importThermostats(fromNSDataObject: export)
    XCTAssertTrue(thermostatManager?.thermostats.count > 0)
  }
  
  func testSavingThermostatValues() {
    thermostatManager?.fetchNewListOfThermostats()
    thermostatManager?.saveTemperatureSetPointOfThermostat(thermostatManager!.thermostats.first!)
    thermostatManager?.saveMode(ofThermostat: thermostatManager!.thermostats.first!, toMode: .Home)
  }
  
  func testChangingFavouriteThermostat() {
    thermostatManager?.fetchNewListOfThermostats()
    let firstThermostat = thermostatManager?.thermostats.first!
    thermostatManager?.favouriteThermostat = firstThermostat
    let secondThermostat = thermostatManager?.thermostats[1]
    thermostatManager?.favouriteThermostat = secondThermostat
    
    XCTAssertTrue(thermostatManager?.favouriteThermostat!.identifier == secondThermostat?.identifier)
  }
}
