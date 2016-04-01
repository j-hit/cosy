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

protocol ThermostatManager {
  var delegate: ThermostatManagerDelegate? { get set }
  var thermostatLocations: [ThermostatLocation] { get }
  func reloadData()
}

final class ThermostatManagerMock: ThermostatManager {
  var delegate: ThermostatManagerDelegate?
  var thermostatLocations: [ThermostatLocation]
  
  init() {
    thermostatLocations = [ThermostatLocation]()
    reloadData()
  }
  
  func reloadData() {
    thermostatLocations.removeAll()
    let locationCasa = ThermostatLocation(locationName: "Casa", isOccupied: true)
    locationCasa.addThermostat(Thermostat(name: "Living room"))
    locationCasa.addThermostat(Thermostat(name: "Bedroom"))
    locationCasa.addThermostat(Thermostat(name: "Guest room"))
    
    let locationOffice = ThermostatLocation(locationName: "Office", isOccupied: false)
    locationOffice.addThermostat(Thermostat(name: "Kitchen"))
    locationOffice.addThermostat(Thermostat(name: "Lobby"))
    
    thermostatLocations.append(locationCasa)
    thermostatLocations.append(locationOffice)
    
    delegate?.didUpdateListOfThermostats()
  }
}