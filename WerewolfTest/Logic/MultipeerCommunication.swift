//
//  MultipeerCommunication.swift
//  WerewolfTest
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MultipeerCommunication: NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCBrowserViewControllerDelegate, MCSessionDelegate {
	static let shared = MultipeerCommunication()
	
	private static let serviceType = "were2-service"
	
	let displayName: String
//		didSet {
//			displayNameUpdate()
//			
//			self.advertiser.delegate = self
//			self.session.delegate = self
//		}
//	}
	
	var localPeerID: MCPeerID
	private var advertiser: MCNearbyServiceAdvertiser
	private var browser: MCNearbyServiceBrowser
	
	private var session: MCSession
	
	private var blockedPeers: Array<MCPeerID>
	
	var viewController: UIViewController?
	
	private var browserViewController: MCBrowserViewController?
	
	private var host: MCPeerID?
	var isHost: Bool
	
	var delegate: MCDelegate?
	
	override init() {
		self.displayName = UIDevice.current.name
		
		// Prevents duplicate devices showing up in browser
		let id = UserDefaults.standard.data(forKey: "peerID")
		if id != nil {
			self.localPeerID = NSKeyedUnarchiver.unarchiveObject(with: id!) as! MCPeerID
		} else {
			self.localPeerID = MCPeerID(displayName: self.displayName)
			UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: self.localPeerID), forKey: "peerID")
		}
		
		self.advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: nil, serviceType: MultipeerCommunication.serviceType)
		
		self.browser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: MultipeerCommunication.serviceType)
		
		self.session = MCSession(peer: localPeerID, securityIdentity: nil, encryptionPreference: .none)
		
		self.blockedPeers = Array()
		
		self.isHost = false
		
		super.init()
		self.advertiser.delegate = self
		self.session.delegate = self
	}
	
//	private func displayNameUpdate() {
//		self.localPeerID = MCPeerID(displayName: self.displayName)
//		
//		self.advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: nil, serviceType: MultipeerCommunication.serviceType)
//		
//		self.browser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: MultipeerCommunication.serviceType)
//		
//		self.session = MCSession(peer: localPeerID, securityIdentity: nil, encryptionPreference: .none)
//	}
	
	func startAdvertising() {
		self.advertiser.startAdvertisingPeer()
	}
	
	func startBrowser() {
		self.isHost = true
		
		if self.browserViewController == nil {
			self.browserViewController = MCBrowserViewController(browser: self.browser, session: self.session)
			self.browserViewController?.delegate = self
		}
		self.viewController?.present(self.browserViewController!, animated: true) {
			self.browser.startBrowsingForPeers()
		}
	}
	
	func sendToAll(message: Data) {
		send(message: message, to: self.session.connectedPeers)
	}
	
	func sendToHost(message: Data) {
		if self.isHost || self.host == nil {
			print("No valid host to send to")
			return
		}
		
		send(message: message, to: [self.host!])
	}
	
	func send(message: Data, to id: String) {
		for peer in self.session.connectedPeers {
			if peer.displayName == id {
				send(message: message, to: [peer])
				return
			}
		}
		
		print("[ERROR] No peer by id \(id)")
	}
	
	private func send(message: Data, to hosts: [MCPeerID]) {
		do {
			try self.session.send(message, toPeers: hosts, with: .reliable)
		}
		catch {
			print("[ERROR] \(error)")
		}
	}
	
	func disconnect() {
		self.session.disconnect()
	}
	
	// MARK: - MCSessionDelegate
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		self.delegate?.messageReceived(data: data, from: peerID.displayName)
		
		if let string = String(data: data, encoding: .utf8) {
			print("Received message: " + string)
		}
	}
	
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		switch state {
		case .connected:
			print("Device Connected")
		case .connecting:
			print("Device Connecting")
		case .notConnected:
			print("Device Not Connected")
		}
		
		DispatchQueue.main.async {
			if state == .connected {
				if !self.isHost && self.host == nil {
					// Only set host if this is not the host and the host isn't already set
					print("Set host to \(peerID.displayName)")
					self.host = peerID
				}
				
				NotificationCenter.default.post(name: .deviceConnected, object: peerID.displayName)
				self.delegate?.connected(device: peerID.displayName)
			} else if state == .notConnected {
				if session.connectedPeers.count == 0 {
					self.isHost = false
				}
				
				NotificationCenter.default.post(name: .deviceDisconnected, object: peerID.displayName)
				self.delegate?.disconnected(device: peerID.displayName)
			}
		}
	}
	
	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		print("Byte stream opened")
	}
	
	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
		print("Started receiving file")
	}
	
	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
		print("Finished receiving file")
	}
	
	func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
		certificateHandler(true)
	}
	
	// MARK: - MCNearbyServiceAdvertiserDelegate
	
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
		
		if self.blockedPeers.contains(peerID) {
			invitationHandler(false, nil)
			return
		}
		
		let alertController = UIAlertController(title:
			NSLocalizedString("Received invitation from \(peerID.displayName)", comment: "Received invitation from {Peer}"),
		                                        message: nil, preferredStyle: .actionSheet)
		let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
			invitationHandler(false, nil)
		}
		let acceptAction = UIAlertAction(title: NSLocalizedString("Accept", comment: ""), style: .default) { _ in
			invitationHandler(true, self.session)
		}
		
		alertController.addAction(cancelAction)
		alertController.addAction(acceptAction)
		self.viewController?.present(alertController, animated: true, completion: nil)
	}
	
	// MARK: - MCNearbyServiceBrowserDelegate
	
	func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		print("Peer lost")
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		print("Peer found")
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
		print("Did not start")
	}
	
	// MARK: - MCBrowserViewControllerDelegate
	
	func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
		print("Browser view controller finished")
		self.browserViewController?.dismiss(animated: true, completion: nil)
		self.browser.stopBrowsingForPeers()
	}
	
	func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
		print("Browser view controller canceled")
		self.browserViewController?.dismiss(animated: true, completion: nil)
		self.browser.stopBrowsingForPeers()
	}
	
	func browserViewController(_ browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) -> Bool {
		return true
	}
}
