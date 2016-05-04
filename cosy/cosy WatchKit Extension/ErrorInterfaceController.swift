//
//  ErrorInterfaceController.swift
//  cosy
//
//  Created by James Bampoe on 02/05/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import WatchKit
import Foundation


class ErrorInterfaceController: WKInterfaceController {
  static let identifier = "errorInterfaceController"
  
  @IBOutlet var errorMessageLabel: WKInterfaceLabel!
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    
    if let errorMessage = context as? String {
      errorMessageLabel.setText(errorMessage)
    }
    
    setTitle(NSLocalizedString("ErrorInterfaceControllerModalTitle", comment: "Title shown on the modal view shown to the user when clicking on an error indicator"))
  }
  
  override func willActivate() {
    super.willActivate()
  }
  
  override func didDeactivate() {
    super.didDeactivate()
  }
}
