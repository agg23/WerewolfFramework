//
//  MCDelegate.swift
//  WerewolfTest
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

protocol MCDelegate {
	func connected(device: String)
	func disconnected(device: String)
	
	func messageReceived(data: Data, from sender: String)
}
