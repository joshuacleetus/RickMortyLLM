//
//  OpenAIClient.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/12/25.
//

import Foundation

enum LLMError: LocalizedError {
    case http(Int, String)
    case decoding(String)
    case empty
    var errorDescription: String? {
        switch self {
        case .http(let c, let m): return "OpenAI HTTP \(c): \(m)"
        case .decoding(let m):    return "OpenAI decoding error: \(m)"
        case .empty:              return "OpenAI returned an empty message."
        }
    }
}

struct OpenAIClient: LLMClient {
    private var apiKey: String { AppConfig.shared.openAIKey }
    private let model = "gpt-3.5-turbo"

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

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw LLMError.http(-1, "No HTTPURLResponse") }

        // ---- error handling (fixed) ----
        guard (200...299).contains(http.statusCode) else {
            struct APIErrorResponse: Decodable {
                struct OpenAIError: Decodable { let message: String?; let type: String?; let code: String? }
                let error: OpenAIError?
                let message: String?
            }
            if let apiErr = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                let msg = apiErr.error?.message ?? apiErr.message
                throw LLMError.http(http.statusCode, msg ?? "Unknown OpenAI error")
            } else {
                let bodyText = String(data: data, encoding: .utf8) ?? "Unknown body"
                throw LLMError.http(http.statusCode, bodyText)
            }
        }

        // ---- success decoding: string content ----
        struct ChatV1: Decodable {
            struct Choice: Decodable { struct Msg: Decodable { let content: String? }; let message: Msg }
            let choices: [Choice]
        }
        if let v1 = try? JSONDecoder().decode(ChatV1.self, from: data),
           let text = v1.choices.first?.message.content?.trimmingCharacters(in: .whitespacesAndNewlines),
           !text.isEmpty {
            return text
        }

        // ---- success decoding: parts array content ----
        struct ChatV2: Decodable {
            struct Choice: Decodable {
                struct Msg: Decodable {
                    struct Part: Decodable { let type: String?; let text: String? }
                    let content: [Part]?
                }
                let message: Msg
            }
            let choices: [Choice]
        }
        if let v2 = try? JSONDecoder().decode(ChatV2.self, from: data),
           let parts = v2.choices.first?.message.content {
            let text = parts.compactMap { $0.text }
                            .joined(separator: "\n")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty { return text }
        }

        #if DEBUG
        print("⚠️ OpenAI raw:", String(data: data, encoding: .utf8) ?? "<non-utf8>")
        #endif
        throw LLMError.decoding("Unexpected response format")
    }
}
