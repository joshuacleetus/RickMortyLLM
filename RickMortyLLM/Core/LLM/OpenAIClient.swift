//
//  OpenAIClient.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import Foundation

struct OpenAIClient: LLMClient {
    private var apiKey: String { AppConfig.openAIKey }
    private let model = "gpt-4o-mini"

    func summarizeCharacter(name: String, status: String, species: String, gender: String, episodes: String) async throws -> String {
        guard !apiKey.isEmpty else {
            return try await StubLLM().summarizeCharacter(name: name, status: status, species: species, gender: gender, episodes: episodes)
        }

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")

        struct Payload: Encodable {
            struct Msg: Encodable { let role: String; let content: String }
            let model: String
            let temperature: Double
            let messages: [Msg]
        }

        let prompt = """
        Summarize this Rick & Morty character in 2–3 friendly, spoiler-light sentences.

        Name: \(name)
        Status: \(status)
        Species: \(species)
        Gender: \(gender)
        Episodes: \(episodes)
        """

        let body = Payload(
            model: model,
            temperature: 0.3,
            messages: [
                .init(role: "system", content: "You are a concise, helpful mobile app assistant."),
                .init(role: "user", content: prompt)
            ]
        )

        req.httpBody = try JSONEncoder().encode(body)

        struct ChatResponse: Decodable {
            struct Choice: Decodable { struct Msg: Decodable { let content: String? }; let message: Msg }
            let choices: [Choice]
        }

        let (data, _) = try await URLSession.shared.data(for: req)
        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
        return decoded.choices.first?.message.content?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}
