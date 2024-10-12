//
//  RollView.swift
//  Dicey
//
//  Created by Anthony Candelino on 2024-10-10.
//

import SwiftUI

// The notification we'll send when a shake gesture happens.
extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

//  Override the default behavior of shake gestures to send our notification instead.
extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

// A view modifier that detects shaking and calls a function of our choosing.
struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

// A View extension to make the modifier easier to use.
extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
}

struct RollView: View {
    @Environment(\.modelContext) var modelContext
    @State private var selectedSides = 6
    @State private var numberOfDice = 1
    @State private var totalRolled = 0
    @State private var diceRolls: [Int] = []
    @State private var displayedDiceIndex = 0
    @State private var isRolling = false
    @State private var isBlinking = false
    @State private var blinkCount = 0
    @State private var blinkTimer: Timer?
    let totalBlinks = 2
    
    var isMultipleDice: Bool { numberOfDice > 1 }
    var isUsingCustomDice: Bool { selectedSides > 6 }
    var hasRolledDice: Bool { !diceRolls.isEmpty }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    
                    Text(isRolling ? "Rolling..." : "Shake to Roll!")
                        .font(.title)
                        .bold()
                        .padding()
                        .foregroundStyle(Color.orange.mix(with: .red, by: 0.2))
                        .opacity(!isBlinking ? 1 : 0.05)
                        .onAppear {
                            blinkCount = 0
                            isBlinking = false
                            
                            blinkTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    isBlinking.toggle()
                                }
                                
                                blinkCount += 1
                                
                                if blinkCount >= totalBlinks * 2 {
                                    timer.invalidate()
                                    blinkTimer = nil
                                }
                            }
                        }
                        .onDisappear {
                            blinkTimer?.invalidate()
                            blinkTimer = nil
                        }
                    
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    if hasRolledDice {
                        ForEach(0..<numberOfDice, id: \.self) { index in
                            if index < displayedDiceIndex {
                                if isUsingCustomDice {
                                    CustomDieView(number: diceRolls[index])
                                        .padding(.horizontal, 3)
                                        .transition(.scale)
                                } else {
                                    Image("die\(diceRolls[index])")
                                        .padding(.horizontal, 3)
                                        .transition(.scale)
                                }
                            } else {
                                Image("dieBlank")
                                    .padding(.horizontal, 3)
                                    .transition(.scale)
                            }
                        }
                    } else {
                        ForEach(0..<numberOfDice , id: \.self) { _ in
                            Image(.dieBlank)
                                .padding(.horizontal, 3)
                                .transition(.scale)
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
                        withAnimation {
                            diceRolls.removeAll()
                            totalRolled = 0
                        }
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
                        withAnimation {
                            diceRolls.removeAll()
                            totalRolled = 0
                        }
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
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("DICEY")
        }
        .onShake(perform: rollDice)
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
