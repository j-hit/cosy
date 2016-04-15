//
//  ThermostatState.swift
//  cosy
//
//  Created by James Bampoe on 15/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation

enum ThermostatState {
  case Heating
  case Cooling
  case Idle
  
  func visualiser() -> ThermostatStateVisualiser {
    switch self {
    case Heating:
      return HeatingStateVisualiser()
    case Cooling:
      return CoolingStateVisualiser()
    case Idle:
      return IdleStateVisualiser()
    }
  }
}