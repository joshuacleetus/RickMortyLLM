//
//  StubLLM.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import Foundation

struct StubLLM: LLMClient {
    func summarizeCharacter(name: String, status: String, species: String, gender: String, episodes: String) async throws -> String {
        let facts = [status, species, gender].filter{ !$0.isEmpty }.joined(separator: " • ")
        let eps = episodes.split(separator: ",").prefix(3).joined(separator: ", ")
        return "\(name) (\(facts)). Seen in \(eps)."
    }
}
