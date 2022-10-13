//
//  ViewController.swift
//  LanguageImmersion
//
//  Created by Cassia Gulley on 3/10/2022.
//

import UIKit
import RealityKit
import ARKit
import MultipeerSession

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    var multipeerSession: MultipeerSession?
    var sessionIDObservation: NSKeyValueObservation?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//
//        // Load the "Box" scene from the "Experience" Reality File
//        let boxAnchor = try! Experience.loadBox()
//
//        // Add the box anchor to the scene
//        arView.scene.anchors.append(boxAnchor)
        
        setUpARView()
        setupMultipeerSession()
        
        arView.session.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        arView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setUpARView() {
        // Turn off ARView's automatically-configured session
        // to create and set up your own configuration.
        arView.automaticallyConfigureSession = false
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]

        // Enable realistic reflections.
        config.environmentTexturing = .automatic
        
        config.isCollaborationEnabled = true

        // Begin the session.
        arView.session.run(config)
    }
    
    func setupMultipeerSession() {
        // Use key-value observation to monitor your ARSession's identifier.
            sessionIDObservation = observe(\.arView.session.identifier, options: [.new]) { object, change in
                print("SessionID changed to: \(change.newValue!)")
                // Tell all other peers about your ARSession's changed ID, so
                // that they can keep track of which ARAnchors are yours.
                guard let multipeerSession = self.multipeerSession else { return }
                self.sendARSessionIDTo(peers: multipeerSession.connectedPeers)
            }
            
            // Start looking for other players via MultiPeerConnectivity.
        multipeerSession = MultipeerSession(serviceName: "language", receivedDataHandler: self.receivedData, peerJoinedHandler:
                                                self.peerJoined, peerLeftHandler: self.peerLeft, peerDiscoveredHandler: self.peerDiscovered)
        
        
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let anchor = ARAnchor(name: "box", transform: arView!.cameraTransform.matrix)
        arView.session.add(anchor: anchor)
    }
    
    func placeObject(named entityName: String, for anchor: ARAnchor) {
        // this line differs
        let boxAnchor = try! Experience.loadBox()
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(boxAnchor)
        arView.scene.addAnchor(anchorEntity)
        
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "box" {
                placeObject(named: anchorName, for: anchor)
            }
            
//            if let participantAnchor = anchor as? ARParticipantAnchor {
//                print("Successfully connected with another user")
//
//                let anchorEntity = AnchorEntity(anchor: participantAnchor)
//                let mesh = MeshResource.generateSphere(radius: 0.03)
//                let color: UIColor.red
//                let material = SimpleMaterial(color: color, isMetallic: false)
//                let coloredSphere = ModelEntity(mesh: mesh, materials: [material])
//
//                anchorEntity.addChild(coloredSphere)
//                arView.scene.addAnchor(anchor)
            }
    }
}

// MARK: Multipeer Session
extension ViewController {
    private func sendARSessionIDTo(peers: [PeerID]) {
        guard let multipeerSession = multipeerSession else { return }
        let idString = arView.session.identifier.uuidString
        let command = "SessionID:" + idString
        if let commandData = command.data(using: .utf8) {
            multipeerSession.sendToPeers(commandData, reliably: true, peers: peers)
        }
    }
    
    func receivedData(_ data: Data, from peer: PeerID) {
        guard let multipeerSession = multipeerSession else { return }
        if let collaborationData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARSession.CollaborationData.self, from: data) {
            arView.session.update(with: collaborationData)
            return
        }
        // ...
        let sessionIDCommandString = "SessionID:"
        if let commandString = String(data: data, encoding: .utf8), commandString.starts(with: sessionIDCommandString) {
            let newSessionID = String(commandString[commandString.index(commandString.startIndex,
                                                                     offsetBy: sessionIDCommandString.count)...])
            // If this peer was using a different session ID before, remove all its associated anchors.
            // This will remove the old participant anchor and its geometry from the scene.
            if let oldSessionID = multipeerSession.peerSessionIDs[peer] {
                removeAllAnchorsOriginatingFromARSessionWithID(oldSessionID)
            }
            
            multipeerSession.peerSessionIDs[peer] = newSessionID
        }
    }
    
    func peerDiscovered(_ peer: PeerID) -> Bool {
          guard let multipeerSession = multipeerSession else { return false }
          
          if multipeerSession.connectedPeers.count > 3 {
              // Do not accept more than four users in the experience.
              print("A fifth peer wants to join the experience.\nThis app is limited to four users.")
              return false
          } else {
              return true
          }
      }
    
    func peerJoined(_ peer: PeerID) {
         print("""
             A peer has joined the experience.
             Hold the phones next to each other.
             """)
         // Provide your session ID to the new user so they can keep track of your anchors.
         sendARSessionIDTo(peers: [peer])
     }
    
    func peerLeft(_ peer: PeerID) {
        guard let multipeerSession = multipeerSession else { return }
        print("A peer has left the shared experience.")
        
        // Remove all ARAnchors associated with the peer that just left the experience.
        if let sessionID = multipeerSession.peerSessionIDs[peer] {
            removeAllAnchorsOriginatingFromARSessionWithID(sessionID)
            multipeerSession.peerSessionIDs.removeValue(forKey: peer)
        }
    }
    
    private func removeAllAnchorsOriginatingFromARSessionWithID(_ identifier: String) {
        guard let frame = arView.session.currentFrame else { return }
        for anchor in frame.anchors {
            guard let anchorSessionID = anchor.sessionIdentifier else { continue }
            if anchorSessionID.uuidString == identifier {
                arView.session.remove(anchor: anchor)
            }
        }
    }
    
    func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
        guard let multipeerSession = multipeerSession else { return }
        
        if !multipeerSession.connectedPeers.isEmpty {
            guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
            else { fatalError("Unexpectedly failed to encode collaboration data.")}
            let dataIsCritical = data.priority == .critical
            multipeerSession.sendToAllPeers(encodedData, reliably: dataIsCritical)
        } else {
            print("Deferred sending collaboration to later because there are no peers")
        }
    }
    
}
