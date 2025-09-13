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
    
    func answerAboutCharacter(
        name: String, status: String, species: String, gender: String,
        origin: String?, location: String?, episodes: [String], question: String
    ) async throws -> String {
        // ultra-simple offline “answer”
        let bits = [status, species, gender, origin, location].compactMap{$0}.filter{ !$0.isEmpty }.joined(separator: " • ")
        let eps = episodes.prefix(3).joined(separator: ", ")
        return "You asked: “\(question)”. Based on cached facts: \(name) (\(bits)). Episodes: \(eps)."
    }
}
