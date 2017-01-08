//
//  WWMinion.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWMinion: WWCharacter {
	override public init() {
		super.init()
		
		self.name = "Minion"
		self.instructions = "I am a Minion"
	}
	
	override public func perform(action: WWAction, with state: WWState) {
		print("Overridden Minion action!")
	}
}
