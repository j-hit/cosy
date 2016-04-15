//
//  SettingsProvider.swift
//  cosy
//
//  Created by James Bampoe on 06/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation

protocol SettingsProvider {
  var key: String { get }
  var mockModeEnabled: Bool { get set }
  var lastUsedEmailAddress: String { get set }
  var lastUsedPassword: String { get set }
  var baseURLOfCPSCloud: String { get set }
  var sessionID: String? { get set }
  var favouriteThermostat: Thermostat? { get set }
  func importFromDictionary(dictionary: [String : AnyObject])
  func exportAsDictionary() -> [String : AnyObject]
}