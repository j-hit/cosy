//
//  CoolingStateVisualiser.swift
//  cosy
//
//  Created by James Bampoe on 08/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation
import WatchKit

struct CoolingStateVisualiser: ThermostatStateVisualiser {
  var color: UIColor {
    return UIColor(red:0.20, green:0.63, blue:0.86, alpha:1.0)
  }
  var description: String { 
    return NSLocalizedString("CoolingStateDescription", comment: "Informs the user that the thermostat is in cooling state")
  }
  var circularImageName: String {
    return "cooling-thermostat-list"
  }
}