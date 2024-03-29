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
  @IBOutlet var informationLabel: WKInterfaceLabel!
  
  private var thermostat: Thermostat?
  private var applicationFacade: ApplicationFacade?
  
  private var lastDataFetchWasFaulty = false {
    didSet {
      if lastDataFetchWasFaulty == true {
        showErrorIndication(true)
      } else if lastDataFetchWasFaulty == false {
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
      
      informationLabel.setHidden(true)
      thermostatNameLabel.setText(thermostat.name)
      thermostatNameLabel.setHidden(false)
      showCurrentTemperature(thermostat.currentTemperature)
      showTemperatureSetpoint(thermostat.temperatureSetPoint)
      showStateImage()
      
      applicationFacade?.thermostatManager.updateData(ofThermostat: thermostat)
    } else {
      handleNoThermostatSetAsFavourite()
    }
  }
  
  override func didDeactivate() {
    super.didDeactivate()
    applicationFacade?.settingsProvider.favouriteThermostat = thermostat
  }
  
  // MARK: - Reloading data on view
  
  private func handleNoThermostatSetAsFavourite() {
    informationLabel.setText(NSLocalizedString("ErrorGlanceNoThermostatAsFavourite", comment: "Message shown to the user the glance is view without having set a thermostat as Favourite"))
    informationLabel.setHidden(false)
    thermostatNameLabel.setHidden(true)
    currentTemperatureLabel.setHidden(true)
    temperatureSetpointLabel.setHidden(true)
    thermostatStateImage.setImage(nil)
  }
  
  private func showStateImage() {
    if let thermostat = thermostat {
      var thermostatAccessibilityLabel: String
      
      switch thermostat.state {
      case .Heating:
        thermostatStateImage.setImageNamed("heating-glance")
        thermostatAccessibilityLabel = NSLocalizedString("ThermostatHeatingAccessibilityLabel", comment: "Accessibility Label: Thermostat state heating")
      case .Cooling:
        thermostatStateImage.setImageNamed("cooling-glance")
        thermostatAccessibilityLabel = NSLocalizedString("ThermostatCoolingAccessibilityLabel", comment: "Accessibility Label: Thermostat state cooling")
      default:
        thermostatStateImage.setImage(nil)
        thermostatAccessibilityLabel = NSLocalizedString("ThermostatNeutralAccessibilityLabel", comment: "Accessibility Label: Thermostat state neutral")
      }
      
      if WKAccessibilityIsVoiceOverRunning() {
        thermostatStateImage.setAccessibilityLabel(thermostatAccessibilityLabel)
      }
    }
  }
  
  private func showCurrentTemperature(currentTemperature: Int?) {
    if let currentTemperature = currentTemperature where currentTemperature > 0 {
      currentTemperatureLabel.setText(String(format: NSLocalizedString("CurrentTemperatureDescription", comment: "describes the current temperature from a thermostat"), currentTemperature))
      currentTemperatureLabel.setHidden(false)
    }
  }
  
  private func showTemperatureSetpoint(temperatureSetpoint: Int?) {
    if let temperatureSetpoint = temperatureSetpoint where temperatureSetpoint > 0 {
      temperatureSetpointLabel.setText("\(temperatureSetpoint)")
      temperatureSetpointLabel.setTextColor(thermostat?.state.visualiser().color)
      temperatureSetpointLabel.setHidden(false)
      
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
