//
//  ExtensionDelegate.swift
//  cosy WatchKit Extension
//
//  Created by James Bampoe on 05/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
  
  var appIsActive = false
  
  static let settingsProvider = ApplicationSettingsManager.sharedInstance
  
  lazy var watchConnectivityHandler = {
    return WatchAppWatchConnectivityHandler(settingsProvider: settingsProvider)
  }()
  
  lazy var thermostatManager: ThermostatManager = {
    if settingsProvider.mockModeEnabled {
      return ThermostatManagerMock(settingsProvider: ApplicationSettingsManager.sharedInstance)
    } else {
      return ThermostatManagerImpl(dataAccessor: CPSCloudThermostatDataAccessor(settingsProvider: ApplicationSettingsManager.sharedInstance))
    }
  }()
  
  func applicationDidFinishLaunching() {
  }
  
  func applicationDidBecomeActive() {
    appIsActive = true
  }
  
  func applicationWillResignActive() {
    appIsActive = false
  }
}
