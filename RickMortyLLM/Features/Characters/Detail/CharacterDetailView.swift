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

    // Computed binding so the alert can dismiss properly
    private var isShowingError: Binding<Bool> {
        Binding(
            get: { vm.error != nil },
            set: { newValue in if !newValue { vm.error = nil } }
        )
    }

    var body: some View {
        ScrollView {
            if let c = vm.character {
                VStack(alignment: .leading, spacing: 16) {
                    AsyncImage(url: URL(string: c.image ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                            ProgressView()
                        }
                    }
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .accessibilityLabel(Text(c.name ?? "Character image"))

                    Text(c.name ?? "")
                        .font(.title.bold())

                    // Build the meta line from non-empty parts to avoid " •  • "
                    Text(
                        [c.species, c.gender, c.status]
                            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }
                            .joined(separator: " • ")
                    )
                    .foregroundStyle(.secondary)

                    if let s = vm.summary, !s.isEmpty {
                        Text(s)
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .accessibilityLabel("AI summary: \(s)")
                    }

                    Button {
                        guard !vm.isSummarizing else { return }
                        Task { await vm.summarize() }
                    } label: {
                        HStack {
                            if vm.isSummarizing { ProgressView() }
                            Text(vm.isSummarizing ? "Summarizing…" : "Summarize with AI")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.isSummarizing || vm.character == nil)

                    Group {
                        Text("Ask a Question")
                            .font(.headline)
                            .padding(.top, 8)

                        TextField("Ask about \(vm.character?.name ?? "this character")…",
                                  text: $vm.question, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(2...4)
                            .submitLabel(.send)
                            .onSubmit {
                                guard !vm.isAnswering else { return }
                                Task { await vm.ask() }
                            }

                        Button {
                            guard !vm.isAnswering else { return }
                            Task { await vm.ask() }
                        } label: {
                            HStack {
                                if vm.isAnswering { ProgressView() }
                                Text(vm.isAnswering ? "Thinking…" : "Ask")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(vm.isAnswering || vm.question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                        if let a = vm.answer, !a.isEmpty {
                            Text(a)
                                .padding()
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .accessibilityLabel("Answer: \(a)")
                        }
                    }
                }
                .padding()
            } else {
                // First-load spinner
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading details…").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 40)
            }
        }
        .navigationTitle("Details")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let id = vm.character?.id {
                    FavoriteButton(id: id)
                }
            }
        }
        // Load when the view appears AND if the id ever changes
        .task(id: id) {
            await vm.load(id: id)
        }
        // Pull-to-refresh forces a network fetch (you already exposed refresh())
        .refreshable {
            await vm.refresh()
        }
        .alert("Error", isPresented: isShowingError) {
            Button("OK") { vm.error = nil }
        } message: {
            Text(vm.error ?? "Something went wrong.")
        }
    }
}
