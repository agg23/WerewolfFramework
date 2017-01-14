//
//  CharacterSelectViewController.swift
//  WerewolfTest
//
//  Created by Adam Gastineau on 1/14/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import UIKit

class CharacterSelectViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
	
	@IBAction func backPressed(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	// MARK: - UICollectionViewDataSource
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CharacterCollectionViewCell
		
		cell.label.text = "Hi"
		
		return cell
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 10
	}
	
	// MARK: - UICollectionViewDelegateFlowLayout
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let itemsPerRow = 6
		let paddingSpace = Int(self.sectionInsets.left) * (itemsPerRow + 1)
		let availableWidth = Int(self.view.frame.width) - paddingSpace
		let widthPerItem = availableWidth / itemsPerRow
		
		return CGSize(width: widthPerItem, height: widthPerItem)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return self.sectionInsets
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return self.sectionInsets.left
	}
}
