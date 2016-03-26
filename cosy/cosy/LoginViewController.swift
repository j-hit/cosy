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
  
  let segueIdentifierToShowThermostatsView = "showListOfThermostats"
  
  let authenticator = Authenticator()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    authenticator.delegate = self
    informationLabel.text = ""
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  @IBAction func signInButtonPressed(sender: AnyObject) {
    authenticator.performSignIn(withUsername: "james.bampoe@siemens.com", andPassword: "Test1234")
  }
}

extension LoginViewController: AuthenticatorDelegate {
  func authenticator(didRetrieveSessionID error: String) {
    performSegueWithIdentifier(segueIdentifierToShowThermostatsView, sender: nil)
  }
  
  func authenticator(didFailToAuthenticateWithError error: String) {
    dispatch_async(dispatch_get_main_queue()) {
      self.informationLabel.text = "Failed to sign in. Make sure your email address and password are correct and then try again."
      self.informationLabel.alpha = 0
      self.informationLabel.textColor = UIColor.redColor()
      
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
  }
}

