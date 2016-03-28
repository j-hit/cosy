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
    static let mockModeEnabled = "mockModeEnabled"
    static let baseURL = "baseURLCPSCloud"
    static let sessionID = "sessionID"
  }
  
  private lazy var userDefaults = NSUserDefaults.standardUserDefaults()
  
  var mockModeEnabled: Bool {
    get {
      return NSUserDefaults.standardUserDefaults().boolForKey(keys.mockModeEnabled)
    }
    set {
      userDefaults.setObject(newValue, forKey: keys.mockModeEnabled)
    }
  }
  
  var lastUsedEmailAddress: String {
    get {
      if let emailAddress = userDefaults.stringForKey(keys.lastUsedEmailAddress) {
        return emailAddress
      } else {
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
      } else {
        return ""
      }
    }
    set {
      userDefaults.setObject(newValue, forKey: keys.lastUsedPassword)
    }
  }
  
  var baseURLOfCPSCloud: String {
    get {
      if let baseURL = userDefaults.stringForKey(keys.baseURL) where !baseURL.isEmpty {
        return baseURL
      } else {
        return "https://nebula.rdzug.net"
      }
    }
    set {
      userDefaults.setObject(newValue, forKey: keys.baseURL)
    }
  }
  
  var sessionID: String? {
    get {
      if let sessionID = userDefaults.stringForKey(keys.sessionID) {
        return sessionID
      } else {
        return nil
      }
    }
    set {
      if let sessionID = newValue {
        userDefaults.setObject(sessionID, forKey: keys.sessionID)
      } else {
        userDefaults.removeObjectForKey(keys.sessionID)
      }
      
      userDefaults.synchronize()
    }
  }
  
  private init() {
    
  }
}