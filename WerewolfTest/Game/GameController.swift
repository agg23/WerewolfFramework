//
//  GameController.swift
//  WerewolfTest
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation
import WerewolfFramework

class GameController: MCDelegate {
	var game: WWGame?
	
	var seenPlayerIDs: [String]
	
	init() {
		self.seenPlayerIDs = Array()
		
		NotificationCenter.default.addObserver(forName: .DeviceConnected, object: nil, queue: nil) { (notification) in
			if MultipeerCommunication.shared.isHost {
				guard let string = notification.object as? String else {
					print("[ERROR] Invalid notification .DeviceConnected object")
					return
				}
				
				self.seenPlayerIDs.append(string)
			} else {
				// Newly connected, so send device name to host
				let data = PeerData(name: "Test Device Name")
				self.send(data: data, toHost: true)
			}
		}
		
		NotificationCenter.default.addObserver(forName: .DeviceDisconnected, object: nil, queue: nil) { (notification) in
			if MultipeerCommunication.shared.isHost {
				guard let string = notification.object as? String else {
					print("[ERROR] Invalid notification .DeviceDisconnected object")
					return
				}
				
				for i in 0 ..< self.seenPlayerIDs.count {
					if self.seenPlayerIDs[i] == string {
						self.seenPlayerIDs.remove(at: i)
						return
					}
				}
			}
		}
	}
	
	func newGame(name: String) {
		self.game = WWGame(name: name)
		
		self.game?.registerPlayer(name: "Adam", internalIdentifier: "AdamID")
		self.game?.registerPlayer(name: "Anna", internalIdentifier: "AnnaID")
		self.game?.registerPlayer(name: "Christopher", internalIdentifier: "Christopher")
		self.game?.registerNonHumanPlayers(count: 3)
		
		self.game?.register(character: WWTroublemaker())
		self.game?.register(character: WWWitch())
		self.game?.register(character: WWSeer())
		self.game?.register(character: WWWerewolf())
		self.game?.register(character: WWWerewolf())
		self.game?.register(character: WWMinion())
		
		self.game?.generateRound()
		
		guard let currentState = self.game?.state else {
			print("[ERROR] Invalid state")
			return
		}
		
		for (player, character) in currentState.assignments {
			print("Player \(player.name) was assigned character \(character.name)")
		}
		
		// TODO: Remove
		// Test PeerData
		
		let peerData = PeerData(action: WWAction(ordering: [.peek], delta: [.peek: WWActionData.init(first: WWPlayer(name: "Test", internalIdentifier: "test", human: true), second: WWPlayer(name: "Test2", internalIdentifier: "test2", human: true))]))
		let data = NSKeyedArchiver.archivedData(withRootObject: peerData)
		
		let peerData2 = NSKeyedUnarchiver.unarchiveObject(with: data) as? PeerData
		
		guard let peer = peerData2 else {
			print("Decoding failed")
			return
		}
		
		print(peerData.command)
		print(peer.command)
		
		print(peerData === peer)
	}
	
	func send(data peerData: PeerData, toHost: Bool) {
		let data = NSKeyedArchiver.archivedData(withRootObject: peerData)
		
		if toHost {
			MultipeerCommunication.shared.sendToHost(message: data)
		} else {
			MultipeerCommunication.shared.sendToAll(message: data)
		}
	}
	
	// MARK: MCDelegate -
	
	func messageReceived(data: Data, from sender: String) {
		let any = NSKeyedUnarchiver.unarchiveObject(with: data)
		
		guard let peerData = any as? PeerData else {
			print("[ERROR] Received message is not valid PeerData")
			return
		}
		
		print("Received PeerData from \(sender) with command \(peerData.command)")
	}
}
