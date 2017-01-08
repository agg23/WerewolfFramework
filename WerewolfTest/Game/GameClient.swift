//
//  GameClient.swift
//  WerewolfTest
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation
import WerewolfFramework

class GameClient: GameController {
	
	var name: String
	
	init() {
		self.name = UIDevice.current.name
	}
	
	func send(data peerData: PeerData) {
		let data = NSKeyedArchiver.archivedData(withRootObject: peerData)
		
		MultipeerCommunication.shared.sendToHost(message: data)
	}
	
	// MARK: MCDelegate -
	
	func connected(device: String) {
		// Newly connected, so send device name to host
		let data = PeerData(name: "Test Device Name")
		self.send(data: data)
	}
	
	func disconnected(device: String) {
		
	}
	
	func messageReceived(data: Data, from sender: String) {
		
	}
}
