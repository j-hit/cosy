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
    let sessionID = "defaultSessionID77"
    delegate?.authenticator(didRetrieveSessionID: sessionID)
    ApplicationSettingsManager.sharedInstance.sessionID = sessionID
  }
}