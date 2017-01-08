//
//  WWActionData.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWActionData: NSObject, NSCoding {
	public let firstInteraction: WWPlayer
	public let secondInteraction: WWPlayer
	
	public init(first: WWPlayer, second: WWPlayer) {
		self.firstInteraction = first
		self.secondInteraction = second
	}
	
	// MARK: NSCoding -
	
	public func encode(with coder: NSCoder) {
		coder.encode(self.firstInteraction, forKey: "first")
		coder.encode(self.secondInteraction, forKey: "second")
	}
	
	public required init?(coder decoder: NSCoder) {
		guard let first = decoder.decodeObject(forKey: "first") as? WWPlayer else {
			print("[ERROR] Cannot decode first WWPlayer")
			return nil
		}
		
		self.firstInteraction = first
		
		guard let second = decoder.decodeObject(forKey: "second") as? WWPlayer else {
			print("[ERROR] Cannot decode second WWPlayer")
			return nil
		}
		
		self.secondInteraction = second
	}
}
