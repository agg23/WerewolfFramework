//
//  WWAction.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

class WWAction {
	enum Operation {
		case peek
		case swap
		case inherit
	}
	
	let ordering: [Operation]
	
	let delta: [Operation: WWActionData]
	
	init(ordering: [Operation], delta: [Operation: WWActionData]) {
		self.ordering = ordering
		self.delta = delta
	}
}
