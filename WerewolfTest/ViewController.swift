//
//  ViewController.swift
//  WerewolfTest
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import UIKit
import WerewolfFramework

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet weak var gameStatusLabel: UILabel!
	@IBOutlet weak var characterLabel: UILabel!
	
	@IBOutlet weak var confirmActionButton: UIButton!
	@IBOutlet weak var startGameButton: UIButton!
	@IBOutlet weak var endGameButton: UIButton!
	
	var host: GameHost?
	var client: GameClient?
	
	var lastSelectedIndex: Int = 0

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		NotificationCenter.default.addObserver(forName: .stateUpdate, object: nil, queue: nil) { (notification) in
			self.statusUpdate()
		}
		
		NotificationCenter.default.addObserver(forName: .deviceConnected, object: nil, queue: nil) { (notification) in
			self.gameStatusLabel.text = "Connected. No Game"
		}
		
		NotificationCenter.default.addObserver(forName: .deviceDisconnected, object: nil, queue: nil) { (notification) in
			self.gameStatusLabel.text = "Disconnected"
		}
		
		MultipeerCommunication.shared.viewController = self
		
		self.client = GameClient()
		
		MultipeerCommunication.shared.delegate = self.client!
		
		self.gameStatusLabel.text = "Disconnected"
		self.characterLabel.text = ""
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
	
	@IBAction func confirmActionPressed(_ sender: Any) {
		guard let state = self.client?.state, let character = self.client?.character else {
			return
		}
		
		let selectedCount = self.tableView.indexPathsForSelectedRows?.count ?? 0
		
		if selectedCount != character.interactionCount {
			let alert = UIAlertController(title: "Alert", message: "\(character.name) requires \(character.interactionCount) selected cards", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (uiAlertAction) in
				alert.dismiss(animated: true, completion: nil)
			}))
			present(alert, animated: true, completion: nil)
			return
		}
		
		var actions = [WWActionData]()
		
		switch selectedCount {
		case 0:
			actions.append(WWActionData(first: nil, second: nil))
		case 1:
			actions.append(WWActionData(first: self.tableView.indexPathsForSelectedRows?[0].row, second: nil))
		case 2:
			actions.append(WWActionData(first: self.tableView.indexPathsForSelectedRows?[0].row, second: self.tableView.indexPathsForSelectedRows?[1].row))
		default:
			break
		}
		
		let action = WWAction(actions: actions)
		let peerData = PeerData(action: action)
		self.client?.send(data: peerData)
	}
	
	@IBAction func hostPressed(_ sender: Any) {
		MultipeerCommunication.shared.startBrowser()
		
		self.host = GameHost(client: self.client!)
		
		self.startGameButton.isEnabled = true
		self.endGameButton.isEnabled = true
	}
	
	@IBAction func startGamePressed(_ sender: Any) {
		self.host?.registerHostPlayer(with: "Host Player")
		self.host?.newGame(name: "Test Game Name")
	}
	
	@IBAction func endGamePressed(_ sender: Any) {
		self.host?.endGame()
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
		
		if state.status != .night || (character != nil && character!.selectionComplete) {
			self.tableView.allowsSelection = false
		}
		
		if character != nil && character!.selectionComplete {
			self.confirmActionButton.isEnabled = false
		} else {
			self.confirmActionButton.isEnabled = true
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
				if character.transferedCharacterName != nil {
					string += " (Was \(character.name); Became \(character.transferedCharacterName!))"
				} else {
					string += " (\(character.name))"
				}
			}
		} else if state.status != .nogame {
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
			} else if let name = playerCharacter.seenAssignments[indexPath.row] {
				string += " (\(name))"
			}
		} else {
			guard let character = state.playerAssignments[player] else {
				return UITableViewCell()
			}
			
			string += " (\(character.name))"
		}

		cell.textLabel?.text = state.players[indexPath.row].name + string
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		guard let state = self.client?.state, let character = self.client?.character else {
			return nil
		}
		
		let player = state.players[indexPath.row]
		
		if player == self.client?.player && !character.canSelectSelf {
			return nil
		}
		
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

