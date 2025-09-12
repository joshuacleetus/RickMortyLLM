//
//  GraphQLClient.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import Foundation
import Apollo

enum GraphQLClient {
    static let shared: ApolloClient = {
        let url = URL(string: "https://rickandmortyapi.com/graphql")!
        return ApolloClient(url: url)
    }()
}


extension ApolloClient {
    func fetchAsync<Q: GraphQLQuery>(_ query: Q,
                                     cachePolicy: CachePolicy = .returnCacheDataElseFetch) async throws -> GraphQLResult<Q.Data> {
        try await withCheckedThrowingContinuation { cont in
            self.fetch(query: query, cachePolicy: cachePolicy) { result in
                cont.resume(with: result)
            }
        }
    }
}
