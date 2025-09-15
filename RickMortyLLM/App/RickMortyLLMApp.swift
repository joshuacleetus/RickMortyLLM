//
//  RickMortyLLMApp.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import SwiftUI

@main
struct RickMortyLLMApp: App {
    @StateObject private var favorites = FavoritesStore.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                LandingView()
            }
            .environmentObject(favorites)
        }
    }
}
