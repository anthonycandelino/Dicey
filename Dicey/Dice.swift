//
//  Dice.swift
//  Dicey
//
//  Created by Anthony Candelino on 2024-10-10.
//

import Foundation
import SwiftData

@Model
class Dice {
    var roll: Int
    var potentialSides: Int
    
    init (roll: Int, potentialSides: Int) {
        self.roll = roll
        self.potentialSides = potentialSides
    }
}
