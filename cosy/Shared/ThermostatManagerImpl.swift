//
//  ThermostatManagerImpl.swift
//  cosy
//
//  Created by James Bampoe on 01/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation
import Alamofire

final class ThermostatManagerImpl: ThermostatManager {
  var delegate: ThermostatManagerDelegate?
  var thermostatLocations: [ThermostatLocation]
  private (set) var state: ThermostatManagerState
  
  init() {
    thermostatLocations = [ThermostatLocation]()
    state = ThermostatManagerState.Ready
  }
  
  func reloadData() {
    guard state == ThermostatManagerState.Ready else {
      return
    }
    
    performRequestToFetchListOfLocations()
  }
  
  private func performRequestToFetchListOfLocations() {
    guard let headersForRequest = headerForFetchingListOfLocations() else {
      return
    }
    
    let baseURL = ApplicationSettingsManager.sharedInstance.baseURLOfCPSCloud
    
    guard let urlForLocations = NSURL(string: "\(baseURL)")?.URLByAppendingPathComponent("/home/sth") else {
      return
    }
    
    state = ThermostatManagerState.ExpectingNewData
    
    Alamofire.request(.GET, urlForLocations, headers: headersForRequest)
      .responseJSON { response in
        switch response.result {
        case .Success:
          if let JSONResponse = response.result.value as? [[String: String]]
          {
            self.thermostatLocations.removeAll()
            for location in JSONResponse {
              if let locationIdentifier = location["name"] {
                self.fetchNameOfLocation(withIdentifier: locationIdentifier)
                print("location key: \(locationIdentifier)")
              }
            }
            //self.delegate?.didUpdateListOfThermostats() // TODO: do when all subcalls have finished and merge data
            self.state = ThermostatManagerState.Ready // TODO: Set after all subcalls have finished
          }
        case .Failure(let error):
          print("Error fetching locations: \(error.localizedDescription)")
        }
        self.state = ThermostatManagerState.Ready
    }
  }
  
  private func fetchNameOfLocation(withIdentifier identifier: String) {
    guard let headersForRequest = headerForFetchingListOfLocations() else {
      return
    }
    
    let baseURL = ApplicationSettingsManager.sharedInstance.baseURLOfCPSCloud
    
    guard let urlForLocationName = NSURL(string: "\(baseURL)")?.URLByAppendingPathComponent("/home/sth/\(identifier)") else {
      return
    }
    
    Alamofire.request(.GET, urlForLocationName, headers: headersForRequest, parameters: ["properties": "object-name,description"])
      .responseJSON { response in
        switch response.result {
        case .Success:
          if let JSONResponse = response.result.value, locationName = JSONResponse["object-name"] as? String, thermostatName = JSONResponse["description"] as? String
          {
            let location = ThermostatLocation(identifier: identifier, locationName: locationName)
            location.addThermostat(Thermostat(name: thermostatName))
            self.thermostatLocations.append(location)
            
            print("location name: \(locationName) - thermostat name: \(thermostatName)")
            self.delegate?.didUpdateListOfThermostats() // TODO: Optimise
          }
        case .Failure(let error):
          print("Error fetching location name: \(error.localizedDescription)")
        }
    }
  }
  
  private func headerForFetchingListOfLocations() -> [String: String]? {
    guard let sessionID = ApplicationSettingsManager.sharedInstance.sessionID else {
      return nil
    }
    
    return [
      "Authorization": "Session \(sessionID)",
      "Content-Type": "application/json"
    ]
  }
}