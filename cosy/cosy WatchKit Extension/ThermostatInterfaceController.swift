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
  @IBOutlet var errorIndicationImage: WKInterfaceImage!
  @IBOutlet var topViewSeparator: WKInterfaceSeparator!
  
  private let watchDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
  
  private var thermostatManager: ThermostatManager?
  private var thermostat: Thermostat? {
    didSet {
      self.setTitle(thermostat?.name)
    }
  }
  private var lastThermostatState = ThermostatState.Idle
  
  private var timer: NSTimer?
  
  private var lastDataFetchWasFaulty = false {
    didSet {
      if lastDataFetchWasFaulty == true {
        showErrorIndication(true)
      } else if lastDataFetchWasFaulty == false && oldValue == true {
        showErrorIndication(false)
      }
    }
  }
  
  // MARK: Lifecycle methods
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    self.thermostat = context as? Thermostat
    self.thermostatManager = watchDelegate.thermostatManager
    visualiseForState(lastThermostatState)
  }
  
  override func willActivate() {
    super.willActivate()
    reloadDataShownOnView()
  }
  
  override func didDeactivate() {
    super.didDeactivate()
    if let thermostat = thermostat {
      if thermostat.isMarkedAsFavourite {
        ExtensionDelegate.settingsProvider.favouriteThermostat = thermostat
      }
    }
  }
  
  // MARK: Reloading data on view
  
  private func reloadDataShownOnView() {
    if let currentTemperature = thermostat?.currentTemperature {
      currentTemperatureLabel.setText(String(format: NSLocalizedString("CurrentTemperatureDescription", comment: "describes the current temperature from a thermostat"), currentTemperature))
    } else {
      currentTemperatureLabel.setText("--")
    }
    
    if let temperatureSetPoint = thermostat?.temperatureSetPoint {
      temperatureSetPointLabel.setText(String(format: NSLocalizedString("TemperatureSetpointDescription", comment: "describes the temperature set-point of a thermostat"), temperatureSetPoint))
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
      informationLabel.setText(NSLocalizedString("LocationNotOccupiedDescription", comment: "describes that a location is not occupied"))
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
      informationLabel.setText(NSLocalizedString("ThermostatInAutoModeDescription", comment: "describes that a thermostat is in auto mode"))
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
    addMenuItemWithImageNamed("menu-unoccupied", title: NSLocalizedString("AwayMenuItemTitle", comment: "Title shown below the away icon in the context menu"), action: #selector(ThermostatInterfaceController.onAwaySelected))
  }
  
  private func addHomeMenuItem() {
    addMenuItemWithImageNamed("menu-occupied", title: NSLocalizedString("HomeMenuItemTitle", comment: "Title shown below the home icon in the context menu"), action: #selector(ThermostatInterfaceController.onHomeSelected))
  }
  
  private func addAutoMenuItem() {
    addMenuItemWithImageNamed("menu-auto", title: NSLocalizedString("AutoMenuItemTitle", comment: "Title shown below the auto icon in the context menu"), action: #selector(ThermostatInterfaceController.onAutoSelected))
  }
  
  private func addManualMenuItem() {
    addMenuItemWithImageNamed("menu-manual", title: NSLocalizedString("ManualMenuItemTitle", comment: "Title shown below the manual icon in the context menu"), action: #selector(ThermostatInterfaceController.onManualSelected))
  }
  
  @IBAction func onFavouriteSelected() {
    thermostatManager?.favouriteThermostat = thermostat
    ExtensionDelegate.settingsProvider.favouriteThermostat = thermostat
    
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
    
    timer?.invalidate()
    timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(saveTemperatureSetPoint), userInfo: nil, repeats: false)
  }
  
  func saveTemperatureSetPoint() {
    if let thermostat = thermostat {
      thermostatManager?.saveTemperatureSetPointOfThermostat(thermostat)
    }
  }
  
  // MARK: Error handling
  
  func showErrorIndication(showErrorOnView: Bool) {
    if showErrorOnView {
      errorIndicationImage.setHidden(false)
    } else {
      errorIndicationImage.setHidden(true)
    }
  }
}

// MARK: - ThermostatDelegate
extension ThermostatInterfaceController: ThermostatDelegate {
  func didUpdateName(toNewValue newValue: String) {
    // TODO: Update name on view
    lastDataFetchWasFaulty = false
  }
  
  func didUpdateCurrentTemperature(toNewValue newValue: Int) {
    // TODO: Update current temperature on view
    lastDataFetchWasFaulty = false
  }
  
  func didUpdateTemperatureSetpoint(toNewValue newValue: Int) {
    // TODO: Update temperature set point on view
    lastDataFetchWasFaulty = false
  }
  
  func didFailToRetrieveData(withError error: String) {
    lastDataFetchWasFaulty = true
  }
}
