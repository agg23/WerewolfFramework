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
		super.init(name: "Troublemaker", instructions: "I am a Troublemaker", turnOrder: .concurrent, orderNumber: 100, selectable: .humanOnly, interactionCount: 2, canSelectSelf: false, defaultVisible: [], defaultViewable: .none)
	}
	
	public required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
	}
	
	override public func perform(action: WWAction, with state: WWState) {
		print("Overridden Troublemaker action!")
		
		guard let actionData = action.lastAction else {
			print("[WARNING] No WWActionData for Troublemaker")
			return
		}
		
		guard let first = actionData.firstSelection, let second = actionData.secondSelection else {
			print("[WARNING] Invalid WWActionData for Troublemaker")
			return
		}
		
		state.swap(first: first, second: second)
	}
	
	public override func received(action: WWAction, state: WWState) -> Bool {
		self.selectionComplete = true
		
		return true
	}
}
