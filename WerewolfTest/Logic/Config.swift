//
//  Config.swift
//  WerewolfTest
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public extension Notification.Name {
	static let DeviceConnected = Notification.Name("DeviceConnected")
	static let DeviceDisconnected = Notification.Name("DeviceDisconnected")
	
	static let MessageReceived = Notification.Name("MessageReceived")
}
