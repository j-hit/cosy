//
//  AuthenticatorMock.swift
//  cosy
//
//  Created by James Bampoe on 27/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation

final class AuthenticatorMock: Authenticator {
  var delegate: AuthenticatorDelegate?
  
  let mockSessionID = "mockModeSessionID"
  
  func performSignIn(withUsername username: String, andPassword password: String) {
    updateSessionID(mockSessionID)
    delegate?.authenticator(didRetrieveSessionID: mockSessionID)
  }
  
  func performSignOut() {
    updateSessionID(nil)
    delegate?.authenticatorDidPerformSignOut()
  }
  
  func updateSessionID(sessionID: String?) {
    ApplicationSettingsManager.sharedInstance.sessionID = sessionID
  }
}