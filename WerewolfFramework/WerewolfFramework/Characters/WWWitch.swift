//
//  WWWitch.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWWitch: WWCharacter {
	public init() {
		super.init(name: "Witch", instructions: "I am a Witch", turnOrder: .concurrent)
	}
	
	public required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
	}
	
	override public func perform(action: WWAction, with state: WWState) {
		print("Overridden Witch action!")
	}
}
