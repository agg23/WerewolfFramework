//
//  WWWitch.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWWitch: WWCharacter {
	var humanPlayerSelect: Bool
	
	public init() {
		self.humanPlayerSelect = false
		
		super.init(name: "Witch", instructions: "I am a Witch", turnOrder: .concurrent, orderNumber: 20, selectable: .nonHumanOnly, interactionCount: 1, defaultVisible: [], defaultViewable: .none)
	}
	
	public required init?(coder decoder: NSCoder) {
		self.humanPlayerSelect = false
		
		super.init(coder: decoder)
	}
	
	override public func perform(action: WWAction, with state: WWState) {
		print("Overridden Witch action!")
		
		if action.actions.count < 2 {
			print("[WARNING] Not two WWActionData for Witch")
			return
		}
		
		let firstActionData = action.actions[action.actions.count - 2]
		
		guard let secondActionData = action.lastAction else {
			print("[WARNING] Missing WWActionData for Witch")
			return
		}
		
		guard let first = firstActionData.firstSelection, let second = secondActionData.firstSelection else {
			print("[WARNING] Invalid WWActionData for Troublemaker")
			return
		}
		
		// Nonhuman card
		let temp = state.assignments[first]
		state.assignments[first] = state.assignments[second]
		state.assignments[second] = temp
	}
	
	public override func beginNight(with state: WWState) {
		self.humanPlayerSelect = false
		
		self.selectable = .nonHumanOnly
	}
	
	public override func received(action: WWAction) -> Bool {
		let temp = self.humanPlayerSelect
		
		self.humanPlayerSelect = true
		
		self.selectable = .humanOnly
		
		return !temp
	}
}
