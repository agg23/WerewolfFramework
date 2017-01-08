//
//  PeerData.swift
//  WerewolfTest
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation
import WerewolfFramework

class PeerData: NSObject, NSCoding {
	enum Command: Int {
		case registername
		case stateupdate
		case actionupdate
	}
	
	let command: Command
	
	let registeredName: String?
	let state: WWState?
	let action: WWAction?
	
	init(name: String) {
		self.registeredName = name
		self.command = .registername
		
		self.state = nil
		self.action = nil
	}
	
	init(state: WWState) {
		self.state = state
		self.command = .stateupdate
		
		self.registeredName = nil
		self.action = nil
	}
	
	init(action: WWAction) {
		self.action = action
		self.command = .actionupdate
		
		self.registeredName = nil
		self.state = nil
	}
	
	// MARK: NSCoding -
	
	func encode(with coder: NSCoder) {
		coder.encode(self.command.rawValue, forKey: "command")
		coder.encode(self.registeredName, forKey: "name")
		coder.encode(self.state, forKey: "state")
		coder.encode(self.action, forKey: "action")
	}
	
	required init?(coder decoder: NSCoder) {
		self.command = Command(rawValue: decoder.decodeInteger(forKey: "command")) ?? .registername
		
		self.registeredName = decoder.decodeObject(forKey: "name") as? String
		self.state = decoder.decodeObject(forKey: "state") as? WWState
		self.action = decoder.decodeObject(forKey: "action") as? WWAction
	}
}
