//
//  GlanceController.swift
//  cosy WatchKit Extension
//
//  Created by James Bampoe on 05/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import WatchKit
import Foundation

class GlanceController: WKInterfaceController {
  
  @IBOutlet var thermostatNameLabel: WKInterfaceLabel!
  @IBOutlet var temperatureSetpointLabel: WKInterfaceLabel!
  @IBOutlet var currentTemperatureLabel: WKInterfaceLabel!
  @IBOutlet var thermostatStateImage: WKInterfaceImage!
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    
    // Configure interface objects here.
  }
  
  override func willActivate() {
    super.willActivate()
    if let thermostat = ExtensionDelegate.settingsProvider.favouriteThermostat {
      thermostatNameLabel.setText(thermostat.name)
      temperatureSetpointLabel.setText("\(thermostat.temperatureSetPoint ?? 0)")
      currentTemperatureLabel.setText(String(format: NSLocalizedString("CurrentTemperatureDescription", comment: "describes the current temperature from a thermostat"), thermostat.currentTemperature ?? 0))
      
      switch thermostat.state {
      case .Heating:
        thermostatStateImage.setImageNamed("heating-glance")
      case .Cooling:
        thermostatStateImage.setImageNamed("cooling-glance")
      default:
        thermostatStateImage.setImage(nil)
      }
      
      temperatureSetpointLabel.setTextColor(thermostat.state.visualiser().color)
    }
  }
  
  override func didDeactivate() {
    super.didDeactivate()
  }
}
