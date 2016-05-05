//
//  CPSCloudThermostatDataAccessor.swift
//  cosy
//
//  Created by James Bampoe on 03/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation
import Alamofire

final class CPSCloudThermostatDataAccessor: ThermostatDataAccessor {
  var delegate: ThermostatDataAccessorDelegate?
  var settingsProvider: SettingsProvider
  var lastFetchedLocations: [ThermostatLocation]
  
  init(settingsProvider: SettingsProvider) {
    self.settingsProvider = settingsProvider
    self.lastFetchedLocations = [ThermostatLocation]()
  }
  
  var outstandingRequestsForLocationFetchToFinish: Int = 0 {
    didSet {
      if outstandingRequestsForLocationFetchToFinish == 0 {
        delegate?.thermostatDataAccessor(didFetchLocations: lastFetchedLocations)
      } else if outstandingRequestsForLocationFetchToFinish < 0 {
        NSLog("ERROR: outstandingRequestsForLocationFetchToFinish should not have minus value")
        outstandingRequestsForLocationFetchToFinish = 0
      }
    }
  }
  
  var baseURL: String {
    return settingsProvider.baseURLOfCPSCloud
  }
  
  // MARK: - Request headers
  
  private func headerForAuthorizedAccess() -> [String: String]? {
    guard let sessionID = settingsProvider.sessionID else {
      return nil
    }
    
    return [
      "Authorization": "Session \(sessionID)",
      "Content-Type": "application/json"
    ]
  }
  
  // MARK: - Fetch locations and thermostat names
  
  func fetchAvailableLocationsWithThermostatNames() {
    performRequestToFetchListOfLocations() // TODO: don't just pass through
  }
  
  private func performRequestToFetchListOfLocations() {
    guard let headersForRequest = headerForAuthorizedAccess() else {
      delegate?.thermostatDataAccessorFailedToFetchLocations()
      return
    }
    
    guard let urlForLocations = NSURL(string: "\(baseURL)")?.URLByAppendingPathComponent("/home/sth") else {
      delegate?.thermostatDataAccessorFailedToFetchLocations()
      return
    }
    
    Alamofire.request(.GET, urlForLocations, headers: headersForRequest)
      .responseJSON { response in
        switch response.result {
        case .Success:
          if let locations = response.result.value as? [[String: String]]
          {
            self.lastFetchedLocations.removeAll()
            self.outstandingRequestsForLocationFetchToFinish = locations.count * 2
            
            for location in locations {
              if let locationIdentifier = location["activation-key"] {
                let fetchedLocation = ThermostatLocation(identifier: locationIdentifier)
                self.lastFetchedLocations.append(fetchedLocation)
                
                self.fetchNameForLocation(fetchedLocation)
                self.fetchOccupationModeForLocation(fetchedLocation)
                NSLog("location key: \(locationIdentifier)")
              } else {
                self.outstandingRequestsForLocationFetchToFinish -= 1
              }
            }
          }
        case .Failure(let error):
          NSLog("Error fetching locations: \(error.localizedDescription)")
          self.delegate?.thermostatDataAccessorFailedToFetchLocations()
        }
    }
  }
  
  private func fetchNameForLocation(location: ThermostatLocation) {
    guard let headersForRequest = headerForAuthorizedAccess() else {
      delegate?.thermostatDataAccessorFailedToFetchLocations()
      return
    }
    
    guard let urlForLocationName = NSURL(string: "\(baseURL)")?.URLByAppendingPathComponent("/home/sth/\(location.identifier)/@location") else {
      delegate?.thermostatDataAccessorFailedToFetchLocations()
      return
    }
    
    Alamofire.request(.GET, urlForLocationName, headers: headersForRequest)
      .responseString { response in
        switch response.result {
        case .Success:
          print("location name fetch response: \(response.result.value)")
          if let locationName = response.result.value
          {
            location.locationName = locationName
            location.addThermostat(Thermostat(identifier: location.identifier, name: locationName, correspondingLocation: location))
            NSLog("location name: \(locationName) - thermostat name: \(locationName)")
          }
        case .Failure(let error):
          NSLog("Error fetching location name: \(error.localizedDescription)")
          self.delegate?.thermostatDataAccessorFailedToFetchLocations()
        }
        self.outstandingRequestsForLocationFetchToFinish -= 1
    }
  }
  
  private func fetchOccupationModeForLocation(location: ThermostatLocation) {
    guard let headersForRequest = headerForAuthorizedAccess() else {
      delegate?.thermostatDataAccessorFailedToFetchLocations()
      return
    }
    
    guard let urlForOccupationMode = NSURL(string: "\(baseURL)")?.URLByAppendingPathComponent("/home/sth/\(location.identifier)/automation-device/R(1)/FvrBscOp/OccMod/@present-value") else {
      delegate?.thermostatDataAccessorFailedToFetchLocations()
      return
    }
    
    Alamofire.request(.GET, urlForOccupationMode, headers: headersForRequest)
      .responseJSON { response in
        switch response.result {
        case .Success:
          if let occupationModeString = response.result.value as? String
          {
            location.isOccupied = occupationModeString == "Present" ? true : false
            NSLog("location name: \(location.identifier) - isOccupied = \(location.isOccupied)")
          }
        case .Failure(let error):
          NSLog("Error fetching occupation mode: \(error.localizedDescription)")
          self.delegate?.thermostatDataAccessorFailedToFetchLocations()
        }
        self.outstandingRequestsForLocationFetchToFinish -= 1
    }
  }
  
  // MARK: - Fetch thermostat data
  
  private func fetchPresentValueOfPoint(point: String, forThermostat thermostat: Thermostat, successHandler: (presentValue: AnyObject) -> Void) {
    guard let headersForRequest = headerForAuthorizedAccess() else {
      delegate?.thermostatDataAccessorFailedToFetchThermostat()
      return
    }
    
    guard let urlForPresentValueOfPoint = NSURL(string: "\(baseURL)")?.URLByAppendingPathComponent("/home/sth/\(thermostat.identifier)/automation-device/R(1)/FvrBscOp/\(point)/@present-value") else {
      delegate?.thermostatDataAccessorFailedToFetchThermostat()
      return
    }
    
    Alamofire.request(.GET, urlForPresentValueOfPoint, headers: headersForRequest)
      .responseJSON { response in
        switch response.result {
        case .Success:
          if let presentValueOfPoint = response.result.value
          {
            successHandler(presentValue: presentValueOfPoint)
            NSLog("present value of \(point) = \(presentValueOfPoint)")
          }
        case .Failure(let error):
          NSLog("Error fetching occupation mode: \(error.localizedDescription)")
          self.delegate?.thermostatDataAccessorFailedToFetchLocations()
        }
    }
  }
  
  func fetchDataOfThermostat(thermostat: Thermostat) {
    fetchPresentValueOfPoint("CmfBtn", forThermostat: thermostat) { (presentValue) in
      if let thermostatIsInComfortMode = presentValue as? Bool {
        if thermostatIsInComfortMode == false {
          thermostat.isInAutoMode = true
        } else if thermostatIsInComfortMode == true {
          thermostat.isInAutoMode = false
        }
      }
    }
    
    fetchPresentValueOfPoint("RTemp", forThermostat: thermostat) { (presentValue) in
      if let currentTemperature = presentValue as? Int {
        thermostat.currentTemperature = currentTemperature
      }
    }
    
    fetchPresentValueOfPoint("SpTR", forThermostat: thermostat) { (presentValue) in
      if let temperatureSetPoint = presentValue as? Int {
        thermostat.temperatureSetPoint = temperatureSetPoint
      }
    }
  }
}