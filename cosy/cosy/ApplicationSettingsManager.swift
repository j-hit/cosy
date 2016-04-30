//
//  ApplicationSettingsManager.swift
//  cosy
//
//  Created by James Bampoe on 27/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation
import Latch

final class ApplicationSettingsManager: SettingsProvider {
  static let sharedInstance = ApplicationSettingsManager()
  var key: String {
    return "applicationSettings"
  }
  
  private struct keys {
    static let lastUsedEmailAddress = "emailAddress"
    static let lastUsedPassword = "password"
    static let mockModeEnabled = "mockModeEnabled"
    static let baseURL = "baseURLCPSCloud"
    static let sessionID = "sessionID"
  }
  
  private lazy var userDefaults = NSUserDefaults.standardUserDefaults()
  private let latch: Latch
  
  private init() {
    latch = Latch(service: "com.pentapie.BampoeJ.cosy")
  }
  
  var favouriteThermostat: Thermostat? {
    get {
      if let decodedData = userDefaults.objectForKey("favourite") as? NSData {
        return NSKeyedUnarchiver.unarchiveObjectWithData(decodedData) as? Thermostat
      } else {
        return nil
      }
    }
    set {
      if let thermostat = newValue {
        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(thermostat)
        userDefaults.setObject(encodedData, forKey: "favourite")
      } else {
        userDefaults.removeObjectForKey("favourite")
      }
    }
  }
  
  var mockModeEnabled: Bool {
    get {
      return NSUserDefaults.standardUserDefaults().boolForKey(keys.mockModeEnabled)
    }
    set {
      if newValue != mockModeEnabled {
        latch.removeObjectForKey(keys.sessionID)
      }
      userDefaults.setObject(newValue, forKey: keys.mockModeEnabled)
    }
  }
  
  var lastUsedEmailAddress: String {
    get {
      if let emailAddressData = latch.dataForKey(keys.lastUsedEmailAddress) {
        return NSString(data: emailAddressData, encoding: NSUTF8StringEncoding) as? String ?? ""
      } else {
        return ""
      }
    }
    set {
      latch.setObject(newValue, forKey: keys.lastUsedEmailAddress)
    }
  }
  
  var lastUsedPassword: String {
    get {
      if let passwordData = latch.dataForKey(keys.lastUsedPassword) {
        return NSString(data: passwordData, encoding: NSUTF8StringEncoding) as? String ?? ""
      } else {
        return ""
      }
    }
    set {
      latch.setObject(newValue, forKey: keys.lastUsedPassword)
    }
  }
  
  var baseURLOfCPSCloud: String {
    get {
      if let baseURL = userDefaults.stringForKey(keys.baseURL) where !baseURL.isEmpty {
        return baseURL
      } else {
        return "https://nebula.rdzug.net/ccl"
      }
    }
    set {
      userDefaults.setObject(newValue, forKey: keys.baseURL)
    }
  }
  
  var sessionID: String? {
    get {
      if let sessionIDData = latch.dataForKey(keys.sessionID) {
        return NSString(data: sessionIDData, encoding: NSUTF8StringEncoding) as? String
        
      } else {
        return nil
      }
    }
    set {
      if let sessionID = newValue {
        latch.setObject(sessionID, forKey: keys.sessionID)
      } else {
        latch.removeObjectForKey(keys.sessionID)
      }
    }
  }
  
  func exportAsDictionary() -> [String : AnyObject] {
    let applicationSettings: [String : AnyObject] = [
      keys.mockModeEnabled : mockModeEnabled,
      keys.sessionID : sessionID ?? "",
      keys.baseURL : baseURLOfCPSCloud
    ]
    
    return applicationSettings
  }
  
  func importFromDictionary(dictionary: [String : AnyObject]) {
    if let mockModeEnabled = dictionary[keys.mockModeEnabled] as? Bool {
      self.mockModeEnabled = mockModeEnabled
    }
    if let sessionID = dictionary[keys.sessionID] as? String {
      if(sessionID.isEmpty) {
        self.sessionID = nil
      } else {
        self.sessionID = sessionID
      }
    }
    if let baseURLOfCPSCloud = dictionary[keys.baseURL] as? String {
      self.baseURLOfCPSCloud = baseURLOfCPSCloud
    }
  }
}