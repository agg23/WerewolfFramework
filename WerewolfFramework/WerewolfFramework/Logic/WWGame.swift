//
//  WWGame.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation
import GameplayKit

public class WWGame {
	public var name: String
	
	public var state: WWState?
	
	public var players: [WWPlayer]
	public var nonHumanPlayers: [WWPlayer]
	
	public var allPlayers: [WWPlayer] {
		return self.players + self.nonHumanPlayers
	}
	
	public var characters: [WWCharacter]
	
	public var nightCanEnd: Bool
	
	private var actions: [WWPlayer: WWAction]
	
	public init(name: String) {
		self.name = name
		
		self.players = [WWPlayer]()
		self.nonHumanPlayers = [WWPlayer]()
		
		self.characters = [WWCharacter]()
		
		self.nightCanEnd = false
		
		self.actions = [WWPlayer: WWAction]()
	}
	
	public func resetGame() {
		self.nonHumanPlayers = [WWPlayer]()
		
		self.characters = [WWCharacter]()
	}
	
	public func generateRound() {
		if self.characters.count != self.players.count + self.nonHumanPlayers.count {
			print("[ERROR] Cannot generate round when the number of characters and players does not equal")
		}
		
		let shuffledCharacters = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: self.characters) as! [WWCharacter]
		
		var assignments = [Int: WWCharacter]()
		
		for i in 0 ..< shuffledCharacters.count {
			let character = shuffledCharacters[i]
			
			assignments[i] = character
		}
		
		self.state = WWState(players: self.allPlayers, characters: self.characters, assignments: assignments)
		self.actions = [WWPlayer: WWAction]()
	}
	
	public func clearState() {
		self.state?.status = .nogame
	}
	
	public func cancelGame() {
		self.state = nil
	}
	
	public func startNight() {
		guard let state = self.state else {
			print("[ERROR] Cannot start night. No state exists")
			return
		}
		
		if state.status == .night {
			print("[WARNING] Attempting to start night when night is current status")
			return
		}
		
		state.status = .night
		
		for character in self.characters {
			character.beginNight(with: state)
		}
	}
	
	public func startDiscussion() {
		guard let state = self.state else {
			print("[ERROR] Cannot start discussion. No state exists")
			return
		}
		
		state.status = .discussion
		
		let playerAssignments = state.playerAssignments
		
		for (player, action) in self.actions {
			if action.actions.count < 1 {
				print("[ERROR] Attempting to process WWAction with no ordering")
				continue
			}
			
			guard let character = playerAssignments[player] else {
				print("[ERROR] WWAction with invalid player")
				continue
			}
			character.perform(action: action, with: state)
		}
	}
	
	public func endGame() {
		self.state?.status = .nogame
	}
	
	// MARK: - Communication
	
	/**
		Adds the provided WWAction to the list of queued actions. Returns true if the WWCharacter indicated a status update should be sent to the client
	*/
	public func add(action: WWAction, for player: WWPlayer) -> Bool {
		if action.actions.count < 1 {
			print("[ERROR] Attempting to process WWAction with no action data")
			return false
		}
		
		guard let playerIndex = index(of: player) else {
			print("[ERROR] Invalid player provided on action add")
			return false
		}
		
		let character = self.state?.assignments[playerIndex]
		
		let shouldUpdate = character?.received(action: action) ?? false
		
		let previousAction = self.actions[player]
		
		var finalAction: WWAction
		
		if previousAction != nil {
			finalAction = WWAction(actions: previousAction!.actions + action.actions)
		} else {
			finalAction = action
		}
		
		self.actions[player] = finalAction
		
		if self.actions.count == self.players.count {
			self.nightCanEnd = true
		}
		
		return shouldUpdate
	}
	
	// MARK: - Player/Character Management
	
	public func registerPlayer(name: String, internalIdentifier: String) -> WWPlayer? {
		let player = WWPlayer(name: name, internalIdentifier: internalIdentifier, human: true)
		
		for player in self.players {
			if player.name == name {
				return nil
			}
		}
		
		self.players.append(player)
		
		return player
	}
	
	public func player(with id: String) -> WWPlayer? {
		for i in 0 ..< self.players.count {
			if self.players[i].internalIdentifier == id {
				return self.players[i]
			}
		}
		return nil
	}
	
	public func removePlayer(id: String) {
		for i in 0 ..< self.players.count {
			if self.players[i].internalIdentifier == id {
				self.players.remove(at: i)
				return
			}
		}
	}
	
	private func index(of player: WWPlayer) -> Int? {
		for i in 0 ..< self.players.count {
			if self.players[i] == player {
				return i
			}
		}
		
		return nil
	}
	
	public func registerNonHumanPlayers(count: Int) {
		if self.nonHumanPlayers.count == count {
			return
		}
		
		for i in 0 ..< count {
			let name = String(format: "Center Card %d", i + 1)
			self.nonHumanPlayers.append(WWPlayer(name: name, internalIdentifier: "nonhuman", human: false))
		}
	}
	
	public func register(character: WWCharacter) {
		self.characters.append(character)
	}
	
	public func remove(character: WWCharacter) {
		for i in 0 ..< self.characters.count {
			if self.characters[i] == character {
				self.characters.remove(at: i)
				return
			}
		}
	}
}
