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
	
	var state: WWState?
	var player: WWPlayer?
	
	weak var gameHost: GameHost?
	
	init() {
		self.name = UIDevice.current.name
	}
	
	func stateUpdate(data: PeerData) {
		self.state = data.state
		
		guard let state = self.state else {
			print("[ERROR] Received stateupdate command, with no attached state")
			return
		}
		
		for player in state.players {
			if (self.gameHost != nil && player.internalIdentifier == "host") || player.name == MultipeerCommunication.shared.localPeerID.displayName {
				self.player = player
				break
			}
		}
		
		guard let player = self.player else {
			print("[ERROR] Stateupdate did not contain client's player. Disconnecting")
			MultipeerCommunication.shared.disconnect()
			return
		}
		
		let assignments = state.playerAssignments
		
		guard let character = assignments[player] else {
			print("[ERROR] Stateupdate did not assign client's player. Disconnecting")
			MultipeerCommunication.shared.disconnect()
			return
		}
		
		print("Client was assigned the role of \(character.name)")
	}
	
	func send(data peerData: PeerData) {
		let data = NSKeyedArchiver.archivedData(withRootObject: peerData)
		
		if self.gameHost != nil {
			// Send to host
			self.gameHost?.messageReceived(data: data, from: MultipeerCommunication.shared.localPeerID.displayName)
			return
		}
		
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
		let any = NSKeyedUnarchiver.unarchiveObject(with: data)
		
		guard let peerData = any as? PeerData else {
			print("[ERROR] Received message is not valid PeerData")
			return
		}
		
		print("Received PeerData from \(sender) (hopefully host) with command \(peerData.command)")
		
		switch peerData.command {
		case .actionupdate:
			print("[WARNING] Client should not receive actionupdate command")
		case .registername:
			print("[WARNING] Client should not receive registername command")
		case .stateupdate:
			stateUpdate(data: peerData)
		default:
			print("[WARNING] Unhandled command")
		}
	}
}
