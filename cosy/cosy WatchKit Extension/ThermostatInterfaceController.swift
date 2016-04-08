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
  
  var lastThermostatState = ThermostatState.Idle
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    if let thermostat = context as? Thermostat {
      self.thermostat = thermostat
    }
    visualiseForState(lastThermostatState)
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
      if state != lastThermostatState {
        visualiseForState(state)
        lastThermostatState = state
      }
    }
  }
  
  func visualiseForState(state: ThermostatState) {
    let stateVisualiser = state.visualiser()
    temperatureSetPointSlider.setColor(stateVisualiser.color)
    heatCoolLabel.setTextColor(stateVisualiser.color)
    temperatureSetPointLabel.setTextColor(stateVisualiser.color)
    heatCoolLabel.setText(stateVisualiser.description)
  }
  
  @IBAction func onTemperatureSetPointChanged(value: Float) {
    thermostat?.temperatureSetPoint = Int(value)
    reloadDataShownOnView()
  }
}
