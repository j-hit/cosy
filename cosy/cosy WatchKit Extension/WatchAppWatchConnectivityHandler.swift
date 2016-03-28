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
  
  override init() {
    super.init()
    setupWatchConnectivity()
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
    if let applicationSettings = applicationContext["applicationSettings"] as? [String: AnyObject] {
      ApplicationSettingsManager.sharedInstance.importFromDictionary(applicationSettings)
      delegate?.didUpdateApplicationSettings()
    }
  }
}