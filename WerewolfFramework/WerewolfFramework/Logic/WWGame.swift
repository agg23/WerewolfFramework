//
//  WWGame.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation
import GameplayKit

class WWGame {
	var name: String
	
	var state: WWState?
	
	var players: [WWPlayer]
	var nonHumanPlayers: [WWPlayer]
	
	var characters: [WWCharacter]
	
	init(name: String) {
		self.name = name
		
		self.players = Array()
		self.nonHumanPlayers = Array()
		
		self.characters = Array()
	}
	
	func generateRound() {
		if self.characters.count != self.players.count + self.nonHumanPlayers.count {
			print("[ERROR] Cannot generate round when the number of characters and players does not equal")
		}
		
		let shuffledCharacters = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: self.characters) as! [WWCharacter]
		
		var assignments = Dictionary<WWPlayer, WWCharacter>()
		
		for i in 0 ..< shuffledCharacters.count {
			let character = shuffledCharacters[i]
			
			let player: WWPlayer
			
			if i < self.players.count {
				player = self.players[i]
			} else {
				player = self.nonHumanPlayers[i - self.players.count]
			}
			
			assignments[player] = character
		}
		
		self.state = WWState(players: self.players + self.nonHumanPlayers, assignments: assignments)
	}
	
	func registerPlayer(name: String, internalIdentifier: String) {
		let player = WWPlayer(name: name, internalIdentifier: internalIdentifier, human: true)
		
		for player in self.players {
			if player.name == name {
				return
			}
		}
		
		self.players.append(player)
	}
	
	func removePlayer(name: String) {
		for i in 0 ..< self.players.count {
			if self.players[i].name == name {
				self.players.remove(at: i)
				return
			}
		}
	}
	
	func registerNonHumanPlayers(count: Int) {
		if self.nonHumanPlayers.count == count {
			return
		}
		
		for i in 0 ..< count {
			let name = String(format: "Nonhuman Player %d", i)
			self.nonHumanPlayers.append(WWPlayer(name: name, internalIdentifier: "nonhuman", human: false))
		}
	}
	
	func register(character: WWCharacter) {
		self.characters.append(character)
	}
	
	func remove(character: WWCharacter) {
		for i in 0 ..< self.characters.count {
			if self.characters[i] === character {
				self.characters.remove(at: i)
				return
			}
		}
	}
}
