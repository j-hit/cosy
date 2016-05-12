//
//  ThermostatDataAccessor.swift
//  cosy
//
//  Created by James Bampoe on 03/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation

protocol ThermostatDataAccessorDelegate {
  func thermostatDataAccessor(didFetchThermostats fetchedThermostats: [Thermostat])
  func thermostatDataAccessorFailedToListOfThermostats()
}

protocol ThermostatDataAccessor {
  var delegate: ThermostatDataAccessorDelegate? { get set }
  func fetchListOfThermostats()
  func fetchDataOfThermostat(thermostat: Thermostat)
  func setPresentValueOfPoint(point: String, forThermostat thermostat: Thermostat, toValue value: AnyObject)
}