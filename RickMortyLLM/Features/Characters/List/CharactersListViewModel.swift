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
            let result = try await GraphQLClient.shared.fetchAsync(
                CharactersQuery(page: .some(page))
            )
            if let data = result.data, let characters = data.characters {
                self.items += characters.results?.compactMap { $0 } ?? []
                self.nextPage = characters.info?.next
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
}

