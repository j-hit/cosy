//
//  ThermostatManagerImpl.swift
//  cosy
//
//  Created by James Bampoe on 01/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation

final class ThermostatManagerImpl: ThermostatManager {
  var delegate: ThermostatManagerDelegate?
  var thermostatLocations: [ThermostatLocation]
  
  init() {
    thermostatLocations = [ThermostatLocation]()
    reloadData()
  }
  
  func reloadData() {
    thermostatLocations.removeAll()
    // TODO: PERFORM NETWORK REQUEST
    
    let locationCasa = ThermostatLocation(locationName: "Real House", isOccupied: true)
    locationCasa.addThermostat(Thermostat(name: "Living room"))
    
    let locationOffice = ThermostatLocation(locationName: "Real Office", isOccupied: false)
    locationOffice.addThermostat(Thermostat(name: "Kitchen"))
    
    thermostatLocations.append(locationCasa)
    thermostatLocations.append(locationOffice)
    
    delegate?.didUpdateListOfThermostats()
  }
}