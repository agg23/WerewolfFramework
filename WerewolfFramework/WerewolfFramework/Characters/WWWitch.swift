//
//  WWWitch.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWWitch: WWCharacter {
	override public init() {
		super.init()
		
		self.name = "Witch"
		self.instructions = "I am a Witch"
	}
	
	override public func perform(action: WWAction, with state: WWState) {
		print("Overridden Witch action!")
	}
}
