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
	
	public enum Viewable: Int {
		case all
		case humanOnly
		case nonHumanOnly
		case none
	}
	
	public var name: String
	public var image: UIImage?
	public var turnOrder: TurnOrder
	public var viewable: Viewable
	public var interactionCount: Int
	
	public var instructions: String
	
	public init(name: String, instructions: String, turnOrder: TurnOrder, viewable: Viewable, interactionCount: Int) {
		self.name = name
		self.turnOrder = turnOrder
		self.instructions = instructions
		self.viewable = viewable
		self.interactionCount = interactionCount
	}
	
	/**
		Interprets the provided WWAction (typically created from the GUI) and mutates the WWState
	*/
	public func perform(action: WWAction, with state: WWState) {
		print("[WARNING] Default action performed. Nothing was changed")
	}
	
	public func viewable(player: WWPlayer) -> Bool {
		switch self.viewable {
		case .all:
			return true
		case .none:
			return false
		case .humanOnly:
			return player.isHumanPlayer
		case .nonHumanOnly:
			return !player.isHumanPlayer
		}
	}
	
	public static func ==(lhs: WWCharacter, rhs: WWCharacter) -> Bool {
		return lhs.turnOrder == rhs.turnOrder && lhs.name == rhs.name
	}
	
	// MARK: - NSCoding
	
	public func encode(with coder: NSCoder) {
		coder.encode(self.name, forKey: "name")
		
		coder.encode(self.turnOrder.rawValue, forKey: "order")
		coder.encode(self.viewable.rawValue, forKey: "limit")
		coder.encode(self.interactionCount, forKey: "count")
		
		coder.encode(self.instructions, forKey: "instructions")
	}
	
	public required init?(coder decoder: NSCoder) {
		guard let name = decoder.decodeObject(forKey: "name") as? String else {
			print("[ERROR] Cannot decode character name")
			return nil
		}
		
		self.name = name
				
		self.turnOrder = TurnOrder(rawValue: decoder.decodeInteger(forKey: "order")) ?? .inactive
		self.viewable = Viewable(rawValue: decoder.decodeInteger(forKey: "limit")) ?? .none
		self.interactionCount = decoder.decodeInteger(forKey: "count")
		
		guard let instructions = decoder.decodeObject(forKey: "instructions") as? String else {
			print("[ERROR] Cannot decode character instructions")
			return nil
		}
		
		self.instructions = instructions
	}
}
