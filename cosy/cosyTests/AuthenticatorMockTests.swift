//
//  AuthenticatorMockTests.swift
//  cosy
//
//  Created by James Bampoe on 31/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import XCTest
@testable import cosy

class AuthenticatorMockTests: XCTestCase {
  
  let applicationSettingsManager = ApplicationSettingsManager.sharedInstance
  var authenticator: AuthenticatorMock?
  
  override func setUp() {
    super.setUp()
    authenticator = AuthenticatorMock()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testSignInShouldSetSessionID() {
    authenticator!.performSignIn(withUsername: "user", andPassword: "password")
    XCTAssertEqual(applicationSettingsManager.sessionID, authenticator!.mockSessionID)
  }
  
  func testSignOutShouldClearSessionID() {
    authenticator!.performSignIn(withUsername: "user", andPassword: "password")
    authenticator!.performSignOut()
    XCTAssertEqual(applicationSettingsManager.sessionID, nil)
  }
}
