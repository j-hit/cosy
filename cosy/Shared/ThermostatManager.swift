//
//  ThermostatManager.swift
//  cosy
//
//  Created by James Bampoe on 01/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation

protocol ThermostatManagerDelegate: class {
  func didUpdateListOfThermostats()
  func didFailToRetrieveData(withError error: String)
}

protocol ThermostatManager: class {
  weak var delegate: ThermostatManagerDelegate? { get set }
  var thermostats: [Thermostat] { get set }
  var favouriteThermostat: Thermostat? { get set }
  func fetchNewListOfThermostats()
  func updateData(ofThermostat thermostat: Thermostat)
  func saveTemperatureSetPointOfThermostat(thermostat: Thermostat)
  func saveMode(ofThermostat thermostat: Thermostat, toMode mode: ThermostatMode)
  func clearAllData()
  func exportThermostatsAsNSData() -> NSData
  func importThermostats(fromNSDataObject thermostatsAsNSData: NSData?)
}