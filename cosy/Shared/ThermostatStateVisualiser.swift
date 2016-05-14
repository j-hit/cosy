//
//  ThermostatStateVisualiser.swift
//  cosy
//
//  Created by James Bampoe on 08/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation
import WatchKit

protocol ThermostatStateVisualiser {
  var color: UIColor { get }
  var circularImageName: String { get }
}