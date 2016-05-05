//
//  Thermostat.swift
//  cosy
//
//  Created by James Bampoe on 01/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation

protocol ThermostatDelegate {
  func didUpdateName(toNewValue newValue: String)
  func didUpdateCurrentTemperature(toNewValue newValue: Int)
  func didUpdateTemperatureSetpoint(toNewValue newValue: Int)
  func didFailToRetrieveData(withError error: String)
}

final class Thermostat: NSObject, NSCoding {
  static let maximumTemperatureValue: Float = 40.0
  static let minimumTemperatureValue: Float = 10.0
  
  var delegate: ThermostatDelegate?
  weak var correspondingLocation: ThermostatLocation?
  
  var name: String {
    didSet {
      delegate?.didUpdateName(toNewValue: name)
    }
  }
  
  var currentTemperature: Int? {
    didSet {
      if let currentTemperature = currentTemperature {
        delegate?.didUpdateCurrentTemperature(toNewValue: currentTemperature)
      }
    }
  }
  
  var temperatureSetPoint: Int? {
    didSet {
      if let temperatureSetPoint = temperatureSetPoint {
        delegate?.didUpdateTemperatureSetpoint(toNewValue: temperatureSetPoint)
      }
    }
  }
  
  var identifier: String
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
  
  private init(identifier: String, name: String) {
    self.name = name
    self.identifier = identifier
    self.isInAutoMode = true
    self.isMarkedAsFavourite = false
  }
  
  convenience init(identifier: String, name: String, correspondingLocation: ThermostatLocation) {
    self.init(identifier: identifier, name: name)
    self.correspondingLocation = correspondingLocation
  }
  
  convenience init(identifier: String, name: String, currentTemperature: Int?, temperatureSetPoint: Int?, isInAutoMode: Bool, isMarkedAsFavourite: Bool, correspondingLocation: ThermostatLocation?) {
    self.init(identifier: identifier, name: name)
    self.currentTemperature = currentTemperature
    self.temperatureSetPoint = temperatureSetPoint
    self.isInAutoMode = isInAutoMode
    self.isMarkedAsFavourite = isMarkedAsFavourite
    self.correspondingLocation = correspondingLocation
  }
  
  convenience init?(coder decoder: NSCoder) {
    guard let name = decoder.decodeObjectForKey("name") as? String else {
        return nil
        // todo: fetch corresponding location
    }
    
    self.init(identifier: decoder.decodeObjectForKey("identifier") as? String ?? "", name: name, currentTemperature: decoder.decodeIntegerForKey("currentTemperature"), temperatureSetPoint: decoder.decodeIntegerForKey("temperatureSetpoint"), isInAutoMode: decoder.decodeBoolForKey("isInAutoMode"), isMarkedAsFavourite: decoder.decodeBoolForKey("isMarkedAsFavourite"), correspondingLocation: nil)
  }
  
  func encodeWithCoder(coder: NSCoder) {
    coder.encodeObject(self.name, forKey: "name")
    coder.encodeObject(self.identifier, forKey: "identifier")
    coder.encodeInteger(self.currentTemperature ?? -1, forKey: "currentTemperature")
    coder.encodeInteger(self.temperatureSetPoint ?? -1, forKey: "temperatureSetpoint")
    coder.encodeBool(self.isInAutoMode, forKey: "isInAutoMode")
    coder.encodeBool(self.isMarkedAsFavourite, forKey: "isMarkedAsFavourite")
  }
}

