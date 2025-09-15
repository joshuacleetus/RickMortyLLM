//
//  CharacterDetailViewModel.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import Foundation
import Apollo

@MainActor
final class CharacterDetailViewModel: ObservableObject {
    @Published var character: CharacterDetailsQuery.Data.Character?
    @Published var summary: String?
    @Published var isSummarizing = false
    @Published var error: String?

    // Ask-a-question state
    @Published var question: String = ""
    @Published var answer: String?
    @Published var isAnswering = false

    private let llm: LLMClient
    private let service: GraphQLService
    private var currentID: String?

    init(llm: LLMClient, service: GraphQLService = LiveGraphQLService()) {
        self.llm = llm
        self.service = service
    }

    /// Load using cache-first so previously viewed details appear instantly.
    func load(id: String) async {
        // Skip if we're already showing this character (guards against duplicate loads)
        if currentID == id, character != nil { return }
        currentID = id

        // Optional: show any cached summary immediately
        if let cached = SummaryCache.read(for: id) { self.summary = cached }

        do {
            self.character = try await service.fetchCharacter(
                id: id,
                cachePolicy: .returnCacheDataElseFetch
            )
        } catch {
            self.error = error.localizedDescription
        }
    }

    /// Force a network fetch (bypass cache). Useful for pull-to-refresh.
    func refresh() async {
        guard let id = currentID else { return }
        do {
            self.character = try await service.fetchCharacter(
                id: id,
                cachePolicy: .fetchIgnoringCacheCompletely
            )
        } catch {
            self.error = error.localizedDescription
        }
    }

    func summarize(forceRefresh: Bool = false) async {
        guard let c = character else { return }
        if isSummarizing { return } // double-tap protection

        if !forceRefresh, let s = summary, !s.isEmpty { return }

        isSummarizing = true
        defer { isSummarizing = false }

        do {
            let episodes = c.episode.compactMap { $0?.name }.joined(separator: ", ")
            let text = try await llm.summarizeCharacter(
                name: c.name ?? "",
                status: c.status ?? "",
                species: c.species ?? "",
                gender: c.gender ?? "",
                episodes: episodes
            )
            self.summary = text
            if let id = currentID { SummaryCache.write(text, for: id) }
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? String(describing: error)
        }
    }

    func clearCachedSummary() {
        if let id = currentID {
            SummaryCache.remove(for: id)
        }
        self.summary = nil
    }

    func ask() async {
        guard let c = character else { return }
        if isAnswering { return } // double-tap protection

        let q = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }

        isAnswering = true
        defer { isAnswering = false }

        do {
            let episodes = c.episode.compactMap { $0?.name } // [String]
            let text = try await llm.answerAboutCharacter(
                name: c.name ?? "",
                status: c.status ?? "",
                species: c.species ?? "",
                gender: c.gender ?? "",
                origin: c.origin?.name,
                location: c.location?.name,
                episodes: episodes,
                question: q
            )
            self.answer = text
            // Optional: clear the question after a successful answer
            // self.question = ""
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? String(describing: error)
        }
    }
}
