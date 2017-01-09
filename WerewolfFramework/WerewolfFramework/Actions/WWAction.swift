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
		Maps to the index of the character in the WWState characters array
	*/
	public let ordering: [Int]
	
	/**
		Maps from index of the character in the WWState characters array to WWActionData representing the selected players
	*/
	public let delta: [Int: WWActionData]
	
	public init(ordering: [Int], delta: [Int: WWActionData]) {
		self.ordering = ordering
		self.delta = delta
	}
	
	// MARK: NSCoding -
	
	public func encode(with coder: NSCoder) {
		coder.encode(self.ordering, forKey: "ordering")
		
		coder.encode(self.delta, forKey: "delta")
	}
	
	public required init?(coder decoder: NSCoder) {
		guard let ordering = decoder.decodeObject(forKey: "ordering") as? [Int] else {
			print("[ERROR] Cannot decode ordering")
			return nil
		}
		
		self.ordering = ordering
		
		guard let delta = decoder.decodeObject(forKey: "delta") as? [Int: WWActionData] else {
			print("[ERROR] Cannot decode delta")
			return nil
		}
		
		self.delta = delta
	}
}
