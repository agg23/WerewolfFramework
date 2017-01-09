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
	var game: WWGame
	
	var host: WWPlayer?
	var hostClient: GameClient
	
	var seenPlayerIDs: [String]
	
	init(client: GameClient) {
		self.game = WWGame(name: "Default Game")
		
		self.hostClient = client
		
		self.seenPlayerIDs = Array()
		
		self.hostClient.gameHost = self
		MultipeerCommunication.shared.delegate = self
	}
	
	func newGame(name: String) {
		self.game.name = name
		
		self.game.registerNonHumanPlayers(count: 3)
		
		let characters = [WWWerewolf(), WWWerewolf(), WWTroublemaker(), WWWitch(), WWSeer(), WWMinion()]
		
		for i in 0 ..< self.game.players.count + self.game.nonHumanPlayers.count {
			self.game.register(character: characters[i])
		}
		
		self.game.generateRound()
		
		self.game.inProgress = true
		
		guard let currentState = self.game.state else {
			print("[ERROR] Invalid state")
			return
		}
		
		for (player, character) in currentState.playerAssignments {
			print("Player \(player.name) was assigned character \(character.name)")
		}
		
		let peerData = PeerData(state: currentState)
		
		let data = NSKeyedArchiver.archivedData(withRootObject: peerData)
		MultipeerCommunication.shared.sendToAll(message: data)
		
		// Send to host's client
		sendToHost(data: data)
	}
	
	func cancelGame() {
		self.game.inProgress = false
	}
	
	// MARK: - Host Player
	
	func registerHostPlayer(with name: String) {
		self.host = self.game.registerPlayer(name: name, internalIdentifier: "host")
	}
	
	func sendToHost(data: Data) {
		self.hostClient.messageReceived(data: data, from: MultipeerCommunication.shared.localPeerID.displayName)
	}
	
	// MARK: - Communication
	
	func send(data peerData: PeerData, to player: WWPlayer) {
		let data = NSKeyedArchiver.archivedData(withRootObject: peerData)
		
		if self.host == player {
			print("Rerouting data to the host's client")
			sendToHost(data: data)
			
			return
		}
		
		MultipeerCommunication.shared.send(message: data, to: player.internalIdentifier)
	}
	
	func sendStatus(to player: WWPlayer) {
		guard let state = self.game.state else {
			return
		}
		
		let peerData = PeerData(state: state)
		send(data: peerData, to: player)
	}
	
	func actionUpdate(data: PeerData) {
		
	}
	
	private func registerName(data: PeerData, from sender: String) {
		guard let name = data.registeredName else {
			print("[ERROR] Received registername command, with no included name")
			return
		}
		
		for playerID in self.seenPlayerIDs {
			if playerID == sender {
				let _ = self.game.registerPlayer(name: name, internalIdentifier: playerID)
				return
			}
		}
		
		print("[WARNING] Could not find peer for which to register name")
	}
	
	// MARK: - GameController
	
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
		
		for player in self.game.players {
			if player.internalIdentifier == device {
				self.game.removePlayer(id: device)
				
				if self.game.inProgress {
					print("Canceling game. User with device \(device) disconnected")
					cancelGame()
				}
			}
		}
	}
	
	// MARK: - MCDelegate
	
	func messageReceived(data: Data, from sender: String) {
		let any = NSKeyedUnarchiver.unarchiveObject(with: data)
		
		guard let peerData = any as? PeerData else {
			print("[ERROR] Received message is not valid PeerData")
			return
		}
		
		print("Received PeerData from \(sender) with command \(peerData.command)")
		
		switch peerData.command {
		case .actionupdate:
			actionUpdate(data: peerData)
		case .registername:
			registerName(data: peerData, from: sender)
		case .stateupdate:
			print("[WARNING] Host should not receive stateupdate command")
		default:
			print("[WARNING] Unhandled command")
		}
	}
}
