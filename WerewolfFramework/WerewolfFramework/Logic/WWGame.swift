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
	
	public var characters: [WWCharacter]
	
	public init(name: String) {
		self.name = name
		
		self.players = [WWPlayer]()
		self.nonHumanPlayers = [WWPlayer]()
		
		self.characters = [WWCharacter]()
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
		
		self.state = WWState(players: self.players + self.nonHumanPlayers, assignments: assignments)
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
	
	public func removePlayer(id: String) {
		for i in 0 ..< self.players.count {
			if self.players[i].name == id {
				self.players.remove(at: i)
				return
			}
		}
	}
	
	public func registerNonHumanPlayers(count: Int) {
		if self.nonHumanPlayers.count == count {
			return
		}
		
		for i in 0 ..< count {
			let name = String(format: "Nonhuman Player %d", i)
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
