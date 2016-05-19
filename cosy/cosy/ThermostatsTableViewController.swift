//
//  ThermostatsTableViewController.swift
//  cosy
//
//  Created by James Bampoe on 26/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import UIKit

class ThermostatsTableViewController: UITableViewController {
  
  @IBOutlet weak var signOutButton: UIBarButtonItem!
  
  private let authenticator = (UIApplication.sharedApplication().delegate as! AppDelegate).authenticator
  private let watchConnectivityHandler = (UIApplication.sharedApplication().delegate as! AppDelegate).watchConnectivityHandler
  let thermostatManager = (UIApplication.sharedApplication().delegate as! AppDelegate).thermostatManager
  
  private var thermostats = [Thermostat]() {
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
    thermostatManager.fetchNewListOfThermostats()
    watchConnectivityHandler.delegate = self
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return thermostats.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(ThermostatTableViewCell.identifier, forIndexPath: indexPath) as! ThermostatTableViewCell
    let thermostat = thermostats[indexPath.row]
    cell.thermostatNameLabel.text = thermostat.name
    return cell
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

// MARK: - AuthenticatorDelegate
extension ThermostatsTableViewController: AuthenticatorDelegate {
  func authenticator(didRetrieveSessionID sessionID: String) {
  }
  
  func authenticator(didFailToAuthenticateWithError error: String) {
  }
  
  func authenticatorDidPerformSignOut() {
    thermostatManager.clearAllData()
    thermostats.removeAll()
    watchConnectivityHandler.transferApplicationSettingsToWatch()
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}

// MARK: - ThermostatManagerDelegate
extension ThermostatsTableViewController: ThermostatManagerDelegate {
  func didUpdateListOfThermostats() {
    thermostats = thermostatManager.thermostats
    watchConnectivityHandler.transferAppContextToWatch(withDataFromThermostatManager: thermostatManager)
  }
  
  func didFailToRetrieveData(withError error: String) {
  }
}

// MARK: - iPhoneWatchConnectivityHandlerDelegate
extension ThermostatsTableViewController: iPhoneWatchConnectivityHandlerDelegate {
  func didReceiveErrorMessageFromWatch(error: String) {
    let alertController = UIAlertController(title: "Error from watch app", message: error, preferredStyle: .Alert)
    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alertController.addAction(defaultAction)
    presentViewController(alertController, animated: true, completion: nil)
  }
}
