//
//  ThermostatsTableViewController.swift
//  cosy
//
//  Created by James Bampoe on 26/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import UIKit

class ThermostatsTableViewController: UITableViewController {
  
  private let thermostatCellIdentifier = "ThermostatTableViewCell"
  
  private let authenticator = (UIApplication.sharedApplication().delegate as! AppDelegate).authenticator
  private let watchConnectivityHandler = (UIApplication.sharedApplication().delegate as! AppDelegate).watchConnectivityHandler
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    authenticator.delegate = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 3
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1 // Current limitation of 1 thermostat pro location
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(thermostatCellIdentifier, forIndexPath: indexPath)
    return cell
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    var titleForHeader = ""
    switch section {
    case 0:
      titleForHeader = "Home"
    case 1:
      titleForHeader = "Office"
    case 2:
      titleForHeader = "Country cottage"
    default:
      break
    }
    
    return titleForHeader
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
