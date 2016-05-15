//
//  Authenticator.swift
//  cosy
//
//  Created by James Bampoe on 26/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation
import Alamofire

protocol AuthenticatorDelegate: class {
  func authenticator(didRetrieveSessionID sessionID: String)
  func authenticator(didFailToAuthenticateWithError error: String)
  func authenticatorDidPerformSignOut()
}

protocol Authenticator: class {
  weak var delegate: AuthenticatorDelegate? { get set }
  func performSignIn(withUsername username: String, andPassword password: String)
  func performSignOut()
  func updateSessionID(sessionID: String?)
}