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
		
		self.game.resetGame()
		
		self.game.registerNonHumanPlayers(count: 3)
		
		let characters = [WWWerewolf(), WWWerewolf(), WWMinion(), WWRobber(), WWWitch(), WWSeer(), WWTroublemaker(), WWPI(), WWMason(), WWMason()]
		
		for i in 0 ..< self.game.players.count + self.game.nonHumanPlayers.count {
			self.game.register(character: characters[i])
		}
		
		self.game.generateRound()
		
		self.game.state?.status = .starting
		
		guard let currentState = self.game.state else {
			print("[ERROR] Invalid state")
			return
		}
		
		for (player, character) in currentState.playerAssignments {
			print("Player \(player.name) was assigned character \(character.name)")
		}
		
		sendAllStatus()
		
		// TODO: Should have confirmation, but instead jumps straight to night
		Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(startNight), userInfo: nil, repeats: false)
	}
	
	@objc func startNight() {
		self.game.startNight()
		
		if self.game.nightCanEnd {
			Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(startDiscussion), userInfo: nil, repeats: false)
		}
		
		sendAllStatus()
	}
	
	@objc func startDiscussion() {
		self.game.setDiscussionStatus()
		
		sendAllStatus()
		
		let playersNeedingState = self.game.startDiscussion()
		
		for player in playersNeedingState {
			sendStatus(to: player)
		}
	}
	
	func endGame() {
		self.game.endGame()
		
		sendAllStatus()
	}
	
	func cancelGame() {
		self.game.clearState()
		
		sendAllStatus()
		
		self.game.cancelGame()
	}
	
	// MARK: - Host Player
	
	func registerHostPlayer(with name: String) {
		self.host = self.game.registerPlayer(name: name, internalIdentifier: UIDevice.current.name)
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
	
	func sendAllStatus() {
		guard let state = self.game.state else {
			return
		}
		
		let peerData = PeerData(state: state)
		
		let data = NSKeyedArchiver.archivedData(withRootObject: peerData)
		MultipeerCommunication.shared.sendToAll(message: data)
		
		// Send to host's client
		sendToHost(data: data)
	}
	
	func sendStatus(to player: WWPlayer) {
		guard let state = self.game.state else {
			return
		}
		
		let peerData = PeerData(state: state)
		send(data: peerData, to: player)
	}
	
	func actionUpdate(data: PeerData, from sender: String) {
		guard let action = data.action else {
			print("[ERROR] Received actionupdate command, with no included action")
			return
		}
		
		print("Received actionupdate")
		
		if let player = self.game.player(with: sender), self.game.add(action: action, for: player) {
			print("Sending client \(sender) updated state as indicated by WWCharacter")
			sendStatus(to: player)
		}
		
		if self.game.nightCanEnd {
			startDiscussion()
		}
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
				break
			}
		}
		
		for player in self.game.players {
			if player.internalIdentifier == device {
				self.game.removePlayer(id: device)
				
				if self.game.state?.status != .nogame {
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
			actionUpdate(data: peerData, from: sender)
		case .registername:
			registerName(data: peerData, from: sender)
		case .stateupdate:
			print("[WARNING] Host should not receive stateupdate command")
		}
	}
}
