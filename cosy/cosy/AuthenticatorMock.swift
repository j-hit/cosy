//
//  AuthenticatorMock.swift
//  cosy
//
//  Created by James Bampoe on 27/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation

final class AuthenicatorMock: Authenticator {
  var delegate: AuthenticatorDelegate?
  
  func performSignIn(withUsername username: String, andPassword password: String) {
    let sessionID = "mockModeSessionID"
    updateSessionID(sessionID)
    delegate?.authenticator(didRetrieveSessionID: sessionID)
  }
  
  func performSignOut() {
    updateSessionID(nil)
    delegate?.authenticatorDidPerformSignOut()
  }
  
  func updateSessionID(sessionID: String?) {
    ApplicationSettingsManager.sharedInstance.sessionID = sessionID
  }
}