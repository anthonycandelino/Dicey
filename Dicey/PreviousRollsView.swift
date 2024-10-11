//
//  PreviousRollsView.swift
//  Dicey
//
//  Created by Anthony Candelino on 2024-10-10.
//

import SwiftUI
import SwiftData

struct PreviousRollsView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \DiceRollSet.timeStamp, order: .reverse) var previousRollSets: [DiceRollSet]
    
    var body: some View {
        NavigationStack {
            List(previousRollSets) { rollSet in
                Section("\(rollSet.diceSidesForRolls)-sided roll | \(rollSet.timeStamp.formatted(date: .long, time: .omitted))") {
                    HStack {
                        Spacer()
                        
                        ForEach(rollSet.diceRolls) { dice in
                            if dice.potentialSides > 6 {
                                CustomDieView(number: dice.roll)
                                    .padding(.horizontal, 3)
                            } else {
                                Image("die\(dice.roll)")
                                    .padding(.horizontal, 3)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 5)
                    
                    HStack {
                        Spacer()
                        
                        Text("Total:")
                            .font(.title3)
                            .bold()
                        
                        Text("\(rollSet.rollTotal)")
                            .font(.title3)
                            .bold()
                            .foregroundStyle(Color.orange.mix(with: .red, by: 0.2))
                        
                        Spacer()
                    }
                }
                .listRowSeparator(.hidden)
            }
            .navigationTitle("Previous Rolls")
        }
    }
}

#Preview {
    let dice1 = Dice(roll: 1, potentialSides: 6)
    let dice2 = Dice(roll: 5, potentialSides: 6)
    let rollSet = DiceRollSet(diceRolls: [dice1, dice2])
    
    let dice3 = Dice(roll: 8, potentialSides: 20)
    let dice4 = Dice(roll: 18, potentialSides: 20)
    let dice5 = Dice(roll: 6, potentialSides: 20)
    let rollSet2 = DiceRollSet(diceRolls: [dice3, dice4, dice5])
    
    let rollSet3 = DiceRollSet(diceRolls: [dice1, dice2, dice1, dice2])
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DiceRollSet.self, Dice.self, configurations: config)
    
    container.mainContext.insert(rollSet)
    container.mainContext.insert(rollSet2)
    container.mainContext.insert(rollSet3)
    
    return PreviousRollsView().modelContainer(container)
}
