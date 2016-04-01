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
  override init() {
    super.init()
    setupWatchConnectivity()
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
        do {
          let applicationSettings = [ApplicationSettingsManager.key: ApplicationSettingsManager.sharedInstance.exportAsDictionary()]
          try session.updateApplicationContext(applicationSettings)
        } catch {
          print("ERROR: \(error)")
        }
      }
    }
  }
}

extension iPhoneWatchConnectivityHandler: WCSessionDelegate {

}