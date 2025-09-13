//
//  FavoritesStore.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import Foundation

@MainActor
final class FavoritesStore: ObservableObject {
    static let shared = FavoritesStore()

    private let key = "favorites"
    @Published private(set) var ids: Set<String> = []

    private init() {
        if let array = UserDefaults.standard.array(forKey: key) as? [String] {
            ids = Set(array)
        }
    }

    func contains(_ id: String) -> Bool { ids.contains(id) }

    func add(_ id: String) {
        if ids.insert(id).inserted { persist() }
    }

    func remove(_ id: String) {
        if ids.remove(id) != nil { persist() }
    }

    func toggle(_ id: String) {
        contains(id) ? remove(id) : add(id)
    }

    private func persist() {
        UserDefaults.standard.set(Array(ids), forKey: key)
    }
}
