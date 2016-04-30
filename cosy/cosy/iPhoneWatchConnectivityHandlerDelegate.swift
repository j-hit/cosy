//
//  iPhoneWatchConnectivityHandlerDelegate.swift
//  cosy
//
//  Created by James Bampoe on 29/04/16.
//  Copyright © 2016 Pentapie. All rights reserved.
//

import Foundation

protocol iPhoneWatchConnectivityHandlerDelegate {
  func didReceiveErrorMessageFromWatch(error: String)
}