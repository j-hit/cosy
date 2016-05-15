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
  @IBOutlet var innerRowGroup: WKInterfaceGroup!
  @IBOutlet var temperatureSetpointLabel: WKInterfaceLabel!
  
  static let identifier = "ThermostatRow"
  private let colourOfThermostatMarkedAsFavourite = UIColor(red:0.51, green:0.70, blue:0.22, alpha:0.8)
  
  var thermostat: Thermostat? {
    didSet {
      if let thermostat = thermostat {
        thermostatLabel.setText(thermostat.name)
        occupationModeImage.setImageNamed(thermostat.occupationModeimageName)
        temperatureSetpointLabel.setText("\(thermostat.temperatureSetPoint ?? 0)°")
        innerRowGroup.setBackgroundImageNamed(thermostat.rowBackgroundImageName)
        temperatureSetpointLabel.setTextColor(thermostat.state.visualiser().textColor)
        
        if thermostat.isMarkedAsFavourite {
          thermostatLabel.setTextColor(colourOfThermostatMarkedAsFavourite)
        }
      }
      if WKAccessibilityIsVoiceOverRunning() {
        makeAccessibile()
      }
    }
  }
  
  func makeAccessibile() {
    if let thermostat = thermostat, temperatureSetpoint = thermostat.temperatureSetPoint {
      rowGroup.setIsAccessibilityElement(true)
      
      let occupiedStateLabel = thermostat.isOccupied ? NSLocalizedString("ThermostatStateOccupied", comment: "Thermostat state: Occupied") : NSLocalizedString("ThermostatStateNotOccupied", comment: "Thermostat state: Not occupied")
      
      rowGroup.setAccessibilityLabel(String(format: NSLocalizedString("ThermostatRowLabel", comment: "Accessibility Label: Thermostat in list"), thermostat.name, temperatureSetpoint, occupiedStateLabel))
      
      rowGroup.setAccessibilityHint(NSLocalizedString("ThermostatRowHint", comment: "Accessibility Hint: Thermostat in list"))
    }
  }
}
