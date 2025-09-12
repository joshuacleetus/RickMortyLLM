//
//  ContentView.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import SwiftUI

struct LandingView: View {
    private var hasOpenAIKey: Bool { !AppConfig.openAIKey.isEmpty }

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "sparkles")
                .font(.system(size: 56, weight: .semibold))
                .padding(.top, 40)

            Text("Rick & Morty Explorer")
                .font(.largeTitle.weight(.bold))

            Text("Browse characters via GraphQL (Apollo). Get a short AI summary on the detail page.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            HStack(spacing: 8) {
                Circle().frame(width: 8, height: 8)
                    .foregroundStyle(hasOpenAIKey ? .green : .orange)
                Text(hasOpenAIKey ? "AI: OpenAI (key detected)" : "AI: Stub (no key)")
                    .font(.subheadline).foregroundStyle(.secondary)
            }

            NavigationLink {
                CharactersListView()
            } label: {
                Text("Browse Characters")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.bottom, 32)
        .navigationTitle("Home")
    }
}


#Preview {
    LandingView()
}
