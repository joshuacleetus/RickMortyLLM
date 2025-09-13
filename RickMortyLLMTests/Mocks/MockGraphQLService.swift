//
//  MockGraphQLService.swift
//  RickMortyLLMTests
//
//  Created by Joshua Cleetus on 9/13/25.
//

import Foundation
import Apollo
import ApolloTestSupport
@testable import RickMortyLLM

final class MockGraphQLService: GraphQLService {
    // Seed this in tests
    var characterByID: [String: CharacterDetailsQuery.Data.Character] = [:]

    // Introspection for assertions
    private(set) var lastCharacterPolicy: CachePolicy?

    // Detail
    func fetchCharacter(id: String, cachePolicy: CachePolicy) async throws -> CharacterDetailsQuery.Data.Character? {
        lastCharacterPolicy = cachePolicy
        return characterByID[id]
    }

    // Unused here, but required by protocol
    func fetchCharacters(page: Int?, cachePolicy: CachePolicy) async throws
    -> ([CharactersQuery.Data.Characters.Result], next: Int?) {
        return ([], nil)
    }
}

