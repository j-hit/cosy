//
//  LocationRowController.swift
//  cosy
//
//  Created by James Bampoe on 01/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import WatchKit

class LocationRowController: NSObject {
  @IBOutlet var locationLabel: WKInterfaceLabel!
  @IBOutlet var locationStateImage: WKInterfaceImage!
  
  static let identifier = "LocationRow"
}
