//
//  Board.swift
//  Flip
//
//  Created by Thang Le Tan on 9/26/16.
//  Copyright © 2016 Thang Le Tan. All rights reserved.
//

import UIKit
import GameplayKit

class Board: NSObject, GKGameModel {
    
    var players: [GKGameModelPlayer]? {
        return Player.allPlayers
    }
    
    var activePlayer: GKGameModelPlayer? {
        return currentPlayer
    }
    
    static let size = 8
    
    static let moves = [Move(row: 0, col: 1), Move(row: 1, col: 1), Move(row: 1, col: 0), Move(row: 1, col: -1)]
    
    var currentPlayer = Player.allPlayers[0]
    
    var rows = [[StoneColor]]()
    
    var lastMove = Move(row: 0, col: 0) //dump init var
    
    func canMoveIn(row: Int, col: Int) -> Bool {
        //test 1: check if the move is sensible (not out of bound/range)
        
        if !isInBound(row: row, col: col) { return false }
        //test 2: check that the move hasnt been made already
        
        let stone = rows[row][col]
        if stone != .empty { return false }
        
        return true
        
        
    }
    
    var rowsInt = [[Int]]()
    
    func isInBound(row: Int, col: Int) -> Bool {
        
        if row < 0 { return false }
        if col < 0 { return false }
        if row >= Board.size { return false }
        if col >= Board.size { return false }
        
        return true
    }
    
    func makeMove(player: Player, row: Int, col: Int) -> [Move] {
        
        var tests = [[Int]]()
        
        //tests = rows.map { $0.map { StoneColor.$0.rawValue } }
        
        if let data = try? JSONSerialization.data(withJSONObject: tests, options: []) {
            let text = String(data: data, encoding: String.Encoding.utf8)
            print(text)
        }
        
        
        //1: create an array to hold all the captured stones
        var didCapture = [Move]()
        //2: place the stone in the requested position
        rows[row][col] = player.stoneColor
        
        lastMove = Move(row: row, col: col)
        
        didCapture.append(lastMove)
        //10: send back the list of of captured stones
        return didCapture
    }
    
    func getScores() -> (black: Int, white: Int) {
        var black = 0
        var white = 0
        
        rows.forEach {
            $0.forEach {
                if $0 == .black {
                    black += 1
                } else if $0 == .white {
                    white += 1
                }
            }
        }
        return (black, white)
    }
    
    func checkWin() -> Bool {
        //print(currentPlayer.stoneColor)
        return isWin(for: currentPlayer)
    }
    
    func isWin(for player: GKGameModelPlayer) -> Bool {
        
        let row = lastMove.row
        let col = lastMove.col
        
        guard let player = player as? Player else { return false }
        
        for move in Board.moves {
            //3: look in this direction for  captured stones
            
            
            
            var count = 0
            
            //move up and down
            
            for way in [1,-1] {
                
                var currentRow = row
                var currentCol = col
                
                for _ in 0 ..< Board.size {
                    
                    currentRow += move.row * way
                    currentCol += move.col * way
                    
                    //5: make sure this is a sensible position to move to
                    
                    guard isInBound(row: currentRow, col: currentCol) else { break }
                    
                    
                    let stone = rows[currentRow][currentCol]
                    
                    if stone == player.stoneColor {
                        count += 1
                    } else {
                        break
                    }
                }
                
            }
            
            if count == 4 {
                return true
            }
            
        }
        
        return false

    }
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        //safely unwrap the player object
        guard let playerObject = player as? Player else { return nil }
        
        //if the game is over, exit now
        if isWin(for: playerObject) || isWin(for: playerObject.opponent) {
            return nil
        }
        
        
        //if we're still here prepare to send back a list of moves
        
        var moves = [Move]()
        
        //try every column in every row
        for row in  0 ..< Board.size {
            for col in 0 ..< Board.size {
                if canMoveIn(row: row, col: col) {
                    moves.append(Move(row: row, col: col))
                }
            }
        }
        
        return moves
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        guard let move = gameModelUpdate as? Move else { return }
        
        _ = makeMove(player: currentPlayer, row: move.row, col: move.col)
        
        currentPlayer = currentPlayer.opponent
    }
    
    func setGameModel(_ gameModel: GKGameModel) {
        guard let board = gameModel as? Board else { return }
        
        currentPlayer = board.currentPlayer
        
        rows = board.rows
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Board()
        
        copy.setGameModel(self)
        
        return copy
    }
    
    
}
