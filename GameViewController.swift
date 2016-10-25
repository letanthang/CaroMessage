//
//  GameViewController.swift
//  Flip
//
//  Created by Thang Le Tan on 9/20/16.
//  Copyright © 2016 Thang Le Tan. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Messages

class GameViewController: UIViewController {
    
    weak var delegate: MessagesViewController!
    
    var rowsString = ""
    
    var player = 0
    var row = 0
    var col = 0
    
    var caroGameScene: GameScene?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                caroGameScene = sceneNode
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode =  .aspectFit //.resizeFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
                    
                    sceneNode.loadRows(rowsString: rowsString)
                    sceneNode.loadLastMove(row: row, col: col)
                    sceneNode.loadPlayerTurn(index: player)
                    
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
    
    func load(message: MSMessage?) {
        guard let message = message else { return }
        guard let messageURL = message.url else { return }
        guard let components = URLComponents(url: messageURL, resolvingAgainstBaseURL: false) else { return }
        guard let queryItems = components.queryItems else { return }
        
        for item in queryItems {
            
            if item.name == "rows" {
                rowsString = item.value ?? ""
            } else if item.name == "player" {
                player = Int(item.value ?? "") ?? 0
            } else if item.name == "row" {
                row = Int(item.value ?? "") ?? 0
            } else if item.name == "col" {
                col = Int(item.value ?? "") ?? 0
            }
            
            
        }
        
    }
    

    @IBAction func sendTapped(_ sender: AnyObject) {
        
        guard let caroGameScene = caroGameScene else { return }
        let text = caroGameScene.getBoardRows()
        
        let player: Int =  Player.allPlayers.index(of: caroGameScene.board.currentPlayer)!
        
        let move = caroGameScene.board.lastMove
        
        delegate.createMessage(rowsString: text, player: player, row: move.row, col: move.col)
    }
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
