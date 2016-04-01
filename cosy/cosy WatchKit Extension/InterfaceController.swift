//
//  InterfaceController.swift
//  cosy WatchKit Extension
//
//  Created by James Bampoe on 05/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
  @IBOutlet var informationLabel: WKInterfaceLabel!
  
  let watchDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    watchDelegate.watchConnectivityHandler.delegate = self
    
    // Configure interface objects here.
  }
  
  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
    reloadData()
  }
  
  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }
  
  private func reloadData() {
    if let sessionID = ApplicationSettingsManager.sharedInstance.sessionID {
      informationLabel.setText("sessionID = \(sessionID)")
    } else {
      informationLabel.setText("no sessionID found")
    }
  }
}

extension InterfaceController: WatchAppWatchConnectivityHandlerDelegate {
  func didUpdateApplicationSettings() {
    reloadData()
  }
}
