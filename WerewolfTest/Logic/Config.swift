//
//  Config.swift
//  WerewolfTest
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public extension Notification.Name {
	static let deviceConnected = Notification.Name("deviceConnected")
	static let deviceDisconnected = Notification.Name("deviceDisconnected")
	
	static let deviceConnectionRequest = Notification.Name("deviceConnectionRequest")
	
	static let messageReceived = Notification.Name("messageReceived")
	
	static let stateUpdate = Notification.Name("stateUpdate")
}
