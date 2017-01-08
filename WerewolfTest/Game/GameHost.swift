//
//  GameController.swift
//  WerewolfTest
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation
import WerewolfFramework

class GameHost: GameController {
	var game: WWGame?
	
	var seenPlayerIDs: [String]
	
	init() {
		self.seenPlayerIDs = Array()
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
	
	func send(data peerData: PeerData, to player: WWPlayer) {
		let data = NSKeyedArchiver.archivedData(withRootObject: peerData)
		
		MultipeerCommunication.shared.send(message: data, to: player.internalIdentifier)
	}
	
	// MARK: GameController -
	
	func connected(device: String) {
		self.seenPlayerIDs.append(device)
	}
	
	func disconnected(device: String) {
		for i in 0 ..< self.seenPlayerIDs.count {
			if self.seenPlayerIDs[i] == device {
				self.seenPlayerIDs.remove(at: i)
				return
			}
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
