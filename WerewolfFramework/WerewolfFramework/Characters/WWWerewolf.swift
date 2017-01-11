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
		super.init(name: "Werewolf", instructions: "I am a Werewolf", turnOrder: .concurrent, orderNumber: 1, selectable: .nonHumanOnly, interactionCount: 0, defaultVisible: [WWWerewolf.self], defaultViewable: .humanOnly)
	}
	
	public required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
	}
	
	override public func perform(action: WWAction, with state: WWState) {
		print("Overridden Werewolf action!")
	}
	
	public override func beginNight(with state: WWState) {
		super.beginNight(with: state)
		
		var werewolfCount = 0
		
		for player in state.players {
			if !player.isHumanPlayer {
				continue
			}
			
			let character = state.playerAssignments[player]
			if character is WWWerewolf {
				werewolfCount += 1
			}
		}
		
		if werewolfCount == 1 {
			self.interactionCount = 1
			self.selectionComplete = false
		} else {
			self.interactionCount = 0
			self.selectionComplete = true
		}
	}
	
	public override func received(action: WWAction, state: WWState) -> Bool {
		let firstActionData = action.actions[0]
		
		guard let first = firstActionData.firstSelection else {
			print("[WARNING] Invalid WWActionData for Werewolf")
			return false
		}
		
		if let character = state.assignments[first] {
			self.seenAssignments[first] = type(of: character)
		} else {
			print("[WARNING] Invalid selected character for Werewolf")
		}
		
		self.selectionComplete = true
		
		return true
	}
}
