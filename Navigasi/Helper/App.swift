//
//  App.swift
//  Navigasi
//
//  Created by Akbar Febry on 11/05/25.
//

import SwiftUI
import SwiftData

// App navigation state enum
enum AppScreen: Equatable {
    case showingMap
    case navigation(startingPoint: String)
}

class AppState: ObservableObject {
    @Published var currentScreen: AppScreen = .showingMap
}
