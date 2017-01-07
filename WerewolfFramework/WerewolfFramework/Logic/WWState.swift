//
//  WWState.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

class WWState {
	var players: [WWPlayer]
	var assignments: [WWPlayer: WWCharacter]
	
	init(players: [WWPlayer], assignments: [WWPlayer: WWCharacter]) {
		self.players = players
		self.assignments = assignments
	}
}
