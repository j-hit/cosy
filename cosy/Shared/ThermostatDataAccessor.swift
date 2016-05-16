//
//  ThermostatDataAccessor.swift
//  cosy
//
//  Created by James Bampoe on 03/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation

enum AccessibleThermostatDataPoint {
  case roomTemperature
  case temperatureSetPoint
  case occupationMode
  case comfortMode
  
  var stringRepresentation: String {
    switch self {
    case roomTemperature:
      return "RTemp"
    case temperatureSetPoint:
      return "SpTR"
    case occupationMode:
      return "OccMod"
    case comfortMode:
      return "CmfBtn"
    }
  }
}

protocol ThermostatDataAccessorDelegate: class {
  func thermostatDataAccessor(didFetchThermostats fetchedThermostats: [Thermostat])
  func thermostatDataAccessorFailedToFetchListOfThermostats()
}

protocol ThermostatDataAccessor {
  weak var delegate: ThermostatDataAccessorDelegate? { get set }
  func fetchListOfThermostats()
  func fetchDataOfThermostat(thermostat: Thermostat)
  func setPresentValueOfPoint(point: AccessibleThermostatDataPoint, forThermostat thermostat: Thermostat, toValue value: AnyObject, successHandler: (() -> Void)?)
}