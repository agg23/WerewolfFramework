//
//  WWState.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWState: NSObject, NSCoding {
	
	public enum GameStatus: Int {
		case starting
		case night
		case discussion
		case nogame
	}
	
	public var players: [WWPlayer]
	public var characters: [WWCharacter]
	public var assignments: [Int: WWCharacter]
	
	public var status: GameStatus
	
	init(players: [WWPlayer], characters: [WWCharacter], assignments: [Int: WWCharacter]) {
		self.players = players
		self.characters = characters
		self.assignments = assignments
		
		self.status = .nogame
	}
	
	public var playerAssignments: [WWPlayer: WWCharacter] {
		var playerAssignments = [WWPlayer: WWCharacter]()
		
		for i in 0 ..< self.players.count {
			let player = self.players[i]
			playerAssignments[player] = self.assignments[i]
		}
		
		return playerAssignments
	}
	
	public func player(at index: Int) -> WWPlayer? {
		if index >= self.players.count {
			return nil
		}
		
		return self.players[index]
	}
	
	func swap(first firstPlayerIndex: Int, second secondPlayerIndex: Int) {
		let temp = self.assignments[firstPlayerIndex]
		let temp2 = self.assignments[secondPlayerIndex]
		
		temp?.transferedCharacterName = nil
		temp2?.transferedCharacterName = nil
		
		self.assignments[firstPlayerIndex] = temp2
		self.assignments[secondPlayerIndex] = temp
	}
	
	// MARK: - NSCoding
	
	public func encode(with coder: NSCoder) {
		coder.encode(self.players, forKey: "players")
		coder.encode(self.characters, forKey: "characters")
		coder.encode(self.assignments, forKey: "assignments")
		
		coder.encode(self.status.rawValue, forKey: "status")
	}
	
	public required init?(coder decoder: NSCoder) {
		guard let players = decoder.decodeObject(forKey: "players") as? [WWPlayer] else {
			print("[ERROR] Cannot decode players")
			return nil
		}
		
		self.players = players
		
		guard let characters = decoder.decodeObject(forKey: "characters") as? [WWCharacter] else {
			print("[ERROR] Cannot decode characters")
			return nil
		}
		
		self.characters = characters
		
		guard let assignments = decoder.decodeObject(forKey: "assignments") as? [Int: WWCharacter] else {
			print("[ERROR] Cannot decode assignments")
			return nil
		}
		
		self.assignments = assignments
		
		self.status = GameStatus(rawValue: decoder.decodeInteger(forKey: "status")) ?? .nogame
	}
}
