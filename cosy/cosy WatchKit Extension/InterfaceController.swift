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
  
  let watchDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
  let thermostatManager = ThermostatManager()
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    watchDelegate.watchConnectivityHandler.delegate = self
    
    for thermostatLocation in thermostatManager.thermostatLocations {
      loadThermostats(fromThermostatLocation: thermostatLocation)
    }
  }
  
  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
    reloadSessionID()
  }
  
  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }
  
  private func loadThermostats(fromThermostatLocation thermostatLocation: ThermostatLocation) {
    let thermostatsOfSpecifiedLocation = thermostatLocation.thermostats
    let rows = thermostatsTable.numberOfRows
    let headerIndex = NSIndexSet(index: rows)
    thermostatsTable.insertRowsAtIndexes(headerIndex, withRowType: "LocationRow")
    
    let thermostatRows = NSIndexSet(indexesInRange: NSRange(location: rows + 1, length: thermostatsOfSpecifiedLocation.count))
    thermostatsTable.insertRowsAtIndexes(thermostatRows, withRowType: "ThermostatRow")
    
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
  
  private func reloadSessionID() {
    if let sessionID = ApplicationSettingsManager.sharedInstance.sessionID {
      informationLabel.setText("sessionID = \(sessionID)")
    } else {
      informationLabel.setText("no sessionID found")
    }
  }
}

extension InterfaceController: WatchAppWatchConnectivityHandlerDelegate {
  func didUpdateApplicationSettings() {
    reloadSessionID()
  }
}
