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
    dataAccessor.fetchAvailableLocationsWithThermostatNames()
  }
}

extension ThermostatManagerImpl: ThermostatDataAccessorDelegate {
  func thermostatDataAccessor(didFetchLocations locations: [ThermostatLocation]) {
    // TODO: merge data & only inform delegate if something changed
    thermostatLocations = locations
    delegate?.didUpdateListOfThermostats()  // Move to didSet of the var
  }
}