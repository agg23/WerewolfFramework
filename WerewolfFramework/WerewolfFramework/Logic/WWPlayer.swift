//
//  WWPlayer.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

class WWPlayer: Hashable {
	let isHumanPlayer: Bool
	
	var name: String
	var internalIdentifier: String
	
	init(name: String, internalIdentifier: String, human: Bool) {
		self.isHumanPlayer = human
		
		self.name = name
		self.internalIdentifier = internalIdentifier;
	}
	
	// MARK: Hashable -
	
	var hashValue: Int {
		return name.hashValue
	}
	
	static func ==(lhs: WWPlayer, rhs: WWPlayer) -> Bool {
		return lhs.name == rhs.name && lhs.internalIdentifier == rhs.internalIdentifier
	}

}
