//
//  ThermostatLocation.swift
//  cosy
//
//  Created by James Bampoe on 01/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation

final class ThermostatLocation {
  var locationName: String
  var isOccupied: Bool
  var thermostats: [Thermostat]
  
  var imageName: String {
    if isOccupied {
      return "occupied"
    } else {
      return "unoccupied"
    }
  }
  
  init(locationName: String, isOccupied: Bool){
    self.locationName = locationName
    self.isOccupied = isOccupied
    thermostats = [Thermostat]()
  }
  
  convenience init(locationName: String) {
    self.init(locationName: locationName, isOccupied: false)
  }
  
  func addThermostat(thermostat: Thermostat) {
    thermostats.append(thermostat)
  }
}