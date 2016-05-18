//
//  LoginViewControllerTests.swift
//  cosy
//
//  Created by James Bampoe on 19/05/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import XCTest
@testable import cosy

class LoginViewControllerTests: XCTestCase {
  
  var viewController: LoginViewController!
  
  override func setUp() {
    super.setUp()
    ApplicationSettingsManager.sharedInstance.mockModeEnabled = true
    
    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    viewController = storyboard.instantiateViewControllerWithIdentifier("LoginView") as! LoginViewController
    viewController.loadView()
    viewController.authenticator.delegate = viewController
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testSignIn() {
    viewController.emailTextField.text = "a@b.c"
    viewController.passwordTextField.text = "Abcd1234!"
    viewController.signInButtonPressed(viewController.signInButton)
    XCTAssertTrue(viewController.signInButton.hidden == true)
  }
  
  func testPasswordMissing() {
    viewController.emailTextField.text = "a@b.c"
    viewController.passwordTextField.text = ""
    viewController.signInButtonPressed(viewController.signInButton)
    XCTAssertFalse(viewController.informationLabel.text!.isEmpty)
  }
  
  func testEmailMissing() {
    viewController.emailTextField.text = ""
    viewController.passwordTextField.text = "Abcd1234!"
    viewController.signInButtonPressed(viewController.signInButton)
    XCTAssertFalse(viewController.informationLabel.text!.isEmpty)
  }
  
  func testWrongUsername() {
    viewController.emailTextField.text = "does.not.exist@cosy.net"
    viewController.passwordTextField.text = "Abcd1234!"
    viewController.signInButtonPressed(viewController.signInButton)
    XCTAssertFalse(viewController.informationLabel.text!.isEmpty)
  }
  
  func testLogout() {
    viewController.emailTextField.text = "a@b.c"
    viewController.passwordTextField.text = "Abcd1234!"
    viewController.signInButtonPressed(viewController.signInButton)
    viewController.authenticator.performSignOut()
    XCTAssertTrue(viewController.signInButton.hidden == false)
  }
}
