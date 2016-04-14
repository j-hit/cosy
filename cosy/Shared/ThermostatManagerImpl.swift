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
      return
    }
    state = .ExpectingNewData
    dataAccessor.fetchAvailableLocationsWithThermostatNames()
  }
  
  func saveTemperatureSetPointOfThermostat(thermostat: Thermostat) {
    print("saved temperature set point of thermostat")
  }
  
  func clearAllData() {
    thermostatLocations.removeAll()
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
  }
  
  func thermostatDataAccessor(didFetchThermostat thermostat: Thermostat) {
    // TODO: Handle and inform ThermostatManagerDelegate
  }
}