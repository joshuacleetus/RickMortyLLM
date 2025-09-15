//
//  CharacterRowView.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/15/25.
//

import SwiftUI

struct CharacterRowView: View {
    let character: CharactersQuery.Data.Characters.Result
    @EnvironmentObject private var favorites: FavoritesStore
    
    var body: some View {
        HStack(spacing: 12) {
            // Character image
            AsyncImage(url: URL(string: character.image ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .accessibilityLabel("Character image for \(character.name ?? "Unknown")")
            
            // Character info
            VStack(alignment: .leading, spacing: 4) {
                Text(character.name ?? "Unknown")
                    .font(.headline)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text(character.species ?? "—")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    
                    StatusIndicator(status: character.status)
                }
            }
            
            Spacer()
            
            // Favorite button
            if let id = character.id {
                FavoriteButton(id: id)
                    .accessibilityLabel(favorites.contains(id) ? "Remove from favorites" : "Add to favorites")
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Status Indicator
private struct StatusIndicator: View {
    let status: String?
    
    private var statusColor: Color {
        switch status?.lowercased() {
        case "alive":
            return .green
        case "dead":
            return .red
        case "unknown":
            return .orange
        default:
            return .secondary
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(status ?? "—")
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
    }
}
