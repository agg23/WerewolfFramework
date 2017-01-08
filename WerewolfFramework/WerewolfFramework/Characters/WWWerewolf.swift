//
//  WWWerewolf.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWWerewolf: WWCharacter {
	override public init() {
		super.init()
		
		self.name = "Werewolf"
		self.instructions = "I am a Werewolf"
	}
	
	override public func perform(action: WWAction, with state: WWState) {
		print("Overridden Werewolf action!")
	}
}
