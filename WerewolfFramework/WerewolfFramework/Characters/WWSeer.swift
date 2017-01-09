//
//  WWSeer.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWSeer: WWCharacter {
	public init() {
		super.init(name: "Seer", instructions: "I am a Seer", turnOrder: .concurrent, selectable: .nonHumanOnly, interactionCount: 2, defaultVisible: [], defaultViewable: .none)
	}
	
	public required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
	}
	
	override public func perform(action: WWAction, with state: WWState) {
		print("Overridden Seer action!")
	}
}
