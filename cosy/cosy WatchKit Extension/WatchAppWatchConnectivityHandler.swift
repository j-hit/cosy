//
//  WatchAppWatchConnectivityHandler.swift
//  cosy
//
//  Created by James Bampoe on 28/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation
import WatchConnectivity
import WatchKit

final class WatchAppWatchConnectivityHandler: NSObject {
  var delegate: WatchAppWatchConnectivityHandlerDelegate?
  var settingsProvider: SettingsProvider?

  var thermostatManager = {
    return (WKExtension.sharedExtension().delegate as? ExtensionDelegate)?.thermostatManager
  }()
  
  override init() {
    super.init()
    setupWatchConnectivity()
  }
  
  convenience init(settingsProvider: SettingsProvider) {
    self.init()
    self.settingsProvider = settingsProvider
  }
  
  func setupWatchConnectivity() {
    if WCSession.isSupported() {
      let session = WCSession.defaultSession()
      session.delegate = self
      session.activateSession()
    }
  }
  
  func transmitErrorToiPhone(error: String, completionHander: () -> Void) {
    let session = WCSession.defaultSession()
    if session.reachable {
      let message = ["error": error]
      session.sendMessage(message, replyHandler: nil, errorHandler: { (error: NSError) in
        print("Error: \(error.localizedDescription)")
      })
    }
    completionHander()
  }
}

// MARK: - WCSessionDelegate
extension WatchAppWatchConnectivityHandler: WCSessionDelegate {
  func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
    print("Phone->Watch Receiving Context: \(applicationContext)")
    if let key = settingsProvider?.key, applicationSettings = applicationContext[key] as? [String: AnyObject] {
      settingsProvider?.importFromDictionary(applicationSettings)
      delegate?.didUpdateApplicationSettings()
    }
    
    if let thermostatLocations = applicationContext["locations"] as? [[String: AnyObject]] {
      thermostatManager?.importThermostatLocations(thermostatLocations)
    }
  }
}