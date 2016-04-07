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
  
  @IBOutlet var heatCoolLabel: WKInterfaceLabel!
  @IBOutlet var currentTemperatureLabel: WKInterfaceLabel!
  @IBOutlet var temperatureSetPointLabel: WKInterfaceLabel!
  @IBOutlet var temperatureSetPointSlider: WKInterfaceSlider!
  
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
    reloadDataShownOnView()
  }
  
  override func didDeactivate() {
    super.didDeactivate()
  }
  
  func reloadDataShownOnView() {
    if let currentTemperature = thermostat?.currentTemperature {
      currentTemperatureLabel.setText("now \(currentTemperature)°") // TODO: use localised string
    } else {
      currentTemperatureLabel.setText("--")
    }
    
    if let temperatureSetPoint = thermostat?.temperatureSetPoint {
      temperatureSetPointLabel.setText("\(temperatureSetPoint)°")
      temperatureSetPointSlider.setValue(Float(temperatureSetPoint))
    } else {
      temperatureSetPointLabel.setText("--")
      temperatureSetPointSlider.setValue(0)
    }
    
    visualiseStateOfThermostat()
  }
  
  func visualiseStateOfThermostat() {
    if let state = thermostat?.state {
      var stateDescription: String
      switch state {
      case .Heating:
        stateDescription = "heat"
        temperatureSetPointSlider.setColor(UIColor.orangeColor())
        heatCoolLabel.setTextColor(UIColor.orangeColor())
        temperatureSetPointLabel.setTextColor(UIColor.orangeColor())
      case .Cooling:
        stateDescription = "cool"
        temperatureSetPointSlider.setColor(UIColor.blueColor())
        heatCoolLabel.setTextColor(UIColor.blueColor())
        temperatureSetPointLabel.setTextColor(UIColor.blueColor())
      case .Idle:
        stateDescription = "idle"
        temperatureSetPointSlider.setColor(UIColor.grayColor())
        heatCoolLabel.setTextColor(UIColor.grayColor())
        temperatureSetPointLabel.setTextColor(UIColor.grayColor())
      }
      heatCoolLabel.setText(stateDescription)
    } else {
      heatCoolLabel.setText("--")
    }
  }
  
  @IBAction func onTemperatureSetPointChanged(value: Float) {
    thermostat?.temperatureSetPoint = Int(value)
    reloadDataShownOnView()
  }
}
