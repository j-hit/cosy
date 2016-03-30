//
//  AuthenticatorImpl.swift
//  cosy
//
//  Created by James Bampoe on 27/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation
import Alamofire

final class AuthenticatorImpl: Authenticator {
  var delegate: AuthenticatorDelegate?
  
  func performSignIn(withUsername username: String, andPassword password: String) {
    guard let urlForSignIn = URLForPerformingSignIn() else {
      self.delegate?.authenticator(didFailToAuthenticateWithError: "URL for sign in could not be constructed")
      return
    }
    
    let URLRequest = NSMutableURLRequest(URL: urlForSignIn)
    URLRequest.HTTPMethod = "POST"
    URLRequest.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
    URLRequest.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(bodyForSignInRequestWith(username: username, andPassword: password), options: [])
    
    Alamofire.request(URLRequest)
      .validate()
      .responseJSON { response in
        switch response.result {
        case .Success:
          if let JSONResponse = response.result.value,
            sessionID = JSONResponse["CCL_SESSION_ID"] as? String{
              self.updateSessionID(sessionID)
              self.delegate?.authenticator(didRetrieveSessionID: sessionID)
          }
        case .Failure(let error):
          var errorDescription: String
          if response.response?.statusCode == 403 {
            errorDescription = "Username or password is wrong"
          } else {
            errorDescription = error.localizedDescription
          }
          self.delegate?.authenticator(didFailToAuthenticateWithError: errorDescription)
        }
    }
  }
  
  private func URLForPerformingSignIn() -> NSURL? {
    let baseURL = ApplicationSettingsManager.sharedInstance.baseURLOfCPSCloud
    guard let urlForSignIn = NSURL(string: "\(baseURL)")?.URLByAppendingPathComponent("/api/sessions/@items") else {
      return nil
    }
    return urlForSignIn
  }
  
  private func bodyForSignInRequestWith(username username: String, andPassword password: String) -> [String: NSObject] {
    return [
      "create": "session",
      "initial-values":
        [
          "user-name": username,
          "password": password
      ]
    ]
  }
  
  func performSignOut() {
    // TODO: Perform sign out on CCL
    updateSessionID(nil)
    delegate?.authenticatorDidPerformSignOut()
  }
  
  func updateSessionID(sessionID: String?) {
    ApplicationSettingsManager.sharedInstance.sessionID = sessionID
  }
}