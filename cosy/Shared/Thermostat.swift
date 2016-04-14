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

func ==(lhs: Thermostat, rhs: Thermostat) -> Bool{
  return lhs.name == rhs.name && lhs.correspondingLocation == rhs.correspondingLocation
}

final class Thermostat: NSObject, NSCoding {
  static let maximumTemperatureValue: Float = 40.0
  static let minimumTemperatureValue: Float = 10.0
  
  var name: String
  weak var correspondingLocation: ThermostatLocation?
  var currentTemperature: Int?
  var temperatureSetPoint: Int?
  var isInAutoMode: Bool
  var isMarkedAsFavourite: Bool
  
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
    self.isMarkedAsFavourite = false
  }
  
  convenience init(name: String, correspondingLocation: ThermostatLocation) {
    self.init(name: name)
    self.correspondingLocation = correspondingLocation
  }
  
  /////
  
  convenience init(name: String, currentTemperature: Int?, temperatureSetPoint: Int?, isInAutoMode: Bool, correspondingLocation: ThermostatLocation?) {
    self.init(name: name)
    self.currentTemperature = currentTemperature
    self.temperatureSetPoint = temperatureSetPoint
    self.isInAutoMode = isInAutoMode
    self.correspondingLocation = correspondingLocation
  }
  
  convenience init?(coder decoder: NSCoder) {
    guard let name = decoder.decodeObjectForKey("name") as? String else {
        return nil
        // todo: fetch corresponding location
    }
    
    self.init(name: name, currentTemperature: decoder.decodeIntegerForKey("currentTemperature"), temperatureSetPoint: decoder.decodeIntegerForKey("temperatureSetpoint"), isInAutoMode: decoder.decodeBoolForKey("isInAutoMode"), correspondingLocation: nil)
  }
  
  func encodeWithCoder(coder: NSCoder) {
    coder.encodeObject(self.name, forKey: "name")
    coder.encodeInteger(self.currentTemperature ?? 0, forKey: "currentTemperature")
    coder.encodeInteger(self.temperatureSetPoint ?? 0, forKey: "temperatureSetpoint")
    coder.encodeBool(self.isInAutoMode, forKey: "isInAutoMode")
  }
}

