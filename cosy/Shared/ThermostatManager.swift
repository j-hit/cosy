//
//  ThermostatManager.swift
//  cosy
//
//  Created by James Bampoe on 01/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation

protocol ThermostatManagerDelegate {
  func didUpdateListOfThermostats()
}

protocol ThermostatManager: class {
  var delegate: ThermostatManagerDelegate? { get set }
  var thermostatLocations: [ThermostatLocation] { get set }
  var favouriteThermostat: Thermostat? { get set }
  func fetchNewData()
  func updateData(ofThermostat thermostat: Thermostat)
  func saveTemperatureSetPointOfThermostat(thermostat: Thermostat)
  func clearAllData()
  // TODO: Consider using separate class for import export
  func exportThermostatLocations() -> [[String: AnyObject]]
  func importThermostatLocations(locations: [[String : AnyObject]])
}