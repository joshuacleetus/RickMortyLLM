//
//  GraphQLClient.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import Apollo
import ApolloSQLite
import Foundation

enum GraphQLClient {
    static let shared: ApolloClient = {
        let endpoint = URL(string: "https://rickandmortyapi.com/graphql")!

        // Persistent cache location
        let cacheURL = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("apollo.sqlite")

        // Use SQLite cache if we can, otherwise fall back to in-memory
        let normalizedCache: NormalizedCache
        if let sqlite = try? SQLiteNormalizedCache(fileURL: cacheURL) {
            normalizedCache = sqlite
        } else {
            normalizedCache = InMemoryNormalizedCache()   // ✅ correct fallback
        }

        let store = ApolloStore(cache: normalizedCache)

        let provider = DefaultInterceptorProvider(store: store)
        let transport = RequestChainNetworkTransport(
            interceptorProvider: provider,
            endpointURL: endpoint
        )

        return ApolloClient(networkTransport: transport, store: store)
    }()
}

// keep your async wrapper; allow passing cachePolicy
extension ApolloClient {
    func fetchAsync<Q: GraphQLQuery>(
        _ query: Q,
        cachePolicy: CachePolicy = .returnCacheDataElseFetch
    ) async throws -> GraphQLResult<Q.Data> {
        try await withCheckedThrowingContinuation { cont in
            self.fetch(query: query, cachePolicy: cachePolicy) { result in
                cont.resume(with: result)
            }
        }
    }
}
