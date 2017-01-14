//
//  WWMason.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/14/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWMason: WWCharacter {
	public init() {
		super.init(name: "Mason", instructions: "I am a Mason", turnOrder: .concurrent, orderNumber: 3, selectable: .none, interactionCount: 0, canSelectSelf: false, defaultVisible: [WWMason.self], defaultViewable: .humanOnly)
		self.selectionComplete = true
	}
	
	public required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
	}
	
	public override func beginNight(with state: WWState) {
		// For some reason necessary
		self.selectionComplete = true
	}
	
	override public func perform(action: WWAction, with state: WWState) {
		print("Overridden Mason action!")
	}
}
