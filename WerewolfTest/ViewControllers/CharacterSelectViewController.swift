//
//  CharacterSelectViewController.swift
//  WerewolfTest
//
//  Created by Adam Gastineau on 1/14/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import UIKit
import WerewolfFramework

class CharacterSelectViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
	var host: GameHost?
	var client: GameClient?
	var initialLoad = true
	
	let availableCharacters: [WWCharacter.Type] = [WWCopycat.self, WWWerewolf.self, WWWerewolf.self, WWMinion.self, WWMason.self, WWMason.self, WWSeer.self, WWPI.self, WWRobber.self, WWWitch.self, WWTroublemaker.self, WWInsomniac.self]
	
	var enabledCharacters = [WWCharacter.Type]()
	
	override func viewDidLoad() {
		self.collectionView?.allowsMultipleSelection = true
	}
	
	override func viewWillAppear(_ animated: Bool) {
		// Temporarily store registered characters (for processing duplicates)
		if let host = self.host {
			self.enabledCharacters = host.enabledCharacters
		} else if let client = self.client, let state = client.state {
			let characters = state.characters
			
			for character in characters {
				self.enabledCharacters.append(type(of: character))
			}
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		self.initialLoad = false
	}
	
	@IBAction func backPressed(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	// MARK: - UICollectionViewDataSource
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CharacterCollectionViewCell
		
		let type = self.availableCharacters[indexPath.row]
		
		cell.label.text = WWCharacter.name(type: type)
		
		// Select initial characters
		if self.initialLoad {
			for i in 0 ..< self.enabledCharacters.count {
				let characterType = self.enabledCharacters[i]
				if type == characterType {
					cell.isSelected = true
					collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .bottom)
					cell.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
					
					self.enabledCharacters.remove(at: i)
					break
				}
			}
		}
		
		return cell
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.availableCharacters.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		return self.host != nil
	}
	
	override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
		return self.host != nil
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.cellForItem(at: indexPath)?.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
		
		self.host?.register(character: self.availableCharacters[indexPath.row])
	}
	
	override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.white
		
		self.host?.remove(character: self.availableCharacters[indexPath.row])
	}
	
	// MARK: - UICollectionViewDelegateFlowLayout
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//		let itemsPerRow = 6
//		let paddingSpace = Int(self.sectionInsets.left) * (itemsPerRow + 1)
//		let availableWidth = Int(self.view.frame.width) - paddingSpace
//		let widthPerItem = availableWidth / itemsPerRow
//		
//		return CGSize(width: widthPerItem, height: widthPerItem)
		return CGSize(width: 100, height: 100)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return self.sectionInsets
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return self.sectionInsets.left
	}
}
