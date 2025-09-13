//
//  MockLLM.swift
//  RickMortyLLMTests
//
//  Created by Joshua Cleetus on 9/13/25.
//

import Foundation
@testable import RickMortyLLM

final class MockLLM: LLMClient {
    var summaryReturn = "Mock summary"
    var answerReturn  = "Mock answer"

    private(set) var summarizeCallCount = 0
    private(set) var answerCallCount    = 0

    func summarizeCharacter(
        name: String, status: String, species: String, gender: String, episodes: String
    ) async throws -> String {
        summarizeCallCount += 1
        return summaryReturn
    }

    func answerAboutCharacter(
        name: String, status: String, species: String, gender: String,
        origin: String?, location: String?, episodes: [String], question: String
    ) async throws -> String {
        answerCallCount += 1
        return answerReturn
    }
}
