//
//  ContentView.swift
//  Dicey
//
//  Created by Anthony Candelino on 2024-10-10.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RollView()
                .tabItem {
                    Label("Roll", systemImage: "dice.fill")
                }
            
            PreviousRollsView()
                .tabItem {
                    Label("Previous Rolls", systemImage: "clock.arrow.circlepath")
                }
        }
        .accentColor(.orange)
    }
}

#Preview {
    ContentView()
}
