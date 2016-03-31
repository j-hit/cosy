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
    XCTAssertEqual(sessionID, nil)
  }
  
  func testPerformanceFetchingSessionID() {
    self.measureBlock {
      _ = self.applicationSettingsManager.sessionID
    }
  }
  
  func testPerformanceFetchingBaseURL() {
    self.measureBlock {
      _ = self.applicationSettingsManager.baseURLOfCPSCloud
    }
  }
}
