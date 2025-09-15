//
//  CharactersListView.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import SwiftUI

struct CharactersListView: View {
    @StateObject private var vm = CharactersListViewModel()
    @State private var showFavoritesOnly = false
    @EnvironmentObject private var favorites: FavoritesStore

    var body: some View {
        VStack(spacing: 8) {
            // Filter toggle
            Toggle("Favorites only", isOn: $showFavoritesOnly)
                .toggleStyle(.switch)
                .padding(.horizontal)

            List {
                let filtered = vm.filteredItems(
                    showFavoritesOnly: showFavoritesOnly,
                    isFavorite: { favorites.contains($0) }
                )

                ForEach(filtered, id: \.id) { character in
                    NavigationLink {
                        CharacterDetailView(id: character.id ?? "")
                    } label: {
                        CharacterRowView(character: character)
                    }
                    .onAppear {
                        if character.id == filtered.last?.id {
                            Task { await vm.loadNextPage() }
                        }
                    }
                }

                if vm.isLoading {
                    HStack { Spacer(); ProgressView(); Spacer() }
                }
            }
            .listStyle(.plain)
            .refreshable { await vm.refresh() }
        }
        .navigationTitle("Characters")
        .task { await vm.loadNextPage() }
        .alert("Error", isPresented: Binding(
            get: { vm.error != nil },
            set: { _ in vm.error = nil }
        )) {
            Button("OK") { vm.error = nil }
        } message: {
            Text(vm.errorMessage ?? "Unknown error")
        }
    }
}
