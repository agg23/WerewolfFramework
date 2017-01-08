//
//  WWAction.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWAction: NSObject, NSCoding {
	public enum Operation: Int {
		case peek
		case swap
		case inherit
	}
	
	public let ordering: [Operation]
	
	public let delta: [Operation: WWActionData]
	
	public init(ordering: [Operation], delta: [Operation: WWActionData]) {
		self.ordering = ordering
		self.delta = delta
	}
	
	// MARK: NSCoding -
	
	public func encode(with coder: NSCoder) {
		let ordering: [Int] = self.ordering.map{$0.rawValue}
		
		coder.encode(ordering, forKey: "ordering")
		
		let delta: [Int: WWActionData] = self.delta.map{(key, value) in (key.rawValue, value)}
		
		coder.encode(delta, forKey: "delta")
	}
	
	public required init?(coder decoder: NSCoder) {
		guard let orderingInt = decoder.decodeObject(forKey: "ordering") as? [Int] else {
			print("[ERROR] Cannot decode ordering")
			return nil
		}
		
		self.ordering = orderingInt.map{Operation(rawValue: $0) ?? .peek}
		
		guard let delta = decoder.decodeObject(forKey: "delta") as? [Int: WWActionData] else {
			print("[ERROR] Cannot decode delta")
			return nil
		}
		
		self.delta = delta.map{(key, value) in (Operation(rawValue: key) ?? .peek, value)}
	}
}
