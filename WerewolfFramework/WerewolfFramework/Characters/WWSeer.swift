//
//  WWSeer.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWSeer: WWCharacter {
	override public init() {
		super.init()
		
		self.name = "Seer"
		self.instructions = "I am a Seer"
	}
	
	override public func perform(action: WWAction, with state: WWState) {
		print("Overridden Seer action!")
	}
}
