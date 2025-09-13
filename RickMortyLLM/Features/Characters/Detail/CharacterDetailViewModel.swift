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
    
    @Published var question: String = ""
    @Published var answer: String?
    @Published var isAnswering = false
    
    private let llm: LLMClient
    private var currentID: String?
    
    init(llm: LLMClient) {
        self.llm = llm
    }
    
    func load(id: String) async {
        self.currentID = id
        
        if let cached = SummaryCache.read(for: id) {
            self.summary = cached
        }
        
        do {
            let result = try await GraphQLClient.shared.fetchAsync(
                CharacterDetailsQuery(id: id)
            )
            self.character = result.data?.character
        } catch { self.error = error.localizedDescription }
    }
    
    func summarize(forceRefresh: Bool = false) async {
        guard let c = character else { return }
        
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
        let q = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }
        
        isAnswering = true; defer { isAnswering = false }
        do {
            let episodes = c.episode.compactMap { $0?.name ?? nil }
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
            // optional: cache Q&A if you like
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? String(describing: error)
        }
    }
}
