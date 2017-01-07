//
//  MultipeerCommunication.swift
//  WerewolfTest
//
//  Created by Adam Gastineau on 1/7/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MultipeerCommunication: NSObject, MCNearbyServiceAdvertiserDelegate, MCBrowserViewControllerDelegate, MCSessionDelegate {
	static let shared = MultipeerCommunication()
	
	private static let serviceType = "were2-service"
	
	var displayName: String {
		didSet {
			self.localPeerID = MCPeerID(displayName: self.displayName)
			
			self.advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: nil, serviceType: MultipeerCommunication.serviceType)
			
			self.browser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: MultipeerCommunication.serviceType)
			
			self.session = MCSession(peer: localPeerID, securityIdentity: nil, encryptionPreference: .none)
			
			self.advertiser.delegate = self
			self.session.delegate = self
		}
	}
	
	private var localPeerID: MCPeerID
	private var advertiser: MCNearbyServiceAdvertiser
	private var browser: MCNearbyServiceBrowser
	
	private var session: MCSession
	
	private var blockedPeers: Array<MCPeerID>
	
	var viewController: UIViewController?
	
	private var browserViewController: MCBrowserViewController?
	
	private var host: MCPeerID?
	private var isHost: Bool
	
	override init() {
		self.displayName = UIDevice.current.name
		self.localPeerID = MCPeerID(displayName: self.displayName)
		
		self.advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: nil, serviceType: MultipeerCommunication.serviceType)
		
		self.browser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: MultipeerCommunication.serviceType)
//		self.browser.delegate = self
		
		self.session = MCSession(peer: localPeerID, securityIdentity: nil, encryptionPreference: .none)
		
		self.blockedPeers = Array()
		
		self.isHost = false
		
		super.init()
		self.advertiser.delegate = self
		self.session.delegate = self
	}
	
	func startAdvertising() {
		self.advertiser.startAdvertisingPeer()
	}
	
	func startBrowser() {
		self.isHost = true
		self.browserViewController = MCBrowserViewController(browser: self.browser, session: self.session)
		self.browserViewController?.delegate = self
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
	
	private func send(message: Data, to hosts: [MCPeerID]) {
		do {
			try self.session.send(message, toPeers: hosts, with: .reliable)
		}
		catch {
			print("[Error] \(error)")
		}
	}
	
	// MARK: MCSessionDelegate -
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		if let string = String(data: data, encoding: .utf8) {
			print(string)
		}
	}
	
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		switch state {
		case .connected:
			print("State Connected")
		case .connecting:
			print("State connecting")
		case .notConnected:
			print("State not connected")
		}
		
		if state == .connected && !self.isHost {
			self.host = peerID
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
	
	// MARK: MCNearbyServiceAdvertiserDelegate -
	
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
	                didReceiveInvitationFromPeer peerID: MCPeerID,
	                withContext context: Data?,
	                invitationHandler: @escaping (Bool, MCSession?) -> Void) {
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
		let blockAction = UIAlertAction(title: NSLocalizedString("Block", comment: ""), style: .destructive) { [weak self] _ in
			self?.blockedPeers.append(peerID)
			invitationHandler(false, nil)
		}
		let acceptAction = UIAlertAction(title: NSLocalizedString("Accept", comment: ""), style: .default) { _ in
			invitationHandler(true, self.session)
		}
		
		alertController.addAction(cancelAction)
		alertController.addAction(blockAction)
		alertController.addAction(acceptAction)
		self.viewController?.present(alertController, animated: true, completion: nil)
	}
	
	// MARK: MCBrowserViewControllerDelegate -
	
	func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
		print("Browser view controller finished")
		self.browserViewController?.dismiss(animated: true, completion: nil)
	}
	
	func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
		print("Browser view controller canceled")
		self.browserViewController?.dismiss(animated: true, completion: nil)
	}
}