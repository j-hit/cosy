//
//  IdleStateVisualiser.swift
//  cosy
//
//  Created by James Bampoe on 08/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation
import WatchKit

struct IdleStateVisualiser: ThermostatStateVisualiser {
  var color: UIColor {
    return UIColor.lightGrayColor()
  }
  var textColor: UIColor {
    return UIColor.blackColor()
  }
  var circularImageName: String {
    return "idle-thermostat-list"
  }
}
