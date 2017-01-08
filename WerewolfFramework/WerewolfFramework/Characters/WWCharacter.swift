//
//  WWCharacter.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

public class WWCharacter: NSObject, NSCoding {
	
	public enum TurnOrder: Int {
		case concurrent
		case last
		case inactive
	}
	
	public var name: String
	public var image: UIImage?
	public var turnOrder: TurnOrder
	
	public var instructions: String
	
	public init(name: String, instructions: String, turnOrder: TurnOrder) {
		self.name = name
		self.turnOrder = turnOrder
		self.instructions = instructions
	}
	
	/**
		Interprets the provided WWAction (typically created from the GUI) and mutates the WWState
	*/
	public func perform(action: WWAction, with state: WWState) {
		print("[WARNING] Default action performed. Nothing was changed")
	}
	
	public static func ==(lhs: WWCharacter, rhs: WWCharacter) -> Bool {
		return lhs.turnOrder == rhs.turnOrder && lhs.name == rhs.name
	}
	
	// MARK: - NSCoding
	
	public func encode(with coder: NSCoder) {
		coder.encode(self.name, forKey: "name")
		
		coder.encode(self.turnOrder.rawValue, forKey: "order")
		
		coder.encode(self.instructions, forKey: "instructions")
	}
	
	public required init?(coder decoder: NSCoder) {
		guard let name = decoder.decodeObject(forKey: "name") as? String else {
			print("[ERROR] Cannot decode character name")
			return nil
		}
		
		self.name = name
				
		self.turnOrder = TurnOrder(rawValue: decoder.decodeInteger(forKey: "order")) ?? .inactive
		
		guard let instructions = decoder.decodeObject(forKey: "instructions") as? String else {
			print("[ERROR] Cannot decode character instructions")
			return nil
		}
		
		self.instructions = instructions
	}
}
