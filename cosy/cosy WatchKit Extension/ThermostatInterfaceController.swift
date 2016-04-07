//
//  ThermostatInterfaceController.swift
//  cosy
//
//  Created by James Bampoe on 07/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import WatchKit
import Foundation


class ThermostatInterfaceController: WKInterfaceController {
  
  var thermostat: Thermostat? {
    didSet {
      self.setTitle(thermostat?.name)
    }
  }
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    if let thermostat = context as? Thermostat {
      self.thermostat = thermostat
    }
  }
  
  override func willActivate() {
    super.willActivate()
  }
  
  override func didDeactivate() {
    super.didDeactivate()
  }
}
