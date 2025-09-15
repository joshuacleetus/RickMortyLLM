//
//  GraphQLService.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import Foundation
import Apollo

// MARK: - Custom Error Types
enum GraphQLServiceError: LocalizedError {
    case characterFetchFailed(id: String, underlying: Error)
    case charactersFetchFailed(page: Int?, underlying: Error)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .characterFetchFailed(let id, let underlying):
            return "Failed to fetch character with id \(id): \(underlying.localizedDescription)"
        case .charactersFetchFailed(let page, let underlying):
            return "Failed to fetch characters for page \(page ?? 1): \(underlying.localizedDescription)"
        case .noData:
            return "No data received from GraphQL query"
        }
    }
}

// MARK: - Data Models
struct CharactersPage {
    let results: [CharactersQuery.Data.Characters.Result]
    let nextPage: Int?
    let hasNextPage: Bool
    
    init(results: [CharactersQuery.Data.Characters.Result], nextPage: Int?) {
        self.results = results
        self.nextPage = nextPage
        self.hasNextPage = nextPage != nil
    }
}

// MARK: - Protocol
protocol GraphQLService {
    func fetchCharacter(id: String, cachePolicy: CachePolicy) async throws -> CharacterDetailsQuery.Data.Character?
    func fetchCharacters(page: Int?, cachePolicy: CachePolicy) async throws -> CharactersPage
}

// MARK: - Default Implementations
extension GraphQLService {
    func fetchCharacter(id: String) async throws -> CharacterDetailsQuery.Data.Character? {
        try await fetchCharacter(id: id, cachePolicy: .returnCacheDataElseFetch)
    }
    
    func fetchCharacters(page: Int? = nil) async throws -> CharactersPage {
        try await fetchCharacters(page: page, cachePolicy: .returnCacheDataElseFetch)
    }
}

// MARK: - Live Implementation
struct LiveGraphQLService: GraphQLService {
    func fetchCharacter(id: String, cachePolicy: CachePolicy) async throws -> CharacterDetailsQuery.Data.Character? {
        do {
            let result = try await GraphQLClient.shared.fetchAsync(
                CharacterDetailsQuery(id: id),
                cachePolicy: cachePolicy
            )
            
            guard let character = result.data?.character else {
                throw GraphQLServiceError.noData
            }
            
            return character
        } catch let error as GraphQLServiceError {
            throw error
        } catch {
            throw GraphQLServiceError.characterFetchFailed(id: id, underlying: error)
        }
    }
    
    func fetchCharacters(page: Int?, cachePolicy: CachePolicy) async throws -> CharactersPage {
        do {
            let pageNumber = page ?? 1
            let result = try await GraphQLClient.shared.fetchAsync(
                CharactersQuery(page: .some(pageNumber)),
                cachePolicy: cachePolicy
            )
            
            guard let charactersData = result.data?.characters else {
                throw GraphQLServiceError.noData
            }
            
            let characters = charactersData.results?.compactMap { $0 } ?? []
            let nextPage = charactersData.info?.next
            
            return CharactersPage(results: characters, nextPage: nextPage)
        } catch let error as GraphQLServiceError {
            throw error
        } catch {
            throw GraphQLServiceError.charactersFetchFailed(page: page, underlying: error)
        }
    }
}
