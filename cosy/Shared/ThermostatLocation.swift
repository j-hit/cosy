//
//  ThermostatLocation.swift
//  cosy
//
//  Created by James Bampoe on 01/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation

func ==(lhs: ThermostatLocation, rhs: ThermostatLocation) -> Bool{
  return lhs.identifier == rhs.identifier
}

final class ThermostatLocation: Hashable {
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
  
  var hashValue: Int {
    return self.identifier.hashValue
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