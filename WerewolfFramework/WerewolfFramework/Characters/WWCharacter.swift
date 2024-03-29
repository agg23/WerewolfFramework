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
    // TODO: Add
//	public var image: UIImage?

	public var turnOrder: TurnOrder
	public var orderNumber: Int = -1
	
	public var selectable: Viewable
	public var interactionCount: Int
	public var canSelectSelf: Bool
	
	public var defaultVisible: [WWCharacter.Type]
	public var defaultViewable: Viewable
	
	public var seenAssignments: [Int: String]
	
	public var transferedCharacterName: String?
	
	public var selectionComplete: Bool
	
	public var instructions: String
	
	public override required init() {
		self.name = "WWCharacter"
		self.turnOrder = .concurrent
		self.orderNumber = -1
		self.instructions = "Instructions"
		self.selectable = .none
		self.canSelectSelf = false
		self.interactionCount = 0
		self.defaultVisible = []
		self.defaultViewable = .none
		
		self.selectionComplete = false
		
		self.seenAssignments = [Int: String]()
	}
	
	public init(name: String, instructions: String, turnOrder: TurnOrder, orderNumber: Int, selectable: Viewable, interactionCount: Int, canSelectSelf: Bool, defaultVisible: [WWCharacter.Type], defaultViewable: Viewable) {
		self.name = name
		self.turnOrder = turnOrder
		self.orderNumber = orderNumber
		self.instructions = instructions
		self.selectable = selectable
		self.canSelectSelf = canSelectSelf
		self.interactionCount = interactionCount
		self.defaultVisible = defaultVisible
		self.defaultViewable = defaultViewable
		
		self.selectionComplete = false
		
		self.seenAssignments = [Int: String]()
	}
	
	/**
		Interprets the provided WWAction (typically created from the GUI) and mutates the WWState
	*/
	public func perform(action: WWAction, with state: WWState, playerIndex: Int) {
		print("[WARNING] Default action performed. Nothing was changed")
	}
	
	/**
		Performs any changes dictated by the current WWState before entering night, such as a solo Werewolf adding a selectable
	*/
	public func beginNight(with state: WWState) {
		self.selectionComplete = false
		self.seenAssignments = [Int: String]()
		self.transferedCharacterName = nil
	}
	
	/**
		Performs any changes dictated by the current WWState before entering discussion, such as Insomniac updating their roll
	*/
	public func beginDiscussion(with state: WWState, playerIndex: Int) {
		
	}
	
	/**
		Performs any necessary changes based on the provided WWAction. Returns true if updated state needs to be sent to the owning client
	*/
	public func received(action: WWAction, state: WWState) -> Bool {
		self.selectionComplete = true
		
		return true
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
		coder.encode(self.canSelectSelf, forKey: "selectself")
		
		var array = [String]()
		
		for type in self.defaultVisible {
			array.append(WWCharacter.characterClassToString(type))
		}
		
		coder.encode(array, forKey: "defaultVisible")
		coder.encode(self.defaultViewable.rawValue, forKey: "viewable")
		
//		var assignments = [Int: String]()
//		
//		for (int, type) in self.seenAssignments {
//			assignments[int] = WWCharacter.characterClassToString(type)
//		}
		
		coder.encode(self.seenAssignments, forKey: "seen")
		
		if self.transferedCharacterName != nil {
			coder.encode(self.transferedCharacterName, forKey: "transfered")
		}
		
		coder.encode(self.selectionComplete, forKey: "complete")
		
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
		self.canSelectSelf = decoder.decodeBool(forKey: "selectself")
		
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
		
		guard let seen = decoder.decodeObject(forKey: "seen") as? [Int: String] else {
			print("[ERROR] Cannot decode character seen")
			return nil
		}
		
//		var assignments = [Int: WWCharacter.Type]()
//		
//		for (int, typeString) in seen {
//			if let characterClass = WWCharacter.stringToCharacterClass(typeString) {
//				assignments[int] = characterClass
//			} else {
//				print("[WARNING] Could not decode character class string")
//			}
//		}
		
		self.seenAssignments = seen
		
		self.transferedCharacterName = decoder.decodeObject(forKey: "transfered") as? String
		
		self.selectionComplete = decoder.decodeBool(forKey: "complete")
		
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
		case "WWPI":
			return WWPI.self
		case "WWMason":
			return WWMason.self
		case "WWInsomniac":
			return WWInsomniac.self
		case "WWCopycat":
			return WWCopycat.self
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
		} else if characterClass == WWPI.self {
			return "WWPI"
		} else if characterClass == WWMason.self {
			return "WWMason"
		} else if characterClass == WWInsomniac.self {
			return "WWInsomniac"
		} else if characterClass == WWCopycat.self {
			return "WWCopycat"
		}
		
		return ""
	}
	
	public static func name(type: WWCharacter.Type) -> String {
		// TODO: Fix
		let character = instantiate(classType: type)
		return character.name
	}
	
	static func instantiate<T: WWCharacter>(classType: T.Type) -> WWCharacter {
		return classType.init()
	}
}
