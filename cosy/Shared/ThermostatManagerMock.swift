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
    fetchNewData()
  }
  
  func fetchNewData() {
    guard state == ThermostatManagerState.Ready else {
      return
    }
    state = .ExpectingNewData
    
    let seconds = 2.0
    let delay = seconds * Double(NSEC_PER_SEC)
    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
    
    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
      self.thermostatLocations = [ThermostatLocation]()
      let locationCasa = ThermostatLocation(identifier: "1BIE53-5TXOH-DFTHT-2LBT4-11111", locationName: "Casa", isOccupied: true)
      locationCasa.addThermostat(Thermostat(name: "Living room", correspondingLocation: locationCasa))
      
      let locationOffice = ThermostatLocation(identifier: "2BIE53-5TXOH-DFTHT-2LBT4-22222", locationName: "Office", isOccupied: false)
      locationOffice.addThermostat(Thermostat(name: "Lobby", correspondingLocation: locationCasa))
      
      let locationCountrySide = ThermostatLocation(identifier: "3BIE53-5TXOH-DFTHT-2LBT4-22222", locationName: "Country side", isOccupied: false)
      locationCountrySide.addThermostat(Thermostat(name: "Cottage", correspondingLocation: locationCasa))
      
      self.thermostatLocations.append(locationCasa)
      self.thermostatLocations.append(locationOffice)
      self.thermostatLocations.append(locationCountrySide)
      
      self.state = .Ready
      self.delegate?.didUpdateListOfThermostats()
    })
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
          }
        }
        thermostatLocations.append(thermostatLocation)
      }
    }
    delegate?.didUpdateListOfThermostats()
  }
}