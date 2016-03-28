//
//  ViewController.swift
//  cosy
//
//  Created by James Bampoe on 05/03/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var informationLabel: UILabel!
  
  private let segueIdentifierToShowThermostatsView = "showListOfThermostats"
  
  let authenticator = (UIApplication.sharedApplication().delegate as! AppDelegate).authenticator
  let watchConnectivityHandler = (UIApplication.sharedApplication().delegate as! AppDelegate).watchConnectivityHandler
  
  override func viewWillAppear(animated: Bool) {
    reloadLastUsedEmailAddressAndPassword()
    authenticator.delegate = self
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    informationLabel.text = ""
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  @IBAction func signInButtonPressed(sender: AnyObject) {
    if let emailAddress = emailTextField.text, password = passwordTextField.text where !emailAddress.isEmpty && !password.isEmpty  {
      authenticator.performSignIn(withUsername: emailAddress, andPassword: password)
      saveLastUsed(emailAddress: emailAddress, andPassword: password)
    } else {
      showInformation("Fill in email address and password", withColor: UIColor.redColor())
    }
  }
  
  private func showInformation(information: String, withColor color: UIColor) {
    self.informationLabel.text = information
    self.informationLabel.alpha = 0
    self.informationLabel.textColor = color
    
    UIView.animateWithDuration(2.0, animations: { () -> Void in
      self.informationLabel.alpha = 1
      }, completion: { (_) -> Void in
        UIView.animateWithDuration(2.5, animations: { () -> Void in
          self.informationLabel.alpha = 0
          }, completion: { (_) -> Void in
            self.informationLabel.text = ""
        })
    })
  }
  
  private func saveLastUsed(emailAddress emailAddress: String, andPassword password: String) {
    ApplicationSettingsManager.sharedInstance.lastUsedEmailAddress = emailAddress
    ApplicationSettingsManager.sharedInstance.lastUsedPassword = password
  }
  
  private func reloadLastUsedEmailAddressAndPassword() {
    emailTextField.text = ApplicationSettingsManager.sharedInstance.lastUsedEmailAddress
    passwordTextField.text = ApplicationSettingsManager.sharedInstance.lastUsedPassword
  }
}

extension LoginViewController: AuthenticatorDelegate {
  func authenticator(didRetrieveSessionID error: String) {
    performSegueWithIdentifier(segueIdentifierToShowThermostatsView, sender: nil)
    watchConnectivityHandler.transferApplicationSettingsToWatch()
  }
  
  func authenticator(didFailToAuthenticateWithError error: String) {
    //"Failed to sign in. Make sure your email address and password are correct and then try again."
    showInformation(error, withColor: UIColor.redColor())
  }
  
  func authenticatorDidPerformSignOut() {
    watchConnectivityHandler.transferApplicationSettingsToWatch()
  }
}

