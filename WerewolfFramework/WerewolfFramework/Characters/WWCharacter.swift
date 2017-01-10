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
	public var selectable: Viewable
	public var interactionCount: Int
	
	public var defaultVisible: [WWCharacter.Type]
	public var defaultViewable: Viewable
	
	public var instructions: String
	
	public init(name: String, instructions: String, turnOrder: TurnOrder, selectable: Viewable, interactionCount: Int, defaultVisible: [WWCharacter.Type], defaultViewable: Viewable) {
		self.name = name
		self.turnOrder = turnOrder
		self.instructions = instructions
		self.selectable = selectable
		self.interactionCount = interactionCount
		self.defaultVisible = defaultVisible
		self.defaultViewable = defaultViewable
	}
	
	/**
		Interprets the provided WWAction (typically created from the GUI) and mutates the WWState
	*/
	public func perform(action: WWAction, with state: WWState) {
		print("[WARNING] Default action performed. Nothing was changed")
	}
	
	/**
		Performs any changes dictated by the current WWState, such as a solo Werewolf adding a selectable
	*/
	public func beginNight(with state: WWState) {
		
	}
	
	/**
		Performs any necessary changes based on the provided WWAction. Returns true if updated state needs to be sent to the owning client
	*/
	public func received(action: WWAction) -> Bool {
		return false
	}
	
	public func selectable(player: WWPlayer) -> Bool {
		return viewable(player: player, viewable: self.selectable)
	}
	
	public func defaultViewable(player: WWPlayer) -> Bool {
		return viewable(player: player, viewable: self.defaultViewable)
	}
	
	private func viewable(player: WWPlayer, viewable: Viewable) -> Bool {
		switch viewable {
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
		coder.encode(self.selectable.rawValue, forKey: "selectable")
		coder.encode(self.interactionCount, forKey: "count")
		
		var array = [String]()
		
		for type in self.defaultVisible {
			array.append(WWCharacter.characterClassToString(type))
		}
		
		coder.encode(array, forKey: "defaultVisible")
		coder.encode(self.defaultViewable.rawValue, forKey: "viewable")
		
		coder.encode(self.instructions, forKey: "instructions")
	}
	
	public required init?(coder decoder: NSCoder) {
		guard let name = decoder.decodeObject(forKey: "name") as? String else {
			print("[ERROR] Cannot decode character name")
			return nil
		}
		
		self.name = name
				
		self.turnOrder = TurnOrder(rawValue: decoder.decodeInteger(forKey: "order")) ?? .inactive
		self.selectable = Viewable(rawValue: decoder.decodeInteger(forKey: "selectable")) ?? .none
		self.interactionCount = decoder.decodeInteger(forKey: "count")
		
		guard let visible = decoder.decodeObject(forKey: "defaultVisible") as? [String] else {
			print("[ERROR] Cannot decode character default visible")
			return nil
		}
		
		var array = [WWCharacter.Type]()
		
		for type in visible {
			if let characterClass = WWCharacter.stringToCharacterClass(type) {
				array.append(characterClass)
			}
		}
		
		self.defaultVisible = array
		self.defaultViewable = Viewable(rawValue: decoder.decodeInteger(forKey: "viewable")) ?? .none
		
		guard let instructions = decoder.decodeObject(forKey: "instructions") as? String else {
			print("[ERROR] Cannot decode character instructions")
			return nil
		}
		
		self.instructions = instructions
	}
	
	private static func stringToCharacterClass(_ string: String) -> WWCharacter.Type? {
		switch string {
		case "WWWerewolf":
			return WWWerewolf.self
		case "WWMinion":
			return WWMinion.self
		case "WWSeer":
			return WWSeer.self
		case "WWWitch":
			return WWWitch.self
		case "WWTroublemaker":
			return WWTroublemaker.self
		default:
			return nil
		}
	}
	
	private static func characterClassToString(_ characterClass: WWCharacter.Type) -> String {
		if characterClass == WWWerewolf.self {
			return "WWWerewolf"
		} else if characterClass == WWMinion.self {
			return "WWMinion"
		} else if characterClass == WWSeer.self {
			return "WWSeer"
		} else if characterClass == WWWitch.self {
			return "WWWitch"
		} else if characterClass == WWTroublemaker.self {
			return "WWTroublemaker"
		}
		
		return ""
	}
}
