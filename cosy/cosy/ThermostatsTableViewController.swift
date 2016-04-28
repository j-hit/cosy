//
//  ThermostatsTableViewController.swift
//  cosy
//
//  Created by James Bampoe on 26/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import UIKit

class ThermostatsTableViewController: UITableViewController {
  
  private let authenticator = (UIApplication.sharedApplication().delegate as! AppDelegate).authenticator
  private let watchConnectivityHandler = (UIApplication.sharedApplication().delegate as! AppDelegate).watchConnectivityHandler
  private let thermostatManager = (UIApplication.sharedApplication().delegate as! AppDelegate).thermostatManager
  
  private var thermostatLocations = [ThermostatLocation]() {
    didSet {
      tableView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    thermostatManager.delegate = self
    authenticator.delegate = self
  }
  
  override func viewWillAppear(animated: Bool) {
    thermostatManager.fetchNewData()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return thermostatLocations.count
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return thermostatLocations[section].thermostats.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(ThermostatTableViewCell.identifier, forIndexPath: indexPath) as! ThermostatTableViewCell
    let thermostat = thermostatLocations[indexPath.section].thermostats[indexPath.row]
    cell.thermostatNameLabel.text = thermostat.name
    return cell
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return thermostatLocations[section].locationName
  }
  
  override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 44.0
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  @IBAction func signOutPressed(sender: AnyObject) {
    authenticator.performSignOut()
  }
}

extension ThermostatsTableViewController: AuthenticatorDelegate {
  func authenticator(didRetrieveSessionID sessionID: String) {
    // TODO: Reload table
  }
  
  func authenticator(didFailToAuthenticateWithError error: String) {
    // TODO: Show information
  }
  
  func authenticatorDidPerformSignOut() {
    watchConnectivityHandler.transferApplicationSettingsToWatch()
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}

extension ThermostatsTableViewController: ThermostatManagerDelegate {
  func didUpdateListOfThermostats() {
    thermostatLocations = thermostatManager.thermostatLocations
    watchConnectivityHandler.transferAppContextToWatch(withDataFromThermsotatManager: thermostatManager)
  }
  
  func didFailToRetrieveData(withError error: String) {
    // TODO: Show information
  }
}
