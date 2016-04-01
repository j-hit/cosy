//
//  InterfaceController.swift
//  cosy WatchKit Extension
//
//  Created by James Bampoe on 05/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
  @IBOutlet var thermostatsTable: WKInterfaceTable!
  
  @IBOutlet var informationLabel: WKInterfaceLabel!
  
  private let watchDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
  
  var thermostatManager: ThermostatManager?
  
  private var userHasBeenAuthenticated: Bool {
    if let _ = ApplicationSettingsManager.sharedInstance.sessionID {
      return true
    } else {
      return false
    }
  }
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    watchDelegate.watchConnectivityHandler.delegate = self
    
    // TODO: If session ID is found then initiate search on thermostatManager
    
    thermostatManager = watchDelegate.thermostatManager
    thermostatManager?.delegate = self
  }
  
  override func willActivate() {
    super.willActivate()
    reloadDataShownOnView()
    thermostatManager?.reloadData()
  }
  
  override func didDeactivate() {
    super.didDeactivate()
  }
  
  private func showAllThermostats(fromThermostatManager thermostatManager: ThermostatManager) {
    clearThermostatsTable()
    for thermostatLocation in thermostatManager.thermostatLocations {
      showThermostats(fromThermostatLocation: thermostatLocation)
    }
  }
  
  private func showThermostats(fromThermostatLocation thermostatLocation: ThermostatLocation) {
    let thermostatsOfSpecifiedLocation = thermostatLocation.thermostats
    let rows = thermostatsTable.numberOfRows
    let headerIndex = NSIndexSet(index: rows)
    thermostatsTable.insertRowsAtIndexes(headerIndex, withRowType: LocationRowController.identifier)
    
    let thermostatRows = NSIndexSet(indexesInRange: NSRange(location: rows + 1, length: thermostatsOfSpecifiedLocation.count))
    thermostatsTable.insertRowsAtIndexes(thermostatRows, withRowType: ThermostatRowController.identifier)
    
    for rowIndex in rows..<thermostatsTable.numberOfRows {
      let row = thermostatsTable.rowControllerAtIndex(rowIndex)
      
      if let row = row as? LocationRowController {
        row.locationLabel.setText(thermostatLocation.locationName)
        row.locationStateImage.setImageNamed(thermostatLocation.imageName)
      } else if let row = row as? ThermostatRowController {
        row.thermostatLabel.setText(thermostatsOfSpecifiedLocation[rowIndex - rows - 1].name)
      }
    }
  }
  
  private func showAuthenticationRequiredMessage() {
    clearThermostatsTable()
    thermostatsTable.setNumberOfRows(1, withRowType: InformationRowController.identifier)
    if let controller = thermostatsTable.rowControllerAtIndex(0) as? InformationRowController {
      controller.informationLabel.setText("Sign in with the cosy app on your iPhone") // TODO: Use localised string
    }
  }
  
  private func clearThermostatsTable() {
    thermostatsTable.removeRowsAtIndexes(NSIndexSet(indexesInRange: NSRange(location: 0, length: thermostatsTable.numberOfRows)))
  }
  
  private func reloadDataShownOnView() {
    guard let thermostatManager = thermostatManager else {
      return
    }
    
    if(userHasBeenAuthenticated) {
      showAllThermostats(fromThermostatManager: thermostatManager)
      if let sessionID = ApplicationSettingsManager.sharedInstance.sessionID {
        informationLabel.setText("sessionID = \(sessionID)") // TEST
      }
    } else {
      showAuthenticationRequiredMessage()
      informationLabel.setText("no sessionID found")
    }
  }
}

extension InterfaceController: WatchAppWatchConnectivityHandlerDelegate {
  func didUpdateApplicationSettings() {
    reloadDataShownOnView()
    if(userHasBeenAuthenticated) {
      thermostatManager?.reloadData()
    }
  }
}

extension InterfaceController: ThermostatManagerDelegate {
  func didUpdateListOfThermostats() {
    reloadDataShownOnView()
  }
}
