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
  var delegate: ThermostatManagerDelegate?
  var thermostatLocations: [ThermostatLocation]
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
    self.thermostatLocations = [ThermostatLocation]()
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
      if self.thermostatLocations.count == 0 {
        self.loadThermostatLocations()
      } else {
        self.delegate?.didUpdateListOfThermostats()
      }
    })
  }
  
  private func loadThermostatLocations() {
    state = .ExpectingNewData
    
    thermostatLocations = [ThermostatLocation]()
    let locationCasa = ThermostatLocation(identifier: "000000-00000-00000-00000-00000", locationName: "Casa", isOccupied: true)
    locationCasa.addThermostat(Thermostat(identifier: "000000-00000-00000-00000-00000", name: "Living room", correspondingLocation: locationCasa))
    
    let locationOffice = ThermostatLocation(identifier: "000000-00000-00000-00000-00001", locationName: "Office", isOccupied: false)
    locationOffice.addThermostat(Thermostat(identifier: "000000-00000-00000-00000-00001", name: "Lobby", correspondingLocation: locationCasa))
    
    let locationCountrySide = ThermostatLocation(identifier: "000000-00000-00000-00000-00002", locationName: "Country side", isOccupied: false)
    locationCountrySide.addThermostat(Thermostat(identifier: "000000-00000-00000-00000-00002", name: "Cottage", correspondingLocation: locationCasa))
    
    thermostatLocations.append(locationCasa)
    thermostatLocations.append(locationOffice)
    thermostatLocations.append(locationCountrySide)
    
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
    thermostatLocations.removeAll()
  }
  
  func exportThermostatLocations() -> [[String: AnyObject]] {
    NSKeyedArchiver.setClassName("Thermostat", forClass: Thermostat.self)
    return thermostatLocations.map { thermostatLocation in
      [
        "locationName": thermostatLocation.locationName,
        "identifier": thermostatLocation.identifier,
        "isOccupied": thermostatLocation.isOccupied,
        "thermostats": NSKeyedArchiver.archivedDataWithRootObject(thermostatLocation.thermostats)
      ]
    }
  }
  
  func importThermostatLocations(locations: [[String : AnyObject]]) {
    clearAllData()
    NSKeyedUnarchiver.setClass(Thermostat.self, forClassName: "Thermostat")
    
    for location in locations {
      if let identifier = location["identifier"] as? String {
        let thermostatLocation = ThermostatLocation(identifier: identifier)
        
        if let locationName = location["locationName"] as? String {
          thermostatLocation.locationName = locationName
        }
        
        if let isOccupied = location["isOccupied"] as? Bool {
          thermostatLocation.isOccupied = isOccupied
        }
        
        if let thermostatsEncoded = location["thermostats"] as? NSData {
          if let thermostatsDecoded = NSKeyedUnarchiver.unarchiveObjectWithData(thermostatsEncoded) as? [Thermostat] {
            thermostatLocation.thermostats = thermostatsDecoded
            for thermostat in thermostatLocation.thermostats {
              thermostat.correspondingLocation = thermostatLocation
            }
          }
        }
        thermostatLocations.append(thermostatLocation)
      }
    }
    delegate?.didUpdateListOfThermostats()
  }
}