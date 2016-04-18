//
//  ExtensionDelegate.swift
//  cosy WatchKit Extension
//
//  Created by James Bampoe on 05/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
  
  private (set) var appIsActive = false
  
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
    // Perform any final initialization of your application.
  }
  
  func applicationDidBecomeActive() {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    appIsActive = true
  }
  
  func applicationWillResignActive() {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
    appIsActive = false
  }
}
