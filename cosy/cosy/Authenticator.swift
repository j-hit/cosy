//
//  Authenticator.swift
//  cosy
//
//  Created by James Bampoe on 26/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation
import Alamofire

protocol AuthenticatorDelegate {
  func authenticator(didRetrieveSessionID sessionID: String)
  func authenticator(didFailToAuthenticateWithError error: String)
}

final class Authenticator {
  var delegate: AuthenticatorDelegate?
  
  private var sessionID: String? {
    didSet {
      if let session = sessionID {
        delegate?.authenticator(didRetrieveSessionID: session)
      }
    }
  }
  
  func performSignIn(withUsername username: String, andPassword password: String) {
    let HTTPBodyForRequest = [
      // READ USERNAME AND PASSWORD FROM INPUT FIELDS
      // READ BASEURL FROM APP SETTINGS
      
      "create": "session",
      "initial-values":
        [
          "user-name": username,//"james.bampoe@siemens.com",
          "password": password//"Test1234"
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
              self.sessionID = sessionID
          }
        case .Failure(let error):
          self.delegate?.authenticator(didFailToAuthenticateWithError: error.localizedDescription)
        }
    }
  }

}