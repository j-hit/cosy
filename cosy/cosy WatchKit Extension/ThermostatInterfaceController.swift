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
  @IBOutlet var informationLabel: WKInterfaceLabel!
  
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
  
  private func reloadDataShownOnView() {
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
    
    if thermostat?.correspondingLocation?.isOccupied == true {
      if thermostat?.isInAutoMode == true {
        onAutoSelected()
      } else {
        onManualSelected()
      }
    }
    else {
      onAwaySelected()
    }
    
    visualiseStateOfThermostat()
  }
  
  private func visualiseStateOfThermostat() {
    if let state = thermostat?.state {
      if state != lastThermostatState {
        visualiseForState(state)
        lastThermostatState = state
      }
    }
  }
  
  private func visualiseForState(state: ThermostatState) {
    let stateVisualiser = state.visualiser()
    temperatureSetPointSlider.setColor(stateVisualiser.color)
    heatCoolLabel.setTextColor(stateVisualiser.color)
    temperatureSetPointLabel.setTextColor(stateVisualiser.color)
    heatCoolLabel.setText(stateVisualiser.description)
  }
  
  // MARK: Menu Items and Actions
  
  func onAwaySelected() {
    if let thermostat = thermostat {
      thermostat.correspondingLocation?.isOccupied = false
      temperatureSetPointSlider.setHidden(true)
      informationLabel.setText("away")
      informationLabel.setHidden(false)
      
      clearAllMenuItems()
      addHomeMenuItem()
    }
  }
  
  func onHomeSelected() {
    if let thermostat = thermostat {
      thermostat.correspondingLocation?.isOccupied = true
      if thermostat.isInAutoMode == true {
        onAutoSelected()
      } else {
        onManualSelected()
      }
    }
  }
  
  func onAutoSelected() {
    if let thermostat = thermostat {
      thermostat.isInAutoMode = true
      temperatureSetPointSlider.setHidden(true)
      informationLabel.setText("auto")
      informationLabel.setHidden(false)
      
      clearAllMenuItems()
      addManualMenuItem()
      addAwayMenuItem()
    }
  }
  
  func onManualSelected() {
    if let thermostat = thermostat {
      thermostat.isInAutoMode = false
      temperatureSetPointSlider.setHidden(false)
      informationLabel.setHidden(true)
      
      clearAllMenuItems()
      addAutoMenuItem()
      addAwayMenuItem()
    }
  }
  
  private func addAwayMenuItem() {
    addMenuItemWithImageNamed("menu-unoccupied", title: "Away", action: #selector(ThermostatInterfaceController.onAwaySelected))
  }
  
  private func addHomeMenuItem() {
    addMenuItemWithImageNamed("menu-occupied", title: "Home", action: #selector(ThermostatInterfaceController.onHomeSelected))
  }
  
  private func addAutoMenuItem() {
    addMenuItemWithImageNamed("menu-auto", title: "Auto", action: #selector(ThermostatInterfaceController.onAutoSelected))
  }
  
  private func addManualMenuItem() {
    addMenuItemWithImageNamed("menu-manual", title: "Manual", action: #selector(ThermostatInterfaceController.onManualSelected))
  }
  
  @IBAction func onFavouriteSelected() {
    // Set thermostat as favourite
    WKInterfaceDevice.currentDevice().playHaptic(.Success)
  }
  
  // MARK: Interface builder actions
  
  @IBAction func onTemperatureSetPointChanged(value: Float) {
    thermostat?.temperatureSetPoint = Int(value)
    reloadDataShownOnView()
    if value == Thermostat.maximumTemperatureValue {
      WKInterfaceDevice.currentDevice().playHaptic(.DirectionUp)
    } else if value == Thermostat.minimumTemperatureValue {
      WKInterfaceDevice.currentDevice().playHaptic(.DirectionDown)
    }
  }
}
