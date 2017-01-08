//
//  ViewController.swift
//  WerewolfTest
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet weak var textField: UITextField!
	
	var host: GameHost?
	var client: GameClient?

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
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
	
	@IBAction func sendMessageToAllPressed(_ sender: Any) {
		MultipeerCommunication.shared.sendToAll(message: "Hello world".data(using: .utf8)!)
	}
	
	@IBAction func sendMessageToHostPressed(_ sender: Any) {
		MultipeerCommunication.shared.sendToHost(message: "Host only message".data(using: .utf8)!)
	}
	
	@IBAction func hostPressed(_ sender: Any) {
		MultipeerCommunication.shared.startBrowser()
		
		self.host = GameHost(client: self.client!)
	}
	
	@IBAction func startGamePressed(_ sender: Any) {
		self.host?.registerHostPlayer(with: "Host Player")
		self.host?.newGame(name: "Test Game Name")
	}
}

