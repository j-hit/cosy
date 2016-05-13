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
  var lastFetchedThermostats: [Thermostat]
  
  init(settingsProvider: SettingsProvider) {
    self.settingsProvider = settingsProvider
    self.lastFetchedThermostats = [Thermostat]()
  }
  
  var outstandingRequestsForThermostatListFetchToFinish: Int = 0 {
    didSet {
      if outstandingRequestsForThermostatListFetchToFinish == 0 {
        delegate?.thermostatDataAccessor(didFetchThermostats: lastFetchedThermostats)
      } else if outstandingRequestsForThermostatListFetchToFinish < 0 {
        NSLog("ERROR: outstandingRequestsForLocationFetchToFinish should not have minus value")
        outstandingRequestsForThermostatListFetchToFinish = 0
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
    
  func fetchListOfThermostats() {
    guard let headersForRequest = headerForAuthorizedAccess() else {
      delegate?.thermostatDataAccessorFailedToListOfThermostats()
      return
    }
    
    guard let urlForLocations = NSURL(string: "\(baseURL)")?.URLByAppendingPathComponent("/home/sth") else {
      delegate?.thermostatDataAccessorFailedToListOfThermostats()
      return
    }
    
    Alamofire.request(.GET, urlForLocations, headers: headersForRequest)
      .responseJSON { response in
        switch response.result {
        case .Success:
          if let locations = response.result.value as? [[String: String]]
          {
            self.lastFetchedThermostats.removeAll()
            self.outstandingRequestsForThermostatListFetchToFinish = locations.count * 4
            
            for location in locations {
              if let identifier = location["activation-key"] {
                let fetchedThermostat = Thermostat(identifier: identifier)
                self.lastFetchedThermostats.append(fetchedThermostat)
                
                self.fetchNameOfThermostat(fetchedThermostat)
                self.fetchOccupationModeOfThermostat(fetchedThermostat, completionHandler: { 
                  self.outstandingRequestsForThermostatListFetchToFinish -= 1
                })
                self.fetchTemperatureSetpointOfThermostat(fetchedThermostat, completionHandler: { 
                  self.outstandingRequestsForThermostatListFetchToFinish -= 1
                })
                self.fetchCurrentTemperatureOfThermostat(fetchedThermostat, completionHandler: { 
                  self.outstandingRequestsForThermostatListFetchToFinish -= 1
                })
                NSLog("thermostat key: \(identifier)")
              } else {
                self.outstandingRequestsForThermostatListFetchToFinish -= 1
              }
            }
          }
        case .Failure(let error):
          NSLog("Error fetching locations: \(error.localizedDescription)")
          self.delegate?.thermostatDataAccessorFailedToListOfThermostats()
        }
    }
  }
  
  private func fetchNameOfThermostat(thermostat: Thermostat) {
    guard let headersForRequest = headerForAuthorizedAccess() else {
      delegate?.thermostatDataAccessorFailedToListOfThermostats()
      return
    }
    
    guard let urlForLocationName = NSURL(string: "\(baseURL)")?.URLByAppendingPathComponent("/home/sth/\(thermostat.identifier)/@location") else {
      delegate?.thermostatDataAccessorFailedToListOfThermostats()
      return
    }
    
    Alamofire.request(.GET, urlForLocationName, headers: headersForRequest)
      .responseString { response in
        switch response.result {
        case .Success:
          print("thermostat name fetch response: \(response.result.value)")
          if let thermostatName = response.result.value
          {
            thermostat.name = thermostatName
            NSLog("thermostat name: \(thermostatName)")
          }
        case .Failure(let error):
          NSLog("Error fetching location name: \(error.localizedDescription)")
          self.delegate?.thermostatDataAccessorFailedToListOfThermostats()
        }
        self.outstandingRequestsForThermostatListFetchToFinish -= 1
    }
  }
  
  // MARK: - Fetch thermostat data
  
  private func fetchPresentValueOfPoint(point: String, forThermostat thermostat: Thermostat, successHandler: (presentValue: AnyObject) -> Void, errorHandler: ((error: NSError) -> Void)? = nil) {
    guard let headersForRequest = headerForAuthorizedAccess() else {
      thermostat.delegate?.didFailToChangeData(withError: NSLocalizedString("FetchPresentValueHeaderFailure", comment: "Error: Failed to construct header for authorized access"))
      return
    }
    
    guard let urlForPresentValueOfPoint = NSURL(string: "\(baseURL)")?.URLByAppendingPathComponent("/home/sth/\(thermostat.identifier)/automation-device/R(1)/FvrBscOp/\(point)/@present-value") else {
      thermostat.delegate?.didFailToRetrieveData(withError: String(format: NSLocalizedString("FetchPresentValueURLFailure", comment: "Error: Failed to construct URL for fetching present value"), point))
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
          errorHandler?(error: error)
          NSLog("Error fetching occupation mode: \(error.localizedDescription)")
          thermostat.delegate?.didFailToRetrieveData(withError: String(format: NSLocalizedString("FetchPresentValueFailure", comment: "Error retrieving present value"), point, error.localizedDescription))
        }
    }
  }
  
  private func fetchCurrentTemperatureOfThermostat(thermostat: Thermostat, completionHandler: (() -> Void)? = nil) {
    fetchPresentValueOfPoint("RTemp", forThermostat: thermostat, successHandler: { (presentValue) in
      if let currentTemperature = presentValue as? Int {
        thermostat.currentTemperature = currentTemperature
      }
      completionHandler?()
      }, errorHandler: { (error) in
        completionHandler?()
    })
  }
  
  private func fetchTemperatureSetpointOfThermostat(thermostat: Thermostat, completionHandler: (() -> Void)? = nil) {
    fetchPresentValueOfPoint("SpTR", forThermostat: thermostat, successHandler: { (presentValue) in
      if let temperatureSetPoint = presentValue as? Int {
        thermostat.temperatureSetPoint = temperatureSetPoint
      }
      completionHandler?()
      }, errorHandler: { (error) in
        completionHandler?()
    })
  }
  
  private func fetchOccupationModeOfThermostat(thermostat: Thermostat, completionHandler: (() -> Void)? = nil) {
    fetchPresentValueOfPoint("OccMod", forThermostat: thermostat, successHandler: { (presentValue) in
      if let occupationModeString = presentValue as? String {
        thermostat.isOccupied = occupationModeString == "Present" ? true : false
      }
      completionHandler?()
      }, errorHandler: { (error) in
        completionHandler?()
    })
  }
  
  func fetchDataOfThermostat(thermostat: Thermostat) {
    fetchCurrentTemperatureOfThermostat(thermostat)
    
    fetchTemperatureSetpointOfThermostat(thermostat)
    
    fetchOccupationModeOfThermostat(thermostat)
    
    fetchPresentValueOfPoint("CmfBtn", forThermostat: thermostat, successHandler: { (presentValue) in
      if let thermostatIsInComfortMode = presentValue as? Bool {
        if thermostatIsInComfortMode == false {
          thermostat.isInAutoMode = true
        } else if thermostatIsInComfortMode == true {
          thermostat.isInAutoMode = false
        }
      }
    })
  }
  
  // MARK: - Change thermostat data
  
  func setPresentValueOfPoint(point: String, forThermostat thermostat: Thermostat, toValue value: AnyObject) {
    guard let url = URLForChangingPresentValue(ofPoint: point, forThermostat: thermostat),
      urlRequest = URLRequestForChangingPresentValueOfPoint(withURL: url, toValue: value) else {
        thermostat.delegate?.didFailToRetrieveData(withError: NSLocalizedString("SetPresentValueURLFailure", comment: "Error constructing url for changing the temperature set point"))
        return
    }
    
    thermostat.savingData = true
    
    Alamofire.request(urlRequest)
      .validate()
      .responseString { response in
        switch response.result {
        case .Success:
          NSLog("Changed point \(point) of thermostat \(thermostat.name) to \(value)")
        case .Failure(let error):
          NSLog("Error changing point \(point) of thermostat \(thermostat.identifier). Details = \(error.localizedDescription)")
          thermostat.delegate?.didFailToChangeData(withError: String(format: NSLocalizedString("SetPresentValueFailure", comment: "Error changing the temperature set point"), thermostat.name, error.localizedDescription))
        }
        thermostat.savingData = false
    }
  }
  
  private func URLForChangingPresentValue(ofPoint point: String, forThermostat thermostat: Thermostat) -> NSURL?{
    return NSURL(string: "\(baseURL)")?.URLByAppendingPathComponent("/home/sth/\(thermostat.identifier)/automation-device/R(1)/FvrBscOp/\(point)")
  }
  
  private func URLRequestForChangingPresentValueOfPoint(withURL url: NSURL, toValue value: AnyObject) -> NSURLRequest?{
    guard let sessionID = settingsProvider.sessionID else {
      return nil
    }
    
    let bodyForChangingPresentValue = [
      "present-value" : value
    ]
    
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Session \(sessionID)", forHTTPHeaderField: "Authorization")
    request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(bodyForChangingPresentValue, options: [])
    return request
  }
}