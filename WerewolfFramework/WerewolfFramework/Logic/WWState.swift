//
//  WWState.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWState: NSObject, NSCoding {
	public var players: [WWPlayer]
	public var assignments: [Int: WWCharacter]
	
	init(players: [WWPlayer], assignments: [Int: WWCharacter]) {
		self.players = players
		self.assignments = assignments
	}
	
	public var playerAssignments: [WWPlayer: WWCharacter] {
		var playerAssignments = [WWPlayer: WWCharacter]()
		
		for i in 0 ..< self.players.count {
			let player = self.players[i]
			playerAssignments[player] = self.assignments[i]
		}
		
		return playerAssignments
	}
	
	// MARK: - NSCoding
	
	public func encode(with coder: NSCoder) {
		coder.encode(self.players, forKey: "players")
		coder.encode(self.assignments, forKey: "assignments")
	}
	
	public required init?(coder decoder: NSCoder) {
		guard let players = decoder.decodeObject(forKey: "players") as? [WWPlayer] else {
			print("[ERROR] Cannot decode players")
			return nil
		}
		
		self.players = players
		
		let assignmentTest = decoder.decodeObject(forKey: "assignments")
		print(assignmentTest)
		
		guard let assignments = assignmentTest as? [Int: WWCharacter] else {
			print("[ERROR] Cannot decode assignments")
			return nil
		}
		
		self.assignments = assignments
	}
}
