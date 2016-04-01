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
  
  private let baseURL = ApplicationSettingsManager.sharedInstance.baseURLOfCPSCloud
  
  func performSignIn(withUsername username: String, andPassword password: String) {
    guard let urlForSignIn = URLForPerformingSignIn() else {
      self.delegate?.authenticator(didFailToAuthenticateWithError: NSLocalizedString("SignInURLConstructionFailure", comment: "Error: Failure constructing sign in URL"))
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
            errorDescription = NSLocalizedString("SignInCredentialIncorrect", comment: "Error: Email address or password incorrect")
          } else {
            errorDescription = error.localizedDescription
          }
          self.delegate?.authenticator(didFailToAuthenticateWithError: errorDescription)
        }
    }
  }
  
  private func URLForPerformingSignIn() -> NSURL? {
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
    guard let sessionID = ApplicationSettingsManager.sharedInstance.sessionID,urlForSignOut = NSURL(string: "\(baseURL)")?.URLByAppendingPathComponent("/api/sessions/\(sessionID)") else {
      return
    }
        
    Alamofire.request(.DELETE, urlForSignOut)
      .validate()
      .responseString { response in
        if(response.result.isSuccess) {
          NSLog("Logout successful")
        } else {
          NSLog("Logout unsuccessful -> Error: \(response.result.value ?? "")")
        }
    }
    
    self.updateSessionID(nil)
    self.delegate?.authenticatorDidPerformSignOut()
  }
  
  func updateSessionID(sessionID: String?) {
    ApplicationSettingsManager.sharedInstance.sessionID = sessionID
  }
}