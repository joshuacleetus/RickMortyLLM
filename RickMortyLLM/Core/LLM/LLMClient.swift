//
//  LLMClient.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import Foundation

protocol LLMClient {
    func summarizeCharacter(
        name: String,
        status: String,
        species: String,
        gender: String,
        episodes: String
    ) async throws -> String
    
    func answerAboutCharacter(
        name: String,
        status: String,
        species: String,
        gender: String,
        origin: String?,
        location: String?,
        episodes: [String],
        question: String
    ) async throws -> String
}
