//
//  WWWerewolf.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWWerewolf: WWCharacter {
	public init() {
		super.init(name: "Werewolf", instructions: "I am a Werewolf", turnOrder: .concurrent, selectable: .none, interactionCount: 0, defaultVisible: [WWWerewolf.self], defaultViewable: .humanOnly)
	}
	
	public required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
	}
	
	override public func perform(action: WWAction, with state: WWState) {
		print("Overridden Werewolf action!")
	}
}
