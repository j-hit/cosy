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
  var identifier: String
  
  var imageName: String {
    if isOccupied {
      return "occupied"
    } else {
      return "unoccupied"
    }
  }
  
  init(identifier: String, locationName: String, isOccupied: Bool){
    self.identifier = identifier
    self.locationName = locationName
    self.isOccupied = isOccupied
    thermostats = [Thermostat]()
  }
  
  convenience init(identifier: String) {
    self.init(identifier: identifier, locationName: "location", isOccupied: false)
  }
  
  convenience init(identifier: String, locationName: String) {
    self.init(identifier: identifier, locationName: locationName, isOccupied: false)
  }
  
  func addThermostat(thermostat: Thermostat) {
    thermostats.append(thermostat)
  }
}