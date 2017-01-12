//
//  WWPlayer.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWPlayer: NSObject, NSCoding, NSCopying {
	public let isHumanPlayer: Bool
	
	public var name: String
	public var internalIdentifier: String
	
	public init(name: String, internalIdentifier: String, human: Bool) {
		self.isHumanPlayer = human
		
		self.name = name
		self.internalIdentifier = internalIdentifier;
	}
	
	// MARK: - Hashable
	
	override public var hashValue: Int {
		return self.internalIdentifier.hashValue
	}
	
	public static func ==(lhs: WWPlayer, rhs: WWPlayer) -> Bool {
		return lhs.name == rhs.name && lhs.internalIdentifier == rhs.internalIdentifier
	}
	
	// MARK: - NSCoding
	
	public func encode(with coder: NSCoder) {
		coder.encode(self.isHumanPlayer, forKey: "human")
		coder.encode(self.name, forKey: "name")
		coder.encode(self.internalIdentifier, forKey: "id")
	}
	
	public required init?(coder decoder: NSCoder) {
		self.isHumanPlayer = decoder.decodeBool(forKey: "human")
		
		guard let name = decoder.decodeObject(forKey: "name") as? String else {
			print("[ERROR] Cannot decode player name")
			return nil
		}
		
		self.name = name
		
		guard let id = decoder.decodeObject(forKey: "id") as? String else {
			print("[ERROR] Cannot decode player id")
			return nil
		}
		
		self.internalIdentifier = id
	}
	
	// MARK: - NSCopying
	
	public func copy(with zone: NSZone? = nil) -> Any {
		return WWPlayer(name: self.name, internalIdentifier: self.internalIdentifier, human: self.isHumanPlayer)
	}
}
