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
            print("ERROR: \(error)")
          }
        }
      }
    }
  }
}

extension iPhoneWatchConnectivityHandler: WCSessionDelegate {

}