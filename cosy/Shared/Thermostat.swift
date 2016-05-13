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
  func didUpdateAutoMode(toOn on: Bool)
  func didUpdateOccupationMode(toNewValue toPresent: Bool)
  func didFailToRetrieveData(withError error: String)
  func didFailToChangeData(withError error: String)
}

final class Thermostat: NSObject, NSCoding {
  static let maximumTemperatureValue: Float = 40.0
  static let minimumTemperatureValue: Float = 10.0
  
  var delegate: ThermostatDelegate?
  var identifier: String
  var isMarkedAsFavourite: Bool
  var savingData = false
  
  var name: String {
    didSet {
      delegate?.didUpdateName(toNewValue: name)
    }
  }
  
  var isOccupied: Bool {
    didSet {
      if isOccupied != oldValue {
        delegate?.didUpdateOccupationMode(toNewValue: isOccupied)
      }
    }
  }
  
  var currentTemperature: Int? {
    didSet {
      if let currentTemperature = currentTemperature where currentTemperature != oldValue {
        delegate?.didUpdateCurrentTemperature(toNewValue: currentTemperature)
      }
    }
  }
  
  var temperatureSetPoint: Int? {
    didSet {
      if let temperatureSetPoint = temperatureSetPoint where temperatureSetPoint != oldValue {
        delegate?.didUpdateTemperatureSetpoint(toNewValue: temperatureSetPoint)
      }
    }
  }
  
  var isInAutoMode: Bool {
    didSet {
      if savingData {
        isInAutoMode = oldValue
      } else if isInAutoMode != oldValue {
        delegate?.didUpdateAutoMode(toOn: isInAutoMode)
      }
    }
  }
  
  var state: ThermostatState {
    if (temperatureSetPoint > currentTemperature) {
      return .Heating
    } else if(temperatureSetPoint < currentTemperature) {
      return .Cooling
    } else {
      return .Idle
    }
  }
  
  init(identifier: String) {
    self.identifier = identifier
    self.name = "Thermostat"
    self.isInAutoMode = true
    self.isMarkedAsFavourite = false
    self.isOccupied = false
  }
  
  convenience init(identifier: String, name: String) {
    self.init(identifier: identifier)
    self.name = name
  }
  
  convenience init(identifier: String, name: String, currentTemperature: Int?, temperatureSetPoint: Int?, isInAutoMode: Bool, isMarkedAsFavourite: Bool) {
    self.init(identifier: identifier, name: name)
    self.currentTemperature = currentTemperature
    self.temperatureSetPoint = temperatureSetPoint
    self.isInAutoMode = isInAutoMode
    self.isMarkedAsFavourite = isMarkedAsFavourite
  }
  
  convenience init?(coder decoder: NSCoder) {
    guard let name = decoder.decodeObjectForKey("name") as? String else {
        return nil
    }
    
    self.init(identifier: decoder.decodeObjectForKey("identifier") as? String ?? "", name: name, currentTemperature: decoder.decodeIntegerForKey("currentTemperature"), temperatureSetPoint: decoder.decodeIntegerForKey("temperatureSetpoint"), isInAutoMode: decoder.decodeBoolForKey("isInAutoMode"), isMarkedAsFavourite: decoder.decodeBoolForKey("isMarkedAsFavourite"))
    
    self.isOccupied = decoder.decodeBoolForKey("isOccupied")
  }
  
  func encodeWithCoder(coder: NSCoder) {
    coder.encodeObject(self.name, forKey: "name")
    coder.encodeObject(self.identifier, forKey: "identifier")
    coder.encodeInteger(self.currentTemperature ?? -1, forKey: "currentTemperature")
    coder.encodeInteger(self.temperatureSetPoint ?? -1, forKey: "temperatureSetpoint")
    coder.encodeBool(self.isInAutoMode, forKey: "isInAutoMode")
    coder.encodeBool(self.isMarkedAsFavourite, forKey: "isMarkedAsFavourite")
    coder.encodeBool(self.isOccupied, forKey: "isOccupied")
  }
}

