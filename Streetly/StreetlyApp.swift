//
//  StreetlyApp.swift
//  Streetly
//
//  Created by Mojmír Horváth on 31.07.24.
//

import SwiftUI
import SwiftData

@main
struct StreetlyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [DataItem.self, Vehicle.self]) 
    }
}
