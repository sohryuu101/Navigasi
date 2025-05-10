//
//  NavigasiApp.swift
//  Navigasi
//
//  Created by Akbar Febry on 28/04/25.
//
import SwiftData
import SwiftUI

@main
struct NavigasiApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Place.self, inMemory: true)
        }
    }
}
