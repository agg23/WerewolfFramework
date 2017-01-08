//
//  WWTroublemaker.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWTroublemaker: WWCharacter {
	override public init() {
		super.init()
		
		self.name = "Troublemaker"
		self.instructions = "I am a Troublemaker"
	}
	
	override public func perform(action: WWAction, with state: WWState) {
		print("Overridden Troublemaker action!")
	}
}
