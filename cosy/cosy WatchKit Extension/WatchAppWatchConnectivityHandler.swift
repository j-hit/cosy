//
//  WatchAppWatchConnectivityHandler.swift
//  cosy
//
//  Created by James Bampoe on 28/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation
import WatchConnectivity

final class WatchAppWatchConnectivityHandler: NSObject {
  var delegate: WatchAppWatchConnectivityHandlerDelegate?
  var settingsProvider: SettingsProvider?
  
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
}

extension WatchAppWatchConnectivityHandler: WCSessionDelegate {
  func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
    print("Phone->Watch Receiving Context: \(applicationContext)")
    if let key = settingsProvider?.key, applicationSettings = applicationContext[key] as? [String: AnyObject] {
      settingsProvider?.importFromDictionary(applicationSettings)
      delegate?.didUpdateApplicationSettings()
    }
  }
}