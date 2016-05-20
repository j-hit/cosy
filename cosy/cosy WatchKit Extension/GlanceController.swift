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
  @IBOutlet var errorIndicationImage: WKInterfaceImage!
  
  private var thermostat: Thermostat?
  private var applicationFacade: ApplicationFacade?
  
  private var lastDataFetchWasFaulty = false {
    didSet {
      if lastDataFetchWasFaulty == true {
        showErrorIndication(true)
      } else if lastDataFetchWasFaulty == false && oldValue == true {
        showErrorIndication(false)
      }
    }
  }
  
  // MARK: - Lifecycle methods
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    applicationFacade = ApplicationFacade.instance
  }
  
  override func willActivate() {
    super.willActivate()
    thermostat = applicationFacade?.settingsProvider.favouriteThermostat
    if let thermostat = thermostat {
      thermostat.delegate = self
      
      thermostatNameLabel.setText(thermostat.name)
      showCurrentTemperature(thermostat.currentTemperature)
      showTemperatureSetpoint(thermostat.temperatureSetPoint)
      showStateImage()
      
      applicationFacade?.thermostatManager.updateData(ofThermostat: thermostat)
    }
  }
  
  override func didDeactivate() {
    super.didDeactivate()
    applicationFacade?.settingsProvider.favouriteThermostat = thermostat
  }
  
  // MARK: - Reloading data on view
  
  private func showStateImage() {
    if let thermostat = thermostat {
      switch thermostat.state {
      case .Heating:
        thermostatStateImage.setImageNamed("heating-glance")
      case .Cooling:
        thermostatStateImage.setImageNamed("cooling-glance")
      default:
        thermostatStateImage.setImage(nil)
      }
    }
  }
  
  private func showCurrentTemperature(currentTemperature: Int?) {
    if let currentTemperature = currentTemperature where currentTemperature > 0 {
      currentTemperatureLabel.setText(String(format: NSLocalizedString("CurrentTemperatureDescription", comment: "describes the current temperature from a thermostat"), currentTemperature))
    }
  }
  
  private func showTemperatureSetpoint(temperatureSetpoint: Int?) {
    if let temperatureSetpoint = temperatureSetpoint where temperatureSetpoint > 0 {
      temperatureSetpointLabel.setText("\(temperatureSetpoint)")
      temperatureSetpointLabel.setTextColor(thermostat?.state.visualiser().color)
      
      if WKAccessibilityIsVoiceOverRunning() {
        temperatureSetpointLabel.setAccessibilityLabel(String(format: NSLocalizedString("ThermostatSetPointAccessibilityLabel", comment: "Accessibility Label: Thermostat temperature set point"), temperatureSetpoint))
      }
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
extension GlanceController: ThermostatDelegate {
  func didUpdateName(toNewValue newValue: String) {
    thermostatNameLabel.setText(newValue)
    lastDataFetchWasFaulty = false
  }
  
  func didUpdateCurrentTemperature(toNewValue newValue: Int) {
    showCurrentTemperature(newValue)
    showStateImage()
    lastDataFetchWasFaulty = false
  }
  
  func didUpdateTemperatureSetpoint(toNewValue newValue: Int) {
    showTemperatureSetpoint(newValue)
    showStateImage()
    lastDataFetchWasFaulty = false
  }
  
  func didUpdateOccupationMode(toNewValue toPresent: Bool) {
    // Nothing to do here
  }
  
  func didUpdateAutoMode(toOn on: Bool) {
    // Nothing to do here
  }
  
  func didFailToRetrieveData(withError error: String) {
    lastDataFetchWasFaulty = true
    WKInterfaceDevice.currentDevice().playHaptic(.Retry)
  }
  
  func didFailToChangeData(withError error: String) {
    NSLog("Glance can only read data, this method should never be called")
  }
}
