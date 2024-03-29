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
	
	@IBOutlet weak var startAdvertisingButton: UIButton!
	@IBOutlet weak var confirmActionButton: UIButton!
	@IBOutlet weak var hostButton: UIButton!
	@IBOutlet weak var startGameButton: UIButton!
	@IBOutlet weak var endGameButton: UIButton!
	
	var host: GameHost?
	var client: GameClient?
	
	var lastSelectedIndex: Int = 0
	
	var confirmedSelections = Set<Int>()

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
		
		NotificationCenter.default.addObserver(forName: .deviceConnectionRequest, object: nil, queue: nil) { (notification) in
			guard let alertController = notification.object as? UIAlertController else {
				print("[ERROR] Invalid object for device connection")
				return
			}
			
			alertController.popoverPresentationController?.sourceView = self.startAdvertisingButton
			alertController.popoverPresentationController?.sourceRect = self.startAdvertisingButton.bounds
			self.present(alertController, animated: true, completion: nil)
		}
		
		MultipeerCommunication.shared.viewController = self
		
		self.client = GameClient()
		
		MultipeerCommunication.shared.delegate = self.client!
		
		self.textField.text = UIDevice.current.name
		
		self.gameStatusLabel.text = "Disconnected"
		self.characterLabel.text = ""
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func setNamePressed(_ sender: Any) {
		if let text = self.textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), text != "" {
			self.client!.name = text
			self.startAdvertisingButton.isEnabled = true
			self.hostButton.isEnabled = true
			self.textField.endEditing(true)
		}
	}

	@IBAction func startAdvertisingPressed(_ sender: Any) {
		self.hostButton.isEnabled = false
		
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
			let first = self.tableView.indexPathsForSelectedRows![0].row
			actions.append(WWActionData(first: first, second: nil))
			self.confirmedSelections.formUnion([first])
		case 2:
			let first = self.tableView.indexPathsForSelectedRows![0].row
			let second = self.tableView.indexPathsForSelectedRows![1].row
			actions.append(WWActionData(first: first, second: second))
			self.confirmedSelections.formUnion([first, second])
		default:
			break
		}
		
		let action = WWAction(actions: actions)
		let peerData = PeerData(action: action)
		self.client?.send(data: peerData)
	}
	
	@IBAction func hostPressed(_ sender: Any) {
		MultipeerCommunication.shared.startBrowser()
		
		if self.host == nil {
			self.host = GameHost(client: self.client!)
		}
		
		self.startGameButton.isEnabled = true
		self.endGameButton.isEnabled = true
		self.startAdvertisingButton.isEnabled = false
	}
	
	@IBAction func startGamePressed(_ sender: Any) {
		var hostName = self.client?.name
		
		if hostName == nil {
			hostName = "Host Player"
		}
		
		self.host?.registerHostPlayer(with: hostName!)
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
			// Clear selections
			self.confirmedSelections = Set<Int>()
		case .night:
			self.gameStatusLabel.text = "Night"
		case .discussion:
			self.gameStatusLabel.text = "Discussion"
		}
		
		let character = client.character
		
		var string = ""
		
		if let character = self.client!.character {
			if character.transferedCharacterName != nil {
				string += "\(character.transferedCharacterName!) (was \(character.name))"
			} else {
				string += "\(character.name)"
			}
		}
		
		self.characterLabel.text = string
		
		if character?.interactionCount == 0 {
			self.tableView.allowsSelection = false
		} else {
			self.tableView.allowsSelection = true
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
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "characterSelectSegue" {
			let characterSelectViewController = segue.destination as! CharacterSelectViewController
			characterSelectViewController.host = self.host
			characterSelectViewController.client = self.client
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
			
			if state.status == .nogame, let name = character.transferedCharacterName {
				string += " (\(name); was \(character.name))"
			} else {
				string += " (\(character.name))"
			}
		}

		cell.textLabel?.text = state.players[indexPath.row].name + string
		
		if self.confirmedSelections.contains(indexPath.row) {
			cell.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
		} else {
			cell.backgroundColor = UIColor.white
		}
		
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

