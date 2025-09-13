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

    func loadNextPage() async {
        guard let page = nextPage, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            // Cache-first: show cached page if present, otherwise fetch
            let result = try await GraphQLClient.shared.fetchAsync(
                CharactersQuery(page: .some(page)),
                cachePolicy: .returnCacheDataElseFetch
            )
            if let data = result.data, let characters = data.characters {
                self.items += characters.results?.compactMap { $0 } ?? []
                self.nextPage = characters.info?.next
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    // Optional pull-to-refresh that bypasses cache
    func refresh() async {
        items.removeAll(); nextPage = 1
        do {
            let result = try await GraphQLClient.shared.fetchAsync(
                CharactersQuery(page: .some(1)),
                cachePolicy: .fetchIgnoringCacheCompletely
            )
            if let data = result.data, let characters = data.characters {
                self.items = characters.results?.compactMap { $0 } ?? []
                self.nextPage = characters.info?.next
            }
        } catch { self.error = error.localizedDescription }
    }
}
