//
//  AuthenticatorMock.swift
//  cosy
//
//  Created by James Bampoe on 27/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation

final class AuthenticatorMock: Authenticator {
  weak var delegate: AuthenticatorDelegate?
  
  let mockSessionID = "mockModeSessionID"
  let nonExistingUsername = "does.not.exist@cosy.net"
  
  func performSignIn(withUsername username: String, andPassword password: String) {
    if(username == nonExistingUsername) {
      delegate?.authenticator(didFailToAuthenticateWithError: NSLocalizedString("SignInCredentialIncorrect", comment: "Error: Email address or password incorrect"))
    } else {
      updateSessionID(mockSessionID)
      delegate?.authenticator(didRetrieveSessionID: mockSessionID)
    }
  }
  
  func performSignOut() {
    updateSessionID(nil)
    delegate?.authenticatorDidPerformSignOut()
  }
  
  func updateSessionID(sessionID: String?) {
    ApplicationSettingsManager.sharedInstance.sessionID = sessionID
  }
}