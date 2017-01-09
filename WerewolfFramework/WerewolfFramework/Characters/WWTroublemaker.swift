//
//  WWTroublemaker.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWTroublemaker: WWCharacter {
	public init() {
		super.init(name: "Troublemaker", instructions: "I am a Troublemaker", turnOrder: .concurrent, viewable: .humanOnly, interactionCount: 2)
	}
	
	public required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
	}
	
	override public func perform(action: WWAction, with state: WWState) {
		print("Overridden Troublemaker action!")
	}
}
