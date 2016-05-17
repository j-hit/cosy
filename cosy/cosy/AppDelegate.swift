//
//  AppDelegate.swift
//  cosy
//
//  Created by James Bampoe on 05/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  static let settingsProvider = ApplicationSettingsManager.sharedInstance

  let watchConnectivityHandler = iPhoneWatchConnectivityHandler(settingsProvider: settingsProvider)
  
  // TODO: Refactor with appConfiguratorFactory and enum (Dependency Injection)
  lazy var authenticator: Authenticator = {
    if settingsProvider.mockModeEnabled {
        return AuthenticatorMock()
    } else {
      return AuthenticatorImpl()
    }
  }()
  
  lazy var thermostatManager: ThermostatManager = {
    if settingsProvider.mockModeEnabled {
      return ThermostatManagerMock(settingsProvider: settingsProvider)
    } else {
      return ThermostatManagerImpl(dataAccessor: CPSCloudThermostatDataAccessor(settingsProvider: ApplicationSettingsManager.sharedInstance))
    }
  }()

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    return true
  }
}

