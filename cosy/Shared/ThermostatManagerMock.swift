//
//  ThermostatManagerMock.swift
//  cosy
//
//  Created by James Bampoe on 14/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation

final class ThermostatManagerMock: ThermostatManager {
  private var state: ThermostatManagerState
  var settingsProvider: SettingsProvider
  weak var delegate: ThermostatManagerDelegate?
  var thermostats: [Thermostat]
  var favouriteThermostat: Thermostat? {
    willSet(newFavourite) {
      if let previousFavourite = favouriteThermostat {
        previousFavourite.isMarkedAsFavourite = false
      }
      newFavourite?.isMarkedAsFavourite = true
    }
  }
  
  init(settingsProvider: SettingsProvider) {
    self.state = ThermostatManagerState.Ready
    self.settingsProvider = settingsProvider
    self.thermostats = [Thermostat]()
    fetchNewListOfThermostats()
  }
  
  func fetchNewListOfThermostats() {
    guard state == ThermostatManagerState.Ready else {
      return
    }
    
    let seconds = 2.0
    let delay = seconds * Double(NSEC_PER_SEC)
    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
    
    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
      if self.thermostats.count == 0 {
        self.loadThermostatLocations()
      } else {
        self.delegate?.didUpdateListOfThermostats()
      }
    })
  }
  
  private func loadThermostatLocations() {
    state = .ExpectingNewData
    
    thermostats = [Thermostat]()
    thermostats.append(Thermostat(identifier: "000000-00000-00000-00000-00000", name: "Living room"))
    thermostats.append(Thermostat(identifier: "000000-00000-00000-00000-00001", name: "Lobby"))
    thermostats.append(Thermostat(identifier: "000000-00000-00000-00000-00002", name: "Cottage"))
    
    state = .Ready
    delegate?.didUpdateListOfThermostats()
  }
  
  func updateData(ofThermostat thermostat: Thermostat) {
    setRandomValuesForThermostat(thermostat)
  }
  
  private func setRandomValuesForThermostat(thermostat: Thermostat) {
    let seconds = 2.0
    let delay = seconds * Double(NSEC_PER_SEC)
    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
    
    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
      thermostat.currentTemperature = Int(arc4random_uniform(30) + 5)
      thermostat.temperatureSetPoint = Int(arc4random_uniform(30) + 5)
      
      if thermostat.isMarkedAsFavourite {
        self.settingsProvider.favouriteThermostat = thermostat
      }
    })
  }
  
  func saveTemperatureSetPointOfThermostat(thermostat: Thermostat) {
    print("saved temperature set point of thermostat")
  }
  
  func saveMode(ofThermostat thermostat: Thermostat, toMode mode: ThermostatMode) {
  }
  
  func clearAllData() {
    thermostats.removeAll()
  }
  
  func exportThermostatsAsNSData() -> NSData {
    NSKeyedArchiver.setClassName("Thermostat", forClass: Thermostat.self)
    return NSKeyedArchiver.archivedDataWithRootObject(thermostats)
  }
  
  func importThermostats(fromNSDataObject thermostatsAsNSData: NSData?) {
    clearAllData()
    NSKeyedUnarchiver.setClass(Thermostat.self, forClassName: "Thermostat")
    if let thermostatsEncoded = thermostatsAsNSData {
      if let thermostatsDecoded = NSKeyedUnarchiver.unarchiveObjectWithData(thermostatsEncoded) as? [Thermostat] {
        thermostats = thermostatsDecoded
      }
    }
    delegate?.didUpdateListOfThermostats()
  }
}