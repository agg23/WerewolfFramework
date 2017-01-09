//
//  WWActionData.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWActionData: NSObject, NSCoding {
	/**
		Maps to the index of the first selected player in the WWGame allPlayers array
	*/
	public let firstSelection: Int?
	
	/**
		Maps to the index of the second selected player in the WWGame allPlayers array
	*/
	public let secondSelection: Int?
	
	public init(first: Int?, second: Int?) {
		self.firstSelection = first
		self.secondSelection = second
	}
	
	// MARK: NSCoding -
	
	public func encode(with coder: NSCoder) {
		if self.firstSelection == nil {
			coder.encode(-1, forKey: "first")
		} else {
			coder.encode(self.firstSelection!, forKey: "first")
		}
		
		if self.secondSelection == nil {
			coder.encode(-1, forKey: "second")
		} else {
			coder.encode(self.secondSelection!, forKey: "second")
		}
	}
	
	public required init?(coder decoder: NSCoder) {
		let first = decoder.decodeInteger(forKey: "first")
		
		if first == -1 {
			self.firstSelection = nil
		} else {
			self.firstSelection = first
		}
		
		let second = decoder.decodeInteger(forKey: "second")
		
		if second == -1 {
			self.secondSelection = nil
		} else {
			self.secondSelection = second
		}
	}
}
