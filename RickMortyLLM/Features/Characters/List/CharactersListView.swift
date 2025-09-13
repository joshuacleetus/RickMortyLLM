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
                // Filter the items up front to avoid empty rows
                let filtered = vm.items.filter { c in
                    guard let id = c.id else { return !showFavoritesOnly }
                    return !showFavoritesOnly || favorites.contains(id)
                }

                ForEach(Array(filtered.enumerated()), id: \.offset) { index, c in
                    NavigationLink {
                        CharacterDetailView(id: c.id ?? "")
                    } label: {
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: c.image ?? "")) { image in
                                image.resizable().scaledToFill()
                            } placeholder: { ProgressView() }
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(c.name ?? "Unknown").font(.headline)
                                Text("\(c.species ?? "—") • \(c.status ?? "—")")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                            }

                            Spacer()

                            if let id = c.id {
                                FavoriteButton(id: id)  // ⭐️
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    // infinite scroll: when last filtered row appears, load next page
                    .onAppear {
                        if index == filtered.count - 1 {
                            Task { await vm.loadNextPage() }
                        }
                    }
                }

                if vm.isLoading {
                    HStack { Spacer(); ProgressView(); Spacer() }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Characters")
        .task { await vm.loadNextPage() } // initial load
        .alert("Error", isPresented: .constant(vm.error != nil)) {
            Button("OK") { vm.error = nil }
        } message: { Text(vm.error ?? "") }
    }
}
