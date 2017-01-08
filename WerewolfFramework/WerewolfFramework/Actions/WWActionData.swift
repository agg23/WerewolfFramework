//
//  WWActionData.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

struct WWActionData {
	let firstInteraction: WWPlayer
	let secondInteraction: WWPlayer
	
	init(first: WWPlayer, second: WWPlayer) {
		self.firstInteraction = first
		self.secondInteraction = second
	}
}
