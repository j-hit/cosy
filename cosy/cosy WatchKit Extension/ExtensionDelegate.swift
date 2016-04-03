//
//  ExtensionDelegate.swift
//  cosy WatchKit Extension
//
//  Created by James Bampoe on 05/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
  
  let watchConnectivityHandler = WatchAppWatchConnectivityHandler()
  lazy var thermostatManager: ThermostatManager = {
    if ApplicationSettingsManager.sharedInstance.mockModeEnabled {
      return ThermostatManagerMock()
    } else {
      return ThermostatManagerImpl(dataAccessor: CPSCloudThermostatDataAccessor())
    }
  }()
  
  func applicationDidFinishLaunching() {
    // Perform any final initialization of your application.
  }
  
  func applicationDidBecomeActive() {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillResignActive() {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
  }
}
