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
  
  private var lastDataFetchWasFaulty = false {
    didSet {
      if lastDataFetchWasFaulty == true {
        showErrorIndication()
      } else if lastDataFetchWasFaulty == false && oldValue == true {
        removeErrorIndication()
      }
    }
  }
  
  // MARK: - Lifecycle methods
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    
    thermostatManager = watchDelegate.thermostatManager
    thermostatManager?.delegate = self
    
    reloadDataShownOnView()
  }
  
  override func willActivate() {
    super.willActivate()
    
    watchDelegate.watchConnectivityHandler.delegate = self
    watchDelegate.appIsActive = true
    tryToFetchNewData()
    checkIfDataWasRetrievedFromiPhoneInTheBackground()
  }
  
  override func didDeactivate() {
    super.didDeactivate()
  }
  
  // MARK: - Table view specific methods
  
  override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
    if segueIdentifier == segueIdentifierToShowThermostat {
      if let row = table.rowControllerAtIndex(rowIndex) as? ThermostatRowController {
        return row.thermostat
      }
    }
    return nil
  }
  
  override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
    if let _ = table.rowControllerAtIndex(rowIndex) as? ErrorRowController {
      let errorMessage = NSLocalizedString("ErrorFetchingListOfThermostats", comment: "Message shown to the user when an error occurs while fetching the list of thermostats")
      watchDelegate.watchConnectivityHandler.transmitErrorToiPhone(errorMessage, completionHander: {
        self.presentControllerWithName(ErrorInterfaceController.identifier, context: errorMessage)
      })
    }
  }
  
  // MARK: - Reloading data on view
  
  private func checkIfDataWasRetrievedFromiPhoneInTheBackground() {
    if(userHasBeenAuthenticated && thermostatManager?.thermostats.count > 0) {
      if let _ = thermostatsTable.rowControllerAtIndex(0) as? InformationRowController {
        reloadDataShownOnView()
      }
    }
  }
  
  private func showAllThermostats(fromThermostatManager thermostatManager: ThermostatManager) {
    clearThermostatsTable()
    let sortedThermostats = thermostatManager.thermostats.sort { $0.name < $1.name }
    
    let rows = thermostatsTable.numberOfRows
    let thermostatRows = NSIndexSet(indexesInRange: NSRange(location: rows, length: sortedThermostats.count))
    thermostatsTable.insertRowsAtIndexes(thermostatRows, withRowType: ThermostatRowController.identifier)
    
    for rowIndex in rows..<thermostatsTable.numberOfRows {
      let row = thermostatsTable.rowControllerAtIndex(rowIndex)
      
      if let row = row as? ThermostatRowController {
        let thermostat = sortedThermostats[rowIndex]
        row.thermostatLabel.setText(thermostat.name)
        row.occupationModeImage.setImageNamed(thermostat.occupationModeimageName)
        row.thermostat = thermostat
      }
    }
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
  
  private func showErrorIndication() {
    guard thermostatsTable.rowControllerAtIndex(0) as? ErrorRowController == nil else {
      return
    }
    thermostatsTable.insertRowsAtIndexes(NSIndexSet(indexesInRange: NSRange(location: 0, length: 1)), withRowType: ErrorRowController.identifier)
  }
  
  private func removeErrorIndication() {
    if let _ = thermostatsTable.rowControllerAtIndex(0) as? ErrorRowController {
      thermostatsTable.removeRowsAtIndexes(NSIndexSet(indexesInRange: NSRange(location: 0, length: 1)))
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
      if thermostatManager?.thermostats.count == 0 {
        showLoadingDataMessage()
      }
      thermostatManager?.fetchNewListOfThermostats()
    } else {
      thermostatManager?.clearAllData()
      showAuthenticationRequiredMessage()
    }
  }
}

// MARK: - WatchAppWatchConnectivityHandlerDelegate
extension ThermostatsTableInterfaceController: WatchAppWatchConnectivityHandlerDelegate {
  func didUpdateApplicationSettings() {
    if watchDelegate.appIsActive {
      tryToFetchNewData()
    }
  }
}

// MARK: - ThermostatManagerDelegate
extension ThermostatsTableInterfaceController: ThermostatManagerDelegate {
  func didUpdateListOfThermostats() {
    if watchDelegate.appIsActive {
      dispatch_async(dispatch_get_main_queue()) {
        self.reloadDataShownOnView()
      }
    }
    lastDataFetchWasFaulty = false
  }
  
  func didFailToRetrieveData(withError error: String) {
    lastDataFetchWasFaulty = true
    WKInterfaceDevice.currentDevice().playHaptic(.Retry)
  }
}
