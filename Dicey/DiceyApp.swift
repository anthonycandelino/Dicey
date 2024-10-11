//
//  DiceyApp.swift
//  Dicey
//
//  Created by Anthony Candelino on 2024-10-10.
//

import SwiftData
import SwiftUI

@main
struct DiceyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: DiceRollSet.self) // which model class is persisted
        }
    }
}
