//
//  cosyTests.swift
//  cosyTests
//
//  Created by James Bampoe on 05/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import XCTest
@testable import cosy

class applicationSettingsManagerTests: XCTestCase {
  
  let applicationSettingsManager = ApplicationSettingsManager.sharedInstance
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testSettingMockModeEnabledFlag() {
    applicationSettingsManager.mockModeEnabled = false
    XCTAssertFalse(applicationSettingsManager.mockModeEnabled)
    applicationSettingsManager.mockModeEnabled = true
    XCTAssertTrue(applicationSettingsManager.mockModeEnabled)
  }
  
  func testSettingLastUsedEmailAddress() {
    let lastUsedEmail = "lastused@email.com"
    applicationSettingsManager.lastUsedEmailAddress = lastUsedEmail
    XCTAssertEqual(lastUsedEmail, applicationSettingsManager.lastUsedEmailAddress)
  }
  
  func testSettingLastUsedPassword() {
    let lastUsedPassword = "1astu5edSecretPa55w@rD"
    applicationSettingsManager.lastUsedPassword = lastUsedPassword
    XCTAssertEqual(lastUsedPassword, applicationSettingsManager.lastUsedPassword)
  }
  
  func testSettingBaseURLOfCPSCloud() {
    let baseURLOfCPSCloud = "https://baseurlOfCPSCloud.com/api"
    applicationSettingsManager.baseURLOfCPSCloud = baseURLOfCPSCloud
    XCTAssertEqual(baseURLOfCPSCloud, applicationSettingsManager.baseURLOfCPSCloud)
  }
  
  func testBaseURLShouldNeverEmpty() {
    let baseURLOfCPSCloud = ""
    applicationSettingsManager.baseURLOfCPSCloud = baseURLOfCPSCloud
    XCTAssertTrue(applicationSettingsManager.baseURLOfCPSCloud.isEmpty == false)
  }
  
  func testSettingSessionID() {
    let sessionID = "myTestSessionID"
    applicationSettingsManager.sessionID = sessionID
    XCTAssertEqual(sessionID, applicationSettingsManager.sessionID)
    applicationSettingsManager.sessionID = nil
    XCTAssertEqual(applicationSettingsManager.sessionID, nil)
  }
  
  func testKeyShouldNotBeEmpty() {
    XCTAssertFalse(applicationSettingsManager.key.isEmpty)
  }
  
  func testApplicationSettingsCanBeExportedAsDictionary() {
    let sessionID = "myTestSessionID"
    applicationSettingsManager.sessionID = sessionID
    
    let export = applicationSettingsManager.exportAsDictionary()
    XCTAssertTrue(export["sessionID"] as? String == sessionID)
  }
  
  func testExportedSessionIDShouldBeEmptyIfNonIsSet() {
    applicationSettingsManager.sessionID = nil
    let export = applicationSettingsManager.exportAsDictionary()
    applicationSettingsManager.sessionID = "modifiedSessionID"
    applicationSettingsManager.importFromDictionary(export)
    
    XCTAssertTrue(export["sessionID"] as? String == "")
    XCTAssertTrue(applicationSettingsManager.sessionID == nil)
  }
  
  func testApplicationSettingsCanBeImportedFromDictionary() {
    let sessionID = "myTestSessionID"
    let mockModeEnabled = true
    let baseURL = "https://cosy.rdzug.net/api"
    
    applicationSettingsManager.sessionID = sessionID
    applicationSettingsManager.mockModeEnabled = mockModeEnabled
    applicationSettingsManager.baseURLOfCPSCloud = baseURL
    let export = applicationSettingsManager.exportAsDictionary()
    
    applicationSettingsManager.sessionID = "modifiedSessionID"
    applicationSettingsManager.mockModeEnabled = false
    applicationSettingsManager.baseURLOfCPSCloud = "https://modified-url.net"
    
    applicationSettingsManager.importFromDictionary(export)
    
    XCTAssertTrue(applicationSettingsManager.sessionID == sessionID)
    XCTAssertTrue(applicationSettingsManager.mockModeEnabled == mockModeEnabled)
    XCTAssertTrue(applicationSettingsManager.baseURLOfCPSCloud == baseURL)
  }
  
  func testSettingFavouriteThermostat() {
    let thermostat = Thermostat(identifier: "myFavouriteThermostat")
    
    applicationSettingsManager.favouriteThermostat = thermostat
    
    XCTAssertTrue(applicationSettingsManager.favouriteThermostat?.identifier == thermostat.identifier)
  }
  
  func testRemovingFavouriteThermostat() {
    let thermostat = Thermostat(identifier: "myFavouriteThermostat")
    applicationSettingsManager.favouriteThermostat = thermostat
    applicationSettingsManager.favouriteThermostat = nil
    
    let favouriteThermostat = applicationSettingsManager.favouriteThermostat
    XCTAssertTrue(favouriteThermostat == nil)
  }
}
