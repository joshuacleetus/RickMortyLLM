//
//  SummaryCache.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import Foundation

enum SummaryCache {
    private static let prefix = "summary:"
    static func read(for id: String) -> String? {
        UserDefaults.standard.string(forKey: prefix + id)
    }
    static func write(_ text: String, for id: String) {
        UserDefaults.standard.set(text, forKey: prefix + id)
    }
    static func remove(for id: String) {
        UserDefaults.standard.removeObject(forKey: prefix + id)
    }
}
