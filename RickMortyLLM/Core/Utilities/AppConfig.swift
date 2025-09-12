//
//  AppConfig.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import Foundation

enum AppConfig {
    static var openAIKey: String {
        // Prefer Secrets.plist; fall back to Info.plist if needed.
        if let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
           let key = dict["OPENAI_API_KEY"] as? String {
            return key
        }
        return (Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String) ?? ""
    }
}
