//
//  RollView.swift
//  Dicey
//
//  Created by Anthony Candelino on 2024-10-10.
//

import SwiftUI

struct RollView: View {
    @Environment(\.modelContext) var modelContext
    @State private var selectedSides = 6
    @State private var numberOfDice = 1
    @State private var totalRolled = 0
    @State private var diceRolls: [Int] = []
    @State private var displayedDiceIndex = 0
    @State private var isRolling = false
    
    var isMultipleDice: Bool { numberOfDice > 1 }
    var isUsingCustomDice: Bool { selectedSides > 6 }
    var hasRolledDice: Bool { !diceRolls.isEmpty }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    if hasRolledDice {
                        ForEach(0..<displayedDiceIndex , id: \.self) { index in
                            if isUsingCustomDice {
                                CustomDieView(number: diceRolls[index])
                                    .padding(.horizontal, 3)
                            } else {
                                Image("die\(diceRolls[index])")
                                    .padding(.horizontal, 3)
                            }
                        }
                    } else {
                        ForEach(0..<numberOfDice , id: \.self) { _ in
                            if isUsingCustomDice {
                                CustomDieView(number: 1)
                                    .padding(.horizontal, 3)
                                
                            } else {
                                Image("die1")
                                    .padding(.horizontal, 3)
                            }
                        }
                    }
                    Spacer()
                    
                }
                
                .frame(height: 80)
                .padding()
                .background(.white)
                .cornerRadius(10)
                .padding()
                .shadow(radius: 3, y: 3)
                
                HStack {
                    Text("Rolled: ")
                        .font(.title)
                    Text("\(totalRolled)")
                        .font(.title)
                        .bold()
                        .foregroundStyle(Color.orange.mix(with: .red, by: 0.2))
                }
                
                VStack {
                    Text("Number of Dice")
                        .font(.headline)
                        .bold()
                        .padding(.top)
                    Picker("Number of dice", selection: $numberOfDice) {
                        ForEach(1...4, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    .disabled(isRolling)
                    .onChange(of: numberOfDice) {
                        totalRolled = 0
                        diceRolls.removeAll()
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical)
                }
                .padding(.horizontal)
                .background(.white)
                .cornerRadius(10)
                .padding()
                .shadow(radius: 3, y: 3)
                
                HStack {
                    Text(isMultipleDice ? "Sides of Dice" : "Sides of Die")
                        .font(.headline)
                        .bold()
                    Spacer()
                    Picker("Sides", selection: $selectedSides) {
                        ForEach([4, 6, 8, 10, 12, 20, 100], id: \.self) {
                            Text("\($0)-sided")
                        }
                    }
                    .disabled(isRolling)
                    .onChange(of: selectedSides) {
                        totalRolled = 0
                        diceRolls.removeAll()
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 200, height: 100)
                }
                .padding(.horizontal)
                .background(.white)
                .cornerRadius(10)
                .padding()
                .shadow(radius: 3, y: 3)
                
                Spacer()
                HStack {
                    Spacer()
                    
                    Button("Roll") {
                        rollDice()
                    }
                    .font(.title)
                    .bold()
                    .padding(.horizontal, 30)
                    .foregroundStyle(.white)
                    .padding()
                    .background(isRolling ? .black.opacity(0.1) : Color.orange.mix(with: .red, by: 0.2))
                    .clipShape(.capsule)
                    .shadow(radius: !isRolling ? 3 : 0, x: 0, y: !isRolling ? 3 : 0)
                    .disabled(isRolling)
                    
                    Spacer()
                }
                .padding(.bottom, 25)
                
                
            }
            .background(.black.opacity(0.07))
            .navigationTitle("DICEY")
        }
    }
    
    func rollDice() {
        isRolling = true
        totalRolled = 0
        diceRolls = (0..<numberOfDice).map { _ in
            Int.random(in: 1...selectedSides)
        }
        displayedDiceIndex = 0
        
        for index in 0..<diceRolls.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index)) {
                totalRolled += diceRolls[index]
                displayedDiceIndex = index + 1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(diceRolls.count)) {
            saveRolls()
            isRolling = false
        }
    }
    
    func saveRolls() {
        let diceResults = (0..<numberOfDice).map { diceIndex in
            return Dice(roll: diceRolls[diceIndex], potentialSides: selectedSides)
        }

        let diceRollSet = DiceRollSet(diceRolls: diceResults)
        modelContext.insert(diceRollSet)
        try? modelContext.save()
    }
    
}

#Preview {
    RollView()
}
