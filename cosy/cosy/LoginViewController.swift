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
  @IBOutlet weak var signInButton: UIButton!
  
  private let segueIdentifierToShowThermostatsView = "showListOfThermostats"
  
  private let authenticator = (UIApplication.sharedApplication().delegate as! AppDelegate).authenticator
  private let watchConnectivityHandler = (UIApplication.sharedApplication().delegate as! AppDelegate).watchConnectivityHandler
  
  override func viewWillAppear(animated: Bool) {
    self.signInButton.hidden = false
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
  
  @IBAction func signInButtonPressed(sender: UIButton) {
    if let emailAddress = emailTextField.text, password = passwordTextField.text where !emailAddress.isEmpty && !password.isEmpty  {
      authenticator.performSignIn(withUsername: emailAddress, andPassword: password)
      saveLastUsed(emailAddress: emailAddress, andPassword: password)
      sender.hidden = true
    } else {
      showInformation(NSLocalizedString("SignInCredentialIncomplete", comment: "Information: Email address or password missing"), withColor: UIColor.redColor())
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
  func authenticator(didRetrieveSessionID sessionID: String) {
    performSegueWithIdentifier(segueIdentifierToShowThermostatsView, sender: nil)
  }
  
  func authenticator(didFailToAuthenticateWithError error: String) {
    self.signInButton.hidden = false
    showInformation(error, withColor: UIColor.redColor())
  }
  
  func authenticatorDidPerformSignOut() {
    watchConnectivityHandler.transferApplicationSettingsToWatch()
  }
}

