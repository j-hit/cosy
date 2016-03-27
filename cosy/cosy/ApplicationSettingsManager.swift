//
//  ApplicationSettingsManager.swift
//  cosy
//
//  Created by James Bampoe on 27/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation

final class ApplicationSettingsManager {
  static let sharedInstance = ApplicationSettingsManager()
  
  private struct keys {
    static let lastUsedEmailAddress = "emailAddress"
    static let lastUsedPassword = "password"
  }
  
  private lazy var userDefaults = NSUserDefaults.standardUserDefaults()
  
  var lastUsedEmailAddress: String {
    get {
      if let emailAddress = userDefaults.stringForKey(keys.lastUsedEmailAddress) {
          return emailAddress
      } else{
        return ""
      }
    }
    set {
      userDefaults.setObject(newValue, forKey: keys.lastUsedEmailAddress)
    }
  }
  
  var lastUsedPassword: String {
    get {
      if let password = userDefaults.stringForKey(keys.lastUsedPassword) {
        return password
      } else{
        return ""
      }
    }
    set {
      userDefaults.setObject(newValue, forKey: keys.lastUsedPassword)
    }
  }
  
  private init() {
    
  }
}