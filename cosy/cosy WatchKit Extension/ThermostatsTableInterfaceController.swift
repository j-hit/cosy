//
//  InterfaceController.swift
//  cosy WatchKit Extension
//
//  Created by James Bampoe on 05/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import WatchKit
import Foundation

class ThermostatsTableInterfaceController: WKInterfaceController {
  @IBOutlet var thermostatsTable: WKInterfaceTable!
  
  @IBOutlet var informationLabel: WKInterfaceLabel!
  
  private let segueIdentifierToShowThermostat = "showThermostat"
  
  private let watchDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
  
  private var thermostatManager: ThermostatManager?
  
  private var settingsProvider: SettingsProvider {
    return ExtensionDelegate.settingsProvider
  }
  
  private var userHasBeenAuthenticated: Bool {
    if let _ = settingsProvider.sessionID {
      return true
    } else {
      return false
    }
  }
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    watchDelegate.watchConnectivityHandler.delegate = self
    
    thermostatManager = watchDelegate.thermostatManager
    thermostatManager?.delegate = self
    
    reloadDataShownOnView()
  }
  
  override func willActivate() {
    super.willActivate()
    
    watchDelegate.appIsActive = true
    
    tryToFetchNewData()
    checkIfDataWasRetrievedFromiPhoneInTheBackground()
  }
  
  override func didDeactivate() {
    super.didDeactivate()
  }
  
  private func checkIfDataWasRetrievedFromiPhoneInTheBackground() {
    if(userHasBeenAuthenticated && thermostatManager?.thermostatLocations.count > 0) {
      if let _ = thermostatsTable.rowControllerAtIndex(0) as? InformationRowController {
        reloadDataShownOnView()
      }
    }
  }
  
  private func showAllThermostats(fromThermostatManager thermostatManager: ThermostatManager) {
    clearThermostatsTable()
    let sortedLocations = thermostatManager.thermostatLocations.sort { $0.locationName < $1.locationName }
    for thermostatLocation in sortedLocations {
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
        let thermostat = thermostatsOfSpecifiedLocation[rowIndex - rows - 1]
        row.thermostatLabel.setText(thermostat.name)
        row.thermostat = thermostat
      }
    }
  }
  
  override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
    if segueIdentifier == segueIdentifierToShowThermostat {
      if let row = table.rowControllerAtIndex(rowIndex) as? ThermostatRowController {
        return row.thermostat
      }
    }
    return nil
  }
  
  private func showAuthenticationRequiredMessage() {
    clearThermostatsTable()
    thermostatsTable.setNumberOfRows(1, withRowType: InformationRowController.identifier)
    if let controller = thermostatsTable.rowControllerAtIndex(0) as? InformationRowController {
      controller.informationLabel.setText(NSLocalizedString("SignInRequiredInformation", comment: "informs the user that a sign in with the counterpart iOS app is required"))
    }
  }
  
  private func showLoadingDataMessage() {
    clearThermostatsTable()
    thermostatsTable.setNumberOfRows(1, withRowType: InformationRowController.identifier)
    if let controller = thermostatsTable.rowControllerAtIndex(0) as? InformationRowController {
      controller.informationLabel.setText(NSLocalizedString("LoadingDataInformation", comment: "informs the user data is being loaded"))
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
    } else {
      showAuthenticationRequiredMessage()
    }
  }
  
  private func tryToFetchNewData() {
    if(userHasBeenAuthenticated) {
      if thermostatManager?.thermostatLocations.count == 0 {
        showLoadingDataMessage()
      }
      thermostatManager?.fetchNewData()
    } else {
      thermostatManager?.clearAllData()
      showAuthenticationRequiredMessage()
    }
  }
}

extension ThermostatsTableInterfaceController: WatchAppWatchConnectivityHandlerDelegate {
  func didUpdateApplicationSettings() {
    if watchDelegate.appIsActive {
      tryToFetchNewData()
    }
  }
}

extension ThermostatsTableInterfaceController: ThermostatManagerDelegate {
  func didUpdateListOfThermostats() {
    if watchDelegate.appIsActive {
      reloadDataShownOnView()
    }
  }
}
