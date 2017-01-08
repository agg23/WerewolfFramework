//
//  WWCharacter.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

class WWCharacter: Equatable {
	
	enum TurnOrder {
		case concurrent
		case last
		case inactive
	}
	
	var name: String
	var image: UIImage?
	var turnOrder: TurnOrder
	
	var instructions: String
	
	init() {
		self.name = "Default Character"
		self.turnOrder = .inactive
		self.instructions = "Default character instructions (PLEASE REPLACE)"
	}
	
	/**
		Interprets the provided WWAction (typically created from the GUI) and mutates the WWState
	*/
	func perform(action: WWAction, with state: WWState) {
		print("[WARNING] Default action performed. Nothing was changed")
	}
	
	static func ==(lhs: WWCharacter, rhs: WWCharacter) -> Bool {
		return lhs.turnOrder == rhs.turnOrder && lhs.name == rhs.name
	}
}
