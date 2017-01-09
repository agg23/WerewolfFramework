//
//  ViewController.swift
//  WerewolfTest
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet weak var gameStatusLabel: UILabel!
	@IBOutlet weak var characterLabel: UILabel!
	
	var host: GameHost?
	var client: GameClient?
	
	var lastSelectedIndex: Int = 0

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		NotificationCenter.default.addObserver(forName: .stateUpdate, object: nil, queue: nil) { (notification) in
			self.statusUpdate()
		}
		
		MultipeerCommunication.shared.viewController = self
		
		self.client = GameClient()
		
		MultipeerCommunication.shared.delegate = self.client!
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func startAdvertisingPressed(_ sender: Any) {
		if let text = textField.text, text != "" {
			MultipeerCommunication.shared.displayName = text
		}
		
		MultipeerCommunication.shared.startAdvertising()
	}
	
	@IBAction func hostPressed(_ sender: Any) {
		MultipeerCommunication.shared.startBrowser()
		
		self.host = GameHost(client: self.client!)
	}
	
	@IBAction func startGamePressed(_ sender: Any) {
		self.host?.registerHostPlayer(with: "Host Player")
		self.host?.newGame(name: "Test Game Name")
	}
	
	func statusUpdate() {
		self.tableView.reloadData()
		
		guard let client = self.client else {
			return
		}
		
		guard let state = client.state else {
			return
		}
		
		switch state.status {
		case .nogame:
			self.gameStatusLabel.text = "No Active Game"
		case .starting:
			self.gameStatusLabel.text = "Game Starting"
		case .night:
			self.gameStatusLabel.text = "Night"
		case .discussion:
			self.gameStatusLabel.text = "Discussion"
		}
		
		let character = client.character
		
		self.characterLabel.text = character?.name
		
		if character?.interactionCount == 0 {
			self.tableView.allowsSelection = false
		} else {
		self.tableView.allowsMultipleSelection = true
		}
	}
	
	// MARK: - UITableViewDelegate
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let state = self.client?.state else {
			print("[WARNING] No state for table view")
			return UITableViewCell()
		}
		
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
			// Should never occur
			return UITableViewCell()
		}
		
		var string = ""
		let player = state.players[indexPath.row]
		if player == self.client!.player {
			string = " - You"
			
			if let character = self.client!.character {
				string += " (\(character.name))"
			}
		} else {
			guard let playerCharacter = self.client!.character, let character = state.playerAssignments[player] else {
				return UITableViewCell()
			}
			
			if playerCharacter.defaultViewable(player: player) {
				var contains = false
				for characterType in playerCharacter.defaultVisible {
					let type: Any.Type = Mirror(reflecting: character).subjectType
					
					if characterType == type {
						contains = true
						break
					}
				}
				
				if contains {
					string += " (\(character.name))"
				}
			}
		}

		cell.textLabel?.text = state.players[indexPath.row].name + string
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		guard let state = self.client?.state else {
			return nil
		}
		
		guard let character = self.client?.character else {
			return nil
		}
		
		let player = state.players[indexPath.row]
		
		let selectedCount = (tableView.indexPathsForSelectedRows?.count ?? 0) + 1
		
		if character.interactionCount == 0 || !character.selectable(player: player) {
			return nil
		}
		
		if selectedCount > character.interactionCount {
			tableView.deselectRow(at: IndexPath(row: self.lastSelectedIndex, section: 0), animated: false)
		}
		
		return indexPath
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.lastSelectedIndex = indexPath.row
	}
	
	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		self.lastSelectedIndex = 0
	}
	
	// MARK: - UITableViewDataSource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let client = self.client, let state = client.state {
			return state.players.count
		}
		
		return 0
	}
}

