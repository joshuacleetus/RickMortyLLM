//
//  FavoriteButton.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import SwiftUI

struct FavoriteButton: View {
    @EnvironmentObject var favorites: FavoritesStore
    let id: String

    var body: some View {
        Button {
            favorites.toggle(id)
        } label: {
            Image(systemName: favorites.contains(id) ? "star.fill" : "star")
                .imageScale(.large)
                .foregroundStyle(favorites.contains(id) ? .yellow : .secondary)
                .accessibilityLabel(favorites.contains(id) ? "Remove from Favorites" : "Add to Favorites")
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}
