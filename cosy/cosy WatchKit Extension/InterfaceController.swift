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
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    
    // Configure interface objects here.
  }
  
  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
    if let sessionID = ApplicationSettingsManager.sharedInstance.sessionID {
      informationLabel.setText("sessionID = \(sessionID)")
      print("sessionID = \(sessionID)")
    } else {
      informationLabel.setText("no sessionID found")
      print("no sessionID found")
    }
  }
  
  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }
  
}
