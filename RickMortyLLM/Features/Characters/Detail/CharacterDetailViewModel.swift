//
//  CharacterDetailViewModel.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import Foundation

@MainActor
final class CharacterDetailViewModel: ObservableObject {
    @Published var character: CharacterDetailsQuery.Data.Character?
    @Published var summary: String?
    @Published var isSummarizing = false
    @Published var error: String?

    private let llm: LLMClient

    init(llm: LLMClient) {
        self.llm = llm
    }

    func load(id: String) async {
        do {
            let result = try await GraphQLClient.shared.fetchAsync(
                CharacterDetailsQuery(id: id)
            )
            self.character = result.data?.character
        } catch { self.error = error.localizedDescription }
    }

    func summarize() async {
        guard let c = character else { return }
        isSummarizing = true
        defer { isSummarizing = false }
        do {
            let episodes = (c.episode).compactMap { $0?.name }.joined(separator: ", ")
            self.summary = try await llm.summarizeCharacter(
                name: c.name ?? "",
                status: c.status ?? "",
                species: c.species ?? "",
                gender: c.gender ?? "",
                episodes: episodes
            )
        } catch {
            // Prefer our LocalizedError text if available
            self.error = (error as? LocalizedError)?.errorDescription ?? String(describing: error)
            print(error as Any)
        }
    }
}
