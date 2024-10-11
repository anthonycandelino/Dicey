//
//  CustomDieView.swift
//  Dicey
//
//  Created by Anthony Candelino on 2024-10-10.
//

import SwiftUI

struct CustomDieView: View {
    var number: Int = 0
    
    var body: some View {
        ZStack {
            Image(.dieBlank)
            Text("\(number)")
                .fontWeight(.bold)
                .foregroundStyle(.numberColour)
                .font(.system(.title, design: .serif))
        }
    }
}

#Preview {
    CustomDieView(number: 9)
    CustomDieView(number: 66)
    CustomDieView(number: 99)
    CustomDieView(number: 100)
}
