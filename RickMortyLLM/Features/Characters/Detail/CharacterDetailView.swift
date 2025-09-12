//
//  CharacterDetailView.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import SwiftUI

struct CharacterDetailView: View {
    let id: String
    @StateObject private var vm = CharacterDetailViewModel(llm: OpenAIClient())

    var body: some View {
        ScrollView {
            if let c = vm.character {
                VStack(alignment: .leading, spacing: 16) {
                    AsyncImage(url: URL(string: c.image ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: { ProgressView() }
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    Text(c.name ?? "")
                        .font(.title.bold())

                    Text("\(c.species ?? "") • \(c.gender ?? "") • \(c.status ?? "")")
                        .foregroundStyle(.secondary)

                    if let s = vm.summary, !s.isEmpty {
                        Text(s)
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .accessibilityLabel("AI summary: \(s)")
                    }

                    Button {
                        Task { await vm.summarize() }
                    } label: {
                        HStack {
                            if vm.isSummarizing { ProgressView() }
                            Text(vm.isSummarizing ? "Summarizing…" : "Summarize with AI")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.isSummarizing)
                }
                .padding()
            } else {
                ProgressView()
                    .task { await vm.load(id: id) }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Details")
        .alert("Error", isPresented: .constant(vm.error != nil)) {
            Button("OK") { vm.error = nil }
        } message: { Text(vm.error ?? "") }
    }
}
