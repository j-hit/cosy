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
  var thermostats: [Thermostat]
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
    self.thermostats = [Thermostat]()
    self.state = ThermostatManagerState.Ready
    self.dataAccessor = dataAccessor
    self.dataAccessor.delegate = self
  }
  
  func fetchNewListOfThermostats() {
    guard state == ThermostatManagerState.Ready else {
      return
    }
    state = .ExpectingNewData
    dataAccessor.fetchListOfThermostats()
  }
  
  func updateData(ofThermostat thermostat: Thermostat) {
    dataAccessor.fetchDataOfThermostat(thermostat)
  }
  
  func saveTemperatureSetPointOfThermostat(thermostat: Thermostat) {
    if let temperatureSetPoint = thermostat.temperatureSetPoint {
      dataAccessor.setPresentValueOfPoint("SpTR", forThermostat: thermostat, toValue: temperatureSetPoint)
    }
  }
  
  func saveMode(ofThermostat thermostat: Thermostat, toMode mode: ThermostatMode) {
    switch mode {
    case .Auto:
      dataAccessor.setPresentValueOfPoint("CmfBtn", forThermostat: thermostat, toValue: false)
    case .Manual:
      dataAccessor.setPresentValueOfPoint("CmfBtn", forThermostat: thermostat, toValue: true)
    case .Home:
      dataAccessor.setPresentValueOfPoint("OccMod", forThermostat: thermostat, toValue: "Present")
    case .Away:
      dataAccessor.setPresentValueOfPoint("OccMod", forThermostat: thermostat, toValue: "Absent")
    }
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

extension ThermostatManagerImpl: ThermostatDataAccessorDelegate {
  func thermostatDataAccessor(didFetchThermostats fetchedThermostats: [Thermostat]) {
    var newListOfThermostats = [Thermostat]()
    for fetchedThermostat in fetchedThermostats {
      let filterForThermostat = thermostats.filter{ (thermostat) in thermostat.identifier == fetchedThermostat.identifier}
      if let existingThermostat = filterForThermostat.first {
        existingThermostat.name = fetchedThermostat.name
        existingThermostat.isOccupied = fetchedThermostat.isOccupied
        existingThermostat.currentTemperature = fetchedThermostat.currentTemperature
        existingThermostat.temperatureSetPoint = fetchedThermostat.temperatureSetPoint
        newListOfThermostats.append(existingThermostat)
      } else {
        newListOfThermostats.append(fetchedThermostat)
      }
    }
    
    self.thermostats = newListOfThermostats
    state = .Ready
    delegate?.didUpdateListOfThermostats()
  }
  
  func thermostatDataAccessorFailedToListOfThermostats() {
    state = .Ready
    delegate?.didFailToRetrieveData(withError: NSLocalizedString("ErrorFetchingListOfThermostats", comment: "Message shown to the user when an error occurs while fetching the list of thermostats"))
  }
}