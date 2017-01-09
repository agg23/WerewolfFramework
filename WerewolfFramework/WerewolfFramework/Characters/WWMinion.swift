//
//  WWMinion.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWMinion: WWCharacter {
	public init() {
		super.init(name: "Minion", instructions: "I am a Minion", turnOrder: .concurrent, viewable: .none, interactionCount: 0)
	}
	
	public required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
	}
	
	override public func perform(action: WWAction, with state: WWState) {
		print("Overridden Minion action!")
	}
}
