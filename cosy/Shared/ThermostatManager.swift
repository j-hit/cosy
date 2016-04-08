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
  func fetchNewData()
}

final class ThermostatManagerMock: ThermostatManager {
  var delegate: ThermostatManagerDelegate?
  var thermostatLocations: [ThermostatLocation]
  
  init() {
    thermostatLocations = [ThermostatLocation]()
    let locationCasa = ThermostatLocation(identifier: "1BIE53-5TXOH-DFTHT-2LBT4-11111", locationName: "Casa", isOccupied: true)
    locationCasa.addThermostat(Thermostat(name: "Living room"))
    
    let locationOffice = ThermostatLocation(identifier: "2BIE53-5TXOH-DFTHT-2LBT4-22222", locationName: "Office", isOccupied: false)
    locationOffice.addThermostat(Thermostat(name: "Lobby"))
    
    let locationCountrySide = ThermostatLocation(identifier: "3BIE53-5TXOH-DFTHT-2LBT4-22222", locationName: "Country side", isOccupied: false)
    locationCountrySide.addThermostat(Thermostat(name: "Cottage"))
    
    thermostatLocations.append(locationCasa)
    thermostatLocations.append(locationOffice)
    thermostatLocations.append(locationCountrySide)
  }
  
  func fetchNewData() {
  }
}