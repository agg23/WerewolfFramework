//
//  WWAction.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWAction: NSObject, NSCoding {
	/**
		WWActionData representing the selected players
	*/
	public let actions: [WWActionData]
	
	public var lastAction: WWActionData? {
		if self.actions.count < 1 {
			return nil
		}
		
		return self.actions[self.actions.count - 1]
	}
	
	public init(actions: [WWActionData]) {
		self.actions = actions
	}
	
	// MARK: - NSCoding
	
	public func encode(with coder: NSCoder) {
		coder.encode(self.actions, forKey: "actions")
	}
	
	public required init?(coder decoder: NSCoder) {
		guard let actions = decoder.decodeObject(forKey: "actions") as? [WWActionData] else {
			print("[ERROR] Cannot decode actions")
			return nil
		}
		
		self.actions = actions
	}
}
