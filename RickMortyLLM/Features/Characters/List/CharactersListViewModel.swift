//
//  CharactersListViewModel.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import Foundation
import Apollo
import ApolloAPI

@MainActor
final class CharactersListViewModel: ObservableObject {
    @Published var items: [CharactersQuery.Data.Characters.Result] = []
    @Published var nextPage: Int? = 1
    @Published var isLoading = false
    @Published var error: String?

    private let service: GraphQLService
    init(service: GraphQLService = LiveGraphQLService()) { self.service = service }

    func loadNextPage() async {
        guard let page = nextPage, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let (rows, next) = try await service.fetchCharacters(
                page: page,
                cachePolicy: .returnCacheDataElseFetch
            )
            self.items += rows
            self.nextPage = next
        } catch {
            self.error = error.localizedDescription
        }
    }

    // pull-to-refresh = bypass cache (network-only)
    func refresh() async {
        items.removeAll()
        nextPage = 1
        do {
            let (rows, next) = try await service.fetchCharacters(
                page: 1,
                cachePolicy: .fetchIgnoringCacheCompletely
            )
            self.items = rows
            self.nextPage = next
        } catch {
            self.error = error.localizedDescription
        }
    }
}
