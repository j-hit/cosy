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
  var thermostatLocations: [ThermostatLocation] { get }
  var favouriteThermostat: Thermostat? { get set }
  func fetchNewData()
  func saveTemperatureSetPointOfThermostat(thermostat: Thermostat)
  func clearAllData()
}