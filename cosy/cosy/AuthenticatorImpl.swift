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
    
    let HTTPBodyForRequest = [
      "create": "session",
      "initial-values":
        [
          "user-name": username,
          "password": password
      ]
    ]
    
    let URLRequest = NSMutableURLRequest(URL: urlForSignIn)
    URLRequest.HTTPMethod = "POST"
    URLRequest.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
    URLRequest.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(HTTPBodyForRequest, options: [])
    
    Alamofire.request(URLRequest)
      .validate()
      .responseJSON { response in
        switch response.result {
        case .Success:
          if let JSONResponse = response.result.value,
            sessionID = JSONResponse["CCL_SESSION_ID"] as? String{
              self.delegate?.authenticator(didRetrieveSessionID: sessionID)
              self.updateSessionID(sessionID)
          }
        case .Failure(let error):
          // TODO: Remove print statement
          var statusCode = 0
          if let httpError = response.result.error {
            statusCode = httpError.code
          } else if let code = response.response?.statusCode {
            statusCode = code
          }
          print("Status code: \(statusCode)")
          
          self.delegate?.authenticator(didFailToAuthenticateWithError: error.localizedDescription)
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
  
  func performSignOut() {
    // TODO: Add code
  }
  
  func updateSessionID(sessionID: String?) {
    ApplicationSettingsManager.sharedInstance.sessionID = sessionID
  }
}