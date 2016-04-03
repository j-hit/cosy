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
  
  let baseURL = ApplicationSettingsManager.sharedInstance.baseURLOfCPSCloud
  
  var lastFetchedLocations = [ThermostatLocation]()
  
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
  
  func fetchDataOfThermostat(withIdentifier identifier: String) -> Thermostat? {
    return nil
  }
  
  func fetchAvailableLocationsWithThermostatNames() {
    performRequestToFetchListOfLocations() // TODO: don't get pass through
  }
  
  private func performRequestToFetchListOfLocations() {
    guard let headersForRequest = headerForFetchingListOfLocations() else {
      return
    }
    
    guard let urlForLocations = NSURL(string: "\(baseURL)")?.URLByAppendingPathComponent("/home/sth") else {
      return
    }
    
    Alamofire.request(.GET, urlForLocations, headers: headersForRequest)
      .responseJSON { response in
        switch response.result {
        case .Success:
          if let locations = response.result.value as? [[String: String]]
          {
            self.lastFetchedLocations.removeAll()
            self.outstandingRequestsForLocationFetchToFinish = locations.count
            
            for location in locations {
              if let locationIdentifier = location["name"] {
                let fetchedLocation = ThermostatLocation(identifier: locationIdentifier)
                self.lastFetchedLocations.append(fetchedLocation)
                self.fetchNameForLocation(fetchedLocation)
                NSLog("location key: \(locationIdentifier)")
              } else {
                // TODO: Inform about error
              }
            }
          }
        case .Failure(let error):
          NSLog("Error fetching locations: \(error.localizedDescription)")
          // inform delegate
        }
    }
  }
  
  private func fetchNameForLocation(location: ThermostatLocation) {
    guard let headersForRequest = headerForFetchingListOfLocations() else {
      return
    }
    
    let baseURL = ApplicationSettingsManager.sharedInstance.baseURLOfCPSCloud
    
    guard let urlForLocationName = NSURL(string: "\(baseURL)")?.URLByAppendingPathComponent("/home/sth/\(location.identifier)") else {
      return
    }
    
    Alamofire.request(.GET, urlForLocationName, headers: headersForRequest, parameters: ["properties": "object-name,description"])
      .responseJSON { response in
        switch response.result {
        case .Success:
          if let JSONResponse = response.result.value, locationName = JSONResponse["object-name"] as? String, thermostatName = JSONResponse["description"] as? String
          {
            location.locationName = locationName
            location.addThermostat(Thermostat(name: thermostatName))
            NSLog("location name: \(locationName) - thermostat name: \(thermostatName)")
          }
        case .Failure(let error):
          NSLog("Error fetching location name: \(error.localizedDescription)")
        }
        self.outstandingRequestsForLocationFetchToFinish--
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