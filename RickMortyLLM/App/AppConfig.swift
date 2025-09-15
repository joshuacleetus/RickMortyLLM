//
//  AppConfig.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import Foundation

final class AppConfig {
    static let shared = AppConfig()
    private init() {}

    /// Reads `OPENAI_API_KEY` from Info.plist (which is fed by an xcconfig).
    var openAIKey: String {
        guard
            let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String,
            !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            fatalError("❌ Missing OPENAI_API_KEY in Info.plist. Add it or set via xcconfig.")
        }
        return key
    }
}
