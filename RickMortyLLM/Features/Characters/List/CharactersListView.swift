//
//  CharactersListView.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import SwiftUI

struct CharactersListView: View {
    @StateObject private var vm = CharactersListViewModel()

    var body: some View {
        List {
            // Use indices for a stable ForEach since id is optional in schema
            ForEach(Array(vm.items.enumerated()), id: \.offset) { _, c in
                NavigationLink {
                    CharacterDetailView(id: c.id ?? "")
                } label: {
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: c.image ?? "")) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(c.name ?? "Unknown").font(.headline)
                            Text("\(c.species ?? "—") • \(c.status ?? "—")")
                                .foregroundStyle(.secondary).font(.subheadline)
                        }
                    }
                    .accessibilityLabel("\(c.name ?? "Character"), \(c.species ?? ""), \(c.status ?? "")")
                }
                .onAppear {
                    if c.id == vm.items.last?.id {
                        Task { await vm.loadNextPage() }
                    }
                }
            }

            if vm.isLoading {
                HStack { Spacer(); ProgressView(); Spacer() }
            }
        }
        .navigationTitle("Characters")
        .task { await vm.loadNextPage() }
        .alert("Error", isPresented: .constant(vm.error != nil)) {
            Button("OK") { vm.error = nil }
        } message: {
            Text(vm.error ?? "")
        }
    }
}
