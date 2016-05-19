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
  
  @IBOutlet var currentTemperatureLabel: WKInterfaceLabel!
  @IBOutlet var temperatureSetPointLabel: WKInterfaceLabel!
  @IBOutlet var temperatureSetPointSlider: WKInterfaceSlider!
  @IBOutlet var informationLabel: WKInterfaceLabel!
  @IBOutlet var errorIndiciationButton: WKInterfaceButton!
  
  private let watchDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
  
  private var thermostatManager: ThermostatManager?
  private var thermostat: Thermostat? {
    didSet {
      self.setTitle(thermostat?.name)
    }
  }
  private var lastThermostatState = ThermostatState.Idle
  private var temperatureSetPointIsBeingChanged = false
  private var timer: NSTimer?
  
  private var lastDataFetchOrChangeWasFaulty = false {
    didSet {
      if lastDataFetchOrChangeWasFaulty == true {
        showErrorIndication(true)
      } else if lastDataFetchOrChangeWasFaulty == false && oldValue == true {
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
    if let thermostat = thermostat {
      thermostat.delegate = self
      thermostatManager?.updateData(ofThermostat: thermostat)
    }
    watchDelegate.watchConnectivityHandler.delegate = self
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
    showCurrentTemperature()
    showTemperatureSetPoint()
    showThermostatState()
  }
  
  private func showCurrentTemperature() {
    if let currentTemperature = thermostat?.currentTemperature where currentTemperature > 0 {
      currentTemperatureLabel.setText(String(format: NSLocalizedString("CurrentTemperatureDescription", comment: "describes the current temperature from a thermostat"), currentTemperature))
    } else {
      currentTemperatureLabel.setText("--")
    }
  }
  
  private func showTemperatureSetPoint() {
    if let temperatureSetPoint = thermostat?.temperatureSetPoint where temperatureSetPoint > 0 {
      temperatureSetPointLabel.setText(String(format: NSLocalizedString("TemperatureSetpointDescription", comment: "describes the temperature set-point of a thermostat"), temperatureSetPoint))
      temperatureSetPointSlider.setValue(Float(temperatureSetPoint))
      
      if WKAccessibilityIsVoiceOverRunning() {
        temperatureSetPointLabel.setAccessibilityLabel(String(format: NSLocalizedString("ThermostatSetPointAccessibilityLabel", comment: "Accessibility Label: Thermostat temperature set point"), temperatureSetPoint))
        temperatureSetPointSlider.setAccessibilityLabel("Temperature set point slider, use to change set point")
        temperatureSetPointSlider.setAccessibilityValue("\(temperatureSetPoint)°")
      }
    } else {
      temperatureSetPointLabel.setText("--")
      temperatureSetPointSlider.setValue(0)
    }
  }
  
  private func showThermostatState() {
    if thermostat?.isOccupied == true {
      if thermostat?.isInAutoMode == true {
        configureForModeAuto()
      } else {
        configureForModeManual()
      }
    }
    else {
      configureForModeAway()
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
    temperatureSetPointLabel.setTextColor(stateVisualiser.color)
  }
  
  func configureForModeAway() {
    temperatureSetPointSlider.setHidden(true)
    informationLabel.setText(NSLocalizedString("LocationNotOccupiedDescription", comment: "describes that a location is not occupied"))
    informationLabel.setHidden(false)
    
    if WKAccessibilityIsVoiceOverRunning() {
      informationLabel.setAccessibilityLabel("Currently set to away")
    }
    
    clearAllMenuItems()
    addHomeMenuItem()
  }
  
  func configureForModeHome() {
    if let thermostat = thermostat {
      if thermostat.isInAutoMode == true {
        configureForModeAuto()
      } else {
        configureForModeManual()
      }
    }
  }
  
  func configureForModeAuto() {
    temperatureSetPointSlider.setHidden(true)
    informationLabel.setText(NSLocalizedString("ThermostatInAutoModeDescription", comment: "describes that a thermostat is in auto mode"))
    informationLabel.setHidden(false)
    
    if WKAccessibilityIsVoiceOverRunning() {
      informationLabel.setAccessibilityLabel("Currently set to auto")
    }
    
    clearAllMenuItems()
    addManualMenuItem()
    addAwayMenuItem()
  }
  
  func configureForModeManual() {
    temperatureSetPointSlider.setHidden(false)
    informationLabel.setHidden(true)
    
    if WKAccessibilityIsVoiceOverRunning() {
      informationLabel.setAccessibilityLabel("Currently set to manual")
    }
    
    clearAllMenuItems()
    addAutoMenuItem()
    addAwayMenuItem()
  }
  
  // MARK: Menu Items and Actions
  
  func onAwaySelected() {
    thermostat?.delegate = nil
    configureForModeAway()
    if let thermostat = thermostat {
      thermostat.isOccupied = false
      thermostatManager?.saveMode(ofThermostat: thermostat, toMode: .Away)
    }
  }
  
  func onHomeSelected() {
    thermostat?.delegate = nil
    configureForModeHome()
    if let thermostat = thermostat {
      thermostat.isOccupied = true
      thermostatManager?.saveMode(ofThermostat: thermostat, toMode: .Home)
    }
  }
  
  func onAutoSelected() {
    thermostat?.delegate = nil
    configureForModeAuto()
    if let thermostat = thermostat {
      thermostat.isInAutoMode = true
      thermostatManager?.saveMode(ofThermostat: thermostat, toMode: .Auto)
    }
  }
  
  func onManualSelected() {
    thermostat?.delegate = nil
    configureForModeManual()
    if let thermostat = thermostat {
      thermostat.isInAutoMode = false
      thermostatManager?.saveMode(ofThermostat: thermostat, toMode: .Manual)
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
  
  @IBAction func onErrorIndicationImageTapped() {
    let thermostatName = thermostat?.name ?? ""
    let errorMessage = String(format: NSLocalizedString("ErrorFetchingThermostatInformation", comment: "Message shown to the user when an error occurs while fetching information of a thermostat"), thermostatName)
    watchDelegate.watchConnectivityHandler.transmitErrorToiPhone(errorMessage, completionHander: {
      self.presentControllerWithName(ErrorInterfaceController.identifier, context: errorMessage)
    })
  }
  
  // MARK: Interface builder actions
  
  @IBAction func onTemperatureSetPointChanged(value: Float) {
    temperatureSetPointIsBeingChanged = true
    
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
    temperatureSetPointIsBeingChanged = false
  }
  
  // MARK: Error handling
  
  func showErrorIndication(showErrorOnView: Bool) {
    if showErrorOnView {
      errorIndiciationButton.setHidden(false)
    } else {
      errorIndiciationButton.setHidden(true)
    }
  }
}

// MARK: - ThermostatDelegate

extension ThermostatInterfaceController: ThermostatDelegate {
  func didUpdateName(toNewValue newValue: String) {
    self.setTitle(thermostat?.name)
    
    lastDataFetchOrChangeWasFaulty = false
  }
  
  func didUpdateCurrentTemperature(toNewValue newValue: Int) {
    showCurrentTemperature()
    visualiseStateOfThermostat()
    
    lastDataFetchOrChangeWasFaulty = false
  }
  
  func didUpdateTemperatureSetpoint(toNewValue newValue: Int) {
    if !temperatureSetPointIsBeingChanged {
      showTemperatureSetPoint()
      visualiseStateOfThermostat()
    }
    lastDataFetchOrChangeWasFaulty = false
  }
  
  func didUpdateAutoMode(toOn on: Bool) {
    if thermostat?.isOccupied == true {
      if on {
        configureForModeAuto()
      } else {
        configureForModeManual()
      }
    }
    lastDataFetchOrChangeWasFaulty = false
  }
  
  func didUpdateOccupationMode(toNewValue toPresent: Bool) {
    if toPresent {
      configureForModeHome()
    } else {
      configureForModeAway()
    }
  }
  
  func didFailToRetrieveData(withError error: String) {
    lastDataFetchOrChangeWasFaulty = true
    WKInterfaceDevice.currentDevice().playHaptic(.Retry)
  }
  
  func didFailToChangeData(withError error: String) {
    lastDataFetchOrChangeWasFaulty = true
    WKInterfaceDevice.currentDevice().playHaptic(.Retry)
  }
}

// MARK: - WatchAppWatchConnectivityHandlerDelegate

extension ThermostatInterfaceController: WatchAppWatchConnectivityHandlerDelegate {
  func didUpdateApplicationSettings() {
    if ExtensionDelegate.settingsProvider.sessionID == nil {
      popController()
    }
  }
}
