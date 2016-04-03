//
//  ThermostatDataAccessor.swift
//  cosy
//
//  Created by James Bampoe on 03/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation

protocol ThermostatDataAccessorDelegate {
  func thermostatDataAccessor(didFetchLocations locations: [ThermostatLocation])
}

protocol ThermostatDataAccessor {
  var delegate: ThermostatDataAccessorDelegate? { get set }
  func fetchAvailableLocationsWithThermostatNames()
  func fetchDataOfThermostat(withIdentifier identifier: String) -> Thermostat?
}