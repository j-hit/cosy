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
}

final class Thermostat {
  var name: String
  var currentTemperature: Int?
  var temperatureSetPoint: Int?
  var state: ThermostatState {
    if (temperatureSetPoint > currentTemperature) {
      return .Heating
    } else if(temperatureSetPoint < currentTemperature) {
      return .Cooling
    } else {
      return .Idle
    }
  }
  
  init(name: String) {
    self.name = name
    // test
    self.currentTemperature = 18
    self.temperatureSetPoint = 23
  }
}