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
  
  /*private var sessionID: String? {
    didSet {
      if let session = sessionID {
        delegate?.authenticator(didRetrieveSessionID: session)
      }
    }
  }*/
  
  func performSignIn(withUsername username: String, andPassword password: String) {
    let HTTPBodyForRequest = [
      // READ BASEURL FROM APP SETTINGS
      
      "create": "session",
      "initial-values":
        [
          "user-name": username,
          "password": password
      ]
    ]
    
    let URLRequest = NSMutableURLRequest(URL: NSURL(string: "https://nebula.rdzug.net/api/sessions/@items")!)
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
              ApplicationSettingsManager.sharedInstance.sessionID = sessionID
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
  
}