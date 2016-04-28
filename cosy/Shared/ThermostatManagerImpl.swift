//
//  ThermostatManagerImpl.swift
//  cosy
//
//  Created by James Bampoe on 01/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation
import Alamofire

enum ThermostatManagerState{
  case Ready
  case ExpectingNewData
}

final class ThermostatManagerImpl: ThermostatManager {
  var delegate: ThermostatManagerDelegate? // consider declaring delegate as weak
  var thermostatLocations: [ThermostatLocation]
  private var dataAccessor: ThermostatDataAccessor
  private var state: ThermostatManagerState
  
  var favouriteThermostat: Thermostat? {
    willSet(newFavourite) {
      if let previousFavourite = favouriteThermostat {
        previousFavourite.isMarkedAsFavourite = false
      }
      newFavourite?.isMarkedAsFavourite = true
    }
  }
  
  init(dataAccessor: ThermostatDataAccessor) {
    self.thermostatLocations = [ThermostatLocation]()
    self.state = ThermostatManagerState.Ready
    self.dataAccessor = dataAccessor
    self.dataAccessor.delegate = self
  }
  
  func fetchNewData() {
    guard state == ThermostatManagerState.Ready else {
      // TODO: start timer to set manager back to ready
      return
    }
    state = .ExpectingNewData
    dataAccessor.fetchAvailableLocationsWithThermostatNames()
  }
  
  func updateData(ofThermostat thermostat: Thermostat) {
    // TODO: Implement
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

extension ThermostatManagerImpl: ThermostatDataAccessorDelegate {
  func thermostatDataAccessor(didFetchLocations locations: [ThermostatLocation]) {
    //let removedLocations = Set<ThermostatLocation>(thermostatLocations).subtract(locations)
    
    let newFoundLocations = Set<ThermostatLocation>(locations).subtract(thermostatLocations)
    
    let alreadyExistingLocations = Set<ThermostatLocation>(thermostatLocations).intersect(locations)
    for existingLocation in alreadyExistingLocations {
      let correspondingNewLocaton = Set<ThermostatLocation>(locations).filter{ $0.identifier == existingLocation.identifier }
      if let newLocationName = correspondingNewLocaton.first?.locationName {
        existingLocation.locationName = newLocationName
      }
    }
    
    thermostatLocations = Array(newFoundLocations.union(alreadyExistingLocations))
    state = .Ready
    delegate?.didUpdateListOfThermostats()
  }
  
  func thermostatDataAccessorFailedToFetchLocations() {
    state = .Ready
    delegate?.didFailToRetrieveData(withError: "Could not fetch the list of available thermostats") // TODO: use localised strings
  }
  
  func thermostatDataAccessor(didFetchThermostat thermostat: Thermostat) {
    // TODO: Handle and inform Thermostat - maybe handled already by thermostatDelegate
  }
  
  func thermostatDataAccessorFailedToFetchThermostat() {
    state = .Ready
    delegate?.didFailToRetrieveData(withError: "Could not fetch information of the selected thermostat") //TODO: Use localised strings
  }
}