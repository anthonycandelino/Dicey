//
//  DiceRollSet.swift
//  Dicey
//
//  Created by Anthony Candelino on 2024-10-10.
//

import Foundation
import SwiftData

@Model
class DiceRollSet {
    var timeStamp: Date = Date()
    var diceRolls: [Dice]
    
    init(diceRolls: [Dice]) {
        self.diceRolls = diceRolls
    }
    
    var rollTotal: Int {
        diceRolls.reduce(0) { $0 + ($1.roll) }
    }
    
    var diceSidesForRolls: Int {
        diceRolls.first?.potentialSides ?? 0
    }
}
