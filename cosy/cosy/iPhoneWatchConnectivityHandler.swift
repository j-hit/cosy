//
//  iPhoneWatchConnectivityHandler.swift
//  cosy
//
//  Created by James Bampoe on 28/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation
import WatchConnectivity

final class iPhoneWatchConnectivityHandler: NSObject {
  var settingsProvider: SettingsProvider?
  weak var delegate: iPhoneWatchConnectivityHandlerDelegate?
  
  override init() {
    super.init()
    setupWatchConnectivity()
  }
  
  convenience init(settingsProvider: SettingsProvider) {
    self.init()
    self.settingsProvider = settingsProvider
  }
  
  private func setupWatchConnectivity() {
    if WCSession.isSupported() {
      let session = WCSession.defaultSession()
      session.delegate = self
      session.activateSession()
    }
  }
  
  func transferApplicationSettingsToWatch() {
    if WCSession.isSupported() {
      let session = WCSession.defaultSession()
      if session.watchAppInstalled {
        if let settingsProvider = settingsProvider {
          do {
            let applicationSettings = [settingsProvider.key: settingsProvider.exportAsDictionary()]
            try session.updateApplicationContext(applicationSettings)
          } catch {
            NSLog("ERROR transfering application settings to watch: \(error)")
          }
        }
      }
    }
  }
  
  func transferAppContextToWatch(withDataFromThermsotatManager thermostatManager: ThermostatManager) {
    if WCSession.isSupported() {
      let session = WCSession.defaultSession()
      if session.watchAppInstalled {
        do {
          var transferObject: [String: AnyObject] = ["thermostats": thermostatManager.exportThermostatsAsNSData()]
          if let settingsProvider = settingsProvider {
            transferObject[settingsProvider.key] = settingsProvider.exportAsDictionary()
          }
          try session.updateApplicationContext(transferObject)
        } catch {
          NSLog("ERROR transfering thermostat locations to watch: \(error)")
        }
      }
    }
  }
}

// MARK: - WCSessionDelegate
extension iPhoneWatchConnectivityHandler: WCSessionDelegate {
  func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
    if let error = message["error"] as? String {
      delegate?.didReceiveErrorMessageFromWatch(error)
    }
  }
}