//
//  GraphQLService.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import Foundation
import Apollo

protocol GraphQLService {
    func fetchCharacter(id: String, cachePolicy: CachePolicy) async throws -> CharacterDetailsQuery.Data.Character?
    func fetchCharacters(page: Int?, cachePolicy: CachePolicy) async throws -> ([CharactersQuery.Data.Characters.Result], next: Int?)
}

extension GraphQLService {
    func fetchCharacter(id: String) async throws -> CharacterDetailsQuery.Data.Character? {
        try await fetchCharacter(id: id, cachePolicy: .returnCacheDataElseFetch)
    }
    func fetchCharacters(page: Int?) async throws -> ([CharactersQuery.Data.Characters.Result], next: Int?) {
        try await fetchCharacters(page: page, cachePolicy: .returnCacheDataElseFetch)
    }
}

struct LiveGraphQLService: GraphQLService {
    func fetchCharacter(id: String, cachePolicy: CachePolicy) async throws -> CharacterDetailsQuery.Data.Character? {
        let result = try await GraphQLClient.shared.fetchAsync(
            CharacterDetailsQuery(id: id),
            cachePolicy: cachePolicy
        )
        return result.data?.character
    }

    func fetchCharacters(page: Int?, cachePolicy: CachePolicy) async throws -> ([CharactersQuery.Data.Characters.Result], next: Int?) {
        let result = try await GraphQLClient.shared.fetchAsync(
            CharactersQuery(page: .some(page ?? 1)),
            cachePolicy: cachePolicy
        )
        let list = result.data?.characters
        return (list?.results?.compactMap { $0 } ?? [], list?.info?.next)
    }
}
