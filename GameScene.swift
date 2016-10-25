//
//  GameScene.swift
//  Flip
//
//  Created by Thang Le Tan on 9/20/16.
//  Copyright © 2016 Thang Le Tan. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var rows = [[Stone]]()
    
    var board: Board!
    
    var strategist: GKMonteCarloStrategist!
    var gameEnd = false
    
    private var label: SKSpriteNode?
    private var spinnyNode: SKShapeNode?
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        
        background.blendMode = .replace
        background.zPosition = 1
        addChild(background)
        
        let gameBoard = SKSpriteNode(imageNamed: "board")
        print("bg: \(background.size.width) x \(background.size.height)")
        print("gameBoard: \(gameBoard.size.width) x \(gameBoard.size.height)")
        gameBoard.name = "board"
        gameBoard.zPosition = 2
        
        addChild(gameBoard)
        
        board = Board()
        
        //1: Set up the constants for positioning
        
        let offsetX = -280
        let offsetY = -281
        let stoneSize = 80
        
        for row in 0 ..< Board.size {
            //2: count from 0 to 7, creating a new array of the stones
            var colArray = [Stone]()
            for col in 0 ..< Board.size {
                //3: create from 0 to 7, creating a new stone object
                let stone = Stone(color: UIColor.clear, size: CGSize(width: stoneSize, height: stoneSize))
                //4: place the stone at the correct position
                stone.position = CGPoint(x: offsetX + (col * stoneSize), y: offsetY + (row * stoneSize))
                //5: tell the stone its row and column
                stone.row = row
                stone.col = col
                //6: 
                
                gameBoard.addChild(stone)
                colArray.append(stone)
            }
            
            board.rows.append([StoneColor](repeatElement(.empty, count: Board.size)))
            rows.append(colArray)
            
//            strategist = GKMonteCarloStrategist()
//            strategist.budget = 100
//            strategist.explorationParameter = 1
//            strategist.randomSource = GKRandomSource.sharedRandom()
//            strategist.gameModel = board
            
            
        }
        
        
        /*
        rows[4][3].setPlayer(.white)
        rows[4][2].setPlayer(.black)
        rows[3][3].setPlayer(.white)
        rows[3][2].setPlayer(.black)
        
        board.rows[4][3] = .white
        board.rows[4][2] = .black
        board.rows[3][3] = .white
        board.rows[3][2] = .black
 
        */
        
        
        
    }
    
    
    func loadLastMove(row: Int, col: Int) {
        board.lastMove = Move(row: row, col: col)
    }
    
    func loadPlayerTurn(index: Int) {
        board.currentPlayer = Player.allPlayers[index]
    }
    
    func loadRows(rowsString: String) {
        
        var text = rowsString
        
        if rowsString.characters.count == 0 {
            text = "[[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,2,3,0,0,0,0],[0,0,2,3,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0]]"
        }
        
        do {
            if let data = text.data(using: String.Encoding.utf8) {
                if let rowsInt = try JSONSerialization.jsonObject(with: data, options: []) as? [[Int]] {
                    board.rows = rowsInt.map { $0.map { StoneColor(rawValue: $0)! }}
                    
                    for (x, row) in board.rows.enumerated() {
                        for (y, value) in row.enumerated() {
                            if value == .white || value == .black {
                                rows[x][y].setPlayer(value)
                            }
                        }
                    }
                    
                }
            }
        } catch (let error) {
            print("There was an error load rows: \(error.localizedDescription)")
        }
        
    }
    
    func getBoardRows() -> String {
        let rows = board.rows
        
        let rowsInt: [[Int]] = rows.map { $0.map { $0.hashValue } }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: rowsInt, options: [])
            let text = String(data: data, encoding: String.Encoding.utf8)
            
            return text ?? ""
            
        } catch (let error) {
            print("There was an error serialize rows: \(error.localizedDescription)")
        }
        
        return ""
        
    }
    
    
    
    
    
    override func sceneDidLoad() {

    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard gameEnd == false else {
            return
        }
        
        //1: unwrap the first touch
        guard let touch = touches.first else { return }
        
        //2: find the gameboard, or return if it somehow couldn't be found
        guard let gameBoard = childNode(withName: "board") else { return }
        //3: figure out where on the game board the touch landed
        let location = touch.location(in: gameBoard)
        
        //4: pull out an array of all nodes in that locaiton
        let nodesAtPoint = self.nodes(at: location)
        
        //5: filter out all nodes that arent Stone
        let tappedStones = nodesAtPoint.filter { $0 is Stone }
        
        //6: if no stone was tapped, bail out
        guard tappedStones.count > 0 else { return }
        let tappedStone = tappedStones[0] as! Stone
        
        //7: pass the tapped stones row and column into  canMoveOn()
        if board.canMoveIn(row: tappedStone.row, col: tappedStone.col) {
            //8: print a message if the move is legal
            makeMove(row: tappedStone.row, col: tappedStone.col)
            
            if board.currentPlayer.stoneColor == .white {
                //makeAIMove()
            }
            
            
            
        } else {
            print("Move is illegal")
        }
        
    }
    
    func makeMove(row: Int, col: Int) {
        //find the list of captured stones
        let captured = board.makeMove(player: board.currentPlayer, row: row, col: col)
        
        for move in captured {
            //pull out the sprite for each captured stone
            let stone = rows[move.row][move.col]
            //update who owns it
            stone.setPlayer(board.currentPlayer.stoneColor)
            //make it 120% of its normal size
            stone.xScale = 1.2
            stone.yScale = 1.2
            
            //animate it down to 100%
            stone.run(SKAction.scale(to: 1, duration: 0.5))
            
            
        }
        
        if board.checkWin() == true {
            print("We have a winner!")
            gameEnd = true
        }
        
        //change players
        board.currentPlayer = board.currentPlayer.opponent
    }
    
    func makeAIMove() {
        
        //1: push all the works to the background thread
        
        DispatchQueue.global().async {
            //2: get the current time
            let strategistTime = CFAbsoluteTimeGetCurrent()
            
            //3: calculate the best AI move
            
            guard let move = self.strategist.bestMoveForActivePlayer() as? Move else { return }
            
            //4: figure out how much time AI spend thinking
            let delta = CFAbsoluteTimeGetCurrent() - strategistTime
            
            //5: set the AI's chosen title to "thinking" texture
            DispatchQueue.main.async {
                self.rows[move.row][move.col].setPlayer(.choice)
                
                //6: wait for at least 3 second
                let aiTimeCeiling = 3.0
                
                let delay = min(aiTimeCeiling - delta, aiTimeCeiling)
                //7: after 3 seconds has passed, make the  move for real
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: { 
                    self.makeMove(row: move.row, col: move.col)
                })
            }
            
            
        }
        
    }
    
}
