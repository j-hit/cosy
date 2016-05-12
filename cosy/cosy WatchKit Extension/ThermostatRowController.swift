//
//  ThermostatRowController.swift
//  cosy
//
//  Created by James Bampoe on 01/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import WatchKit

class ThermostatRowController: NSObject {
  @IBOutlet var thermostatLabel: WKInterfaceLabel!
  @IBOutlet var rowGroup: WKInterfaceGroup!
  @IBOutlet var occupationModeImage: WKInterfaceImage!
  
  static let identifier = "ThermostatRow"
  private let colourOfThermostatMarkedAsFavourite = UIColor(red:0.51, green:0.70, blue:0.22, alpha:0.8)
  
  var thermostat: Thermostat? {
    didSet {
      if let thermostat = thermostat where thermostat.isMarkedAsFavourite {
        rowGroup.setBackgroundColor(colourOfThermostatMarkedAsFavourite)
      }
    }
  }
}
