//
//  Move.swift
//  Flip
//
//  Created by Thang Le Tan on 9/26/16.
//  Copyright © 2016 Thang Le Tan. All rights reserved.
//

import UIKit
import GameplayKit

class Move: NSObject, GKGameModelUpdate {
    
    var row: Int
    var col: Int
    
    var value = 0
    
    init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
}
