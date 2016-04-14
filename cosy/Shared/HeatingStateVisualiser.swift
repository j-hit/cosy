//
//  HeatingStateVisualiser.swift
//  cosy
//
//  Created by James Bampoe on 08/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation
import WatchKit

struct HeatingStateVisualiser: ThermostatStateVisualiser {
  var color: UIColor {
    return UIColor(red:1.00, green:0.47, blue:0.00, alpha:1.0)
  }
  var description: String {
    return NSLocalizedString("HeatingStateDescription", comment: "Informs the user that the thermostat is in heating state")
  }
}