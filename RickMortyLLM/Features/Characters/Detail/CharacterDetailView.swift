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
                    
                    Group {
                        Text("Ask a Question")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        TextField("Ask about \(vm.character?.name ?? "this character")…",
                                  text: $vm.question, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)
                        
                        Button {
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
                ProgressView()
                    .task { await vm.load(id: id) }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Details")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let id = vm.character?.id {
                    FavoriteButton(id: id)   // ⭐️
                }
            }
        }
        .alert("Error", isPresented: .constant(vm.error != nil)) {
            Button("OK") { vm.error = nil }
        } message: { Text(vm.error ?? "") }
    }
}
