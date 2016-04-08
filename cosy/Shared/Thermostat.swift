//
//  Thermostat.swift
//  cosy
//
//  Created by James Bampoe on 01/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation

enum ThermostatState {
  case Heating
  case Cooling
  case Idle
  
  func visualiser() -> ThermostatStateVisualiser {
    switch self {
    case Heating:
      return HeatingStateVisualiser()
    case Cooling:
      return CoolingStateVisualiser()
    case Idle:
      return IdleStateVisualiser()
    }
  }
}

final class Thermostat {
  var name: String
  weak var correspondingLocation: ThermostatLocation?
  var currentTemperature: Int?
  var temperatureSetPoint: Int?
  var isInAutoMode: Bool
  var state: ThermostatState {
    if (temperatureSetPoint > currentTemperature) {
      return .Heating
    } else if(temperatureSetPoint < currentTemperature) {
      return .Cooling
    } else {
      return .Idle
    }
  }
  
  private init(name: String) {
    self.name = name
    // test
    self.currentTemperature = 18
    self.temperatureSetPoint = 23
    self.isInAutoMode = true
  }
  
  convenience init(name: String, correspondingLocation: ThermostatLocation) {
    self.init(name: name)
    self.correspondingLocation = correspondingLocation
  }
}