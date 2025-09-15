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
    // MARK: - Published Properties
    @Published var items: [CharactersQuery.Data.Characters.Result] = []
    @Published var nextPage: Int? = 1
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var error: Error?
    
    // MARK: - Computed Properties
    var hasNextPage: Bool {
        nextPage != nil
    }
    
    var errorMessage: String? {
        error?.localizedDescription
    }
    
    var hasItems: Bool {
        !items.isEmpty
    }

    // MARK: - Private Properties
    private let service: GraphQLService
    
    // MARK: - Initialization
    init(service: GraphQLService = LiveGraphQLService()) {
        self.service = service
    }

    // MARK: - Public Methods
    func filteredItems(
        showFavoritesOnly: Bool,
        isFavorite: (String) -> Bool
    ) -> [CharactersQuery.Data.Characters.Result] {
        items.filter { character in
            guard let id = character.id else { return !showFavoritesOnly }
            return !showFavoritesOnly || isFavorite(id)
        }
    }

    func loadNextPage() async {
        guard let page = nextPage, !isLoading else { return }
        
        await performLoad(page: page, isRefresh: false)
    }

    func refresh() async {
        // Clear error state on refresh
        clearError()
        
        // Reset pagination
        items.removeAll()
        nextPage = 1
        
        await performLoad(page: 1, isRefresh: true)
    }
    
    func clearError() {
        error = nil
    }
    
    func retryLastOperation() async {
        if hasItems {
            await loadNextPage()
        } else {
            await refresh()
        }
    }

    // MARK: - Private Methods
    private func performLoad(page: Int, isRefresh: Bool) async {
        if isRefresh {
            isRefreshing = true
        } else {
            isLoading = true
        }
        
        defer {
            isRefreshing = false
            isLoading = false
        }

        do {
            let cachePolicy: CachePolicy = isRefresh ?
                .fetchIgnoringCacheCompletely :
                .returnCacheDataElseFetch
            
            let charactersPage = try await service.fetchCharacters(
                page: page,
                cachePolicy: cachePolicy
            )
            
            if isRefresh {
                self.items = charactersPage.results
            } else {
                self.items += charactersPage.results
            }
            
            self.nextPage = charactersPage.nextPage
            
            // Clear any previous errors on successful load
            clearError()
            
        } catch {
            self.error = error
            
            // Log error for debugging
            print("Failed to load characters: \(error)")
            
            // If this was a refresh and we have existing items, don't clear them
            // If this was initial load or pagination, the error state will be handled by UI
        }
    }
}

// MARK: - Convenience Extensions
extension CharactersListViewModel {
    /// Load initial data if no items are present
    func loadInitialDataIfNeeded() async {
        guard items.isEmpty && !isLoading && !isRefreshing else { return }
        await refresh()
    }
    
    /// Check if we should show loading state
    var shouldShowLoadingState: Bool {
        isLoading && items.isEmpty
    }
    
    /// Check if we should show refresh state
    var shouldShowRefreshState: Bool {
        isRefreshing
    }
    
    /// Check if we should show error state
    var shouldShowErrorState: Bool {
        error != nil && items.isEmpty
    }
    
    /// Check if we should show pagination loading
    var shouldShowPaginationLoading: Bool {
        isLoading && !items.isEmpty
    }
}
