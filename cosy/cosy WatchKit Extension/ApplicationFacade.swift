//
//  ApplicationFacade.swift
//  cosy
//
//  Created by James Bampoe on 19/05/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation
import WatchKit

final class ApplicationFacade {
  static let instance = ApplicationFacade()
  
  private init() {
  }
  
  private let watchDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
  
  var watchConnectivityHandler: WatchAppWatchConnectivityHandler {
    return watchDelegate.watchConnectivityHandler
  }
  
  var thermostatManager: ThermostatManager {
    return watchDelegate.thermostatManager
  }
  
  var settingsProvider: SettingsProvider {
    get {
      return ExtensionDelegate.settingsProvider
    }
    set {
      
    }
  }
  
  var appIsActive: Bool {
    get {
      return watchDelegate.appIsActive
    }
    set {
      watchDelegate.appIsActive = newValue
    }
  }
}