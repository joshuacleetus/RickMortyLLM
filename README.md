# RickMortyLLM

A small SwiftUI app that fetches data from the **Rick & Morty GraphQL API** and adds **LLM-powered** insights (summaries, Q\&A, and fun facts) for characters, episodes, and locations.

> Target: iOS 17+
>
> Stack: SwiftUI · Apollo iOS · Combine/Swift Concurrency · URLSession · (Optional) Node/Express proxy for LLM

---

## Table of Contents

* [Features](#features)
* [Architecture](#architecture)
* [Tradeoffs & Limitations](#tradeoffs--limitations)
* [Project Structure](#project-structure)
* [Setup](#setup)

  * [1) Clone & open](#1-clone--open)
  * [2) Configure GraphQL codegen (Apollo)](#2-configure-graphql-codegen-apollo)
  * [3) Choose & configure LLM](#3-choose--configure-llm)
  * [4) Build & run](#4-build--run)
  * [5) Run tests](#5-run-tests)
* [CI (GitHub Actions)](#ci-github-actions)
* [Screenshots / Demo](#screenshots--demo)
* [Future Work](#future-work)
* [License](#license)

---

## Features

* Character list & detail (name, species, status, origin, episodes…)
* Search & filter
* Caching of last successful query (simple on-disk cache)
* **LLM insights** on any character/episode/location:

  * TL;DR summary
  * Contextual Q\&A from on-device selections (e.g., "Explain Morty’s arc in these episodes")
  * "Fun fact" generator

---

## Architecture

**High level**

* **MVVM** with a thin UseCase layer (protocol-oriented, easy to unit test).
* **Apollo iOS** for GraphQL transport & strongly-typed models.
* **LLMProvider** protocol with concrete implementations for OpenAI or Gemini.
* **EnvironmentConfig** for API keys and base URLs.
* **Cache**: lightweight JSON file cache (can be swapped for SQLite/CoreData later).

---

## Tradeoffs & Limitations

1. **Client → LLM direct calls** (DEV ONLY):

   * Production should **proxy via a backend** that holds the key. A tiny Node/Express example is provided below.
2. **Free-tier LLMs**:

   * Rate limits & occasional latency spikes; model capabilities vary.
   * Prompts are kept short; no user PII is sent.
3. **Caching**:

   * Simple JSON file cache; no invalidation beyond staleness window.
4. **Offline**:

   * Minimal offline support (reads from last cache) but no background sync.
5. **Testing**:

   * Unit tests for ViewModels and Repos with Mock LLM + Mock GraphQL; snapshot tests omitted for brevity.

---

## Setup

### 1) Clone & open

```bash
git clone https://github.com/<you>/RickMortyLLM.git
cd RickMortyLLM
open RickMortyLLM.xcodeproj 
```

### 2) Configure GraphQL codegen (Apollo)

**Dependencies (Swift Package Manager):**

```
dependencies: [
  .package(url: "https://github.com/apollographql/apollo-ios.git", .upToNextMajor(from: "1.0.0"))
]
```

Targets ➜ Add **Apollo** to the app target.

**Schema & operations**

* Schema lives at `Modules/Data/GraphQL/Schema/schema.json` (or `.graphqls`).
* Operations (queries/mutations) are in `Modules/Data/GraphQL/Operations/`.

**Codegen options** (choose one):

**A) Xcode Build Tool Plugin (recommended, Xcode 15+)**

1. In *Build Phases* ➜ add **Apollo Codegen Build Tool**.
2. Ensure `Scripts/apollo-codegen-config.json` 
3. Build the target; generated files appear under `Generated/`.

**B) Run Script Phase**
Add a *Run Script Phase* before Compile Sources:

```bash
# Apollo Codegen (SPM plugin entrypoint)
if [ -z "${SRCROOT}" ]; then SRCROOT="$(pwd)"; fi
APOLLO_CODEGEN_CONFIG="${SRCROOT}/Scripts/apollo-codegen-config.json"
"${SWIFT_EXEC:-swift}" run apollo-ios-cli generate --config "${APOLLO_CODEGEN_CONFIG}"
```

> If the `apollo-ios-cli` executable isn’t available by default, Xcode will resolve it via SPM the first build. No Homebrew needed.

### 3) Configure LLM

* Model: `gpt-4o-mini` (fast, low-cost) or `gpt-4o`
* Set **OPENAI\_API\_KEY** in the info.plist, the key will be provided separately
  ```

### 4) Build & run

* Select `RickMortyLLM` scheme ➜ iPhone 15 simulator ➜ **Run**.
* First build may take a minute while SPM resolves Apollo & generates GraphQL types.

### 5) Run tests

* In Xcode: **Product > Test** (⌘U).
* CLI:

```bash
xcodebuild -scheme RickMortyLLM -destination "platform=iOS Simulator,name=iPhone 15" test
```

---

## CI (GitHub Actions)

Minimal workflow (`.github/workflows/ios.yml`)

---

## Screenshots / Demo

Add images under `Docs/` and link them here.

| List                   | Detail                     | LLM Insight                  |
| ---------------------- | -------------------------- | ---------------------------- |
| ![List](Docs/list.png) | ![Detail](Docs/detail.png) | ![Insight](Docs/insight.png) |

**Demo video**: add a short clip to `Docs/demo.mp4` and link: `[Watch demo](Docs/demo.mp4)`.

---

## Future Work

* Offline-first with normalized cache (SQLite) via ApolloStore
* Pagination for long lists (characters/episodes)
* Snapshot tests for UI, accessibility audits
* Prompt templates and function calling for structured LLM output
* In-app feedback & analytics (privacy-first)

---

## License

MIT (or your preferred license)

---

## Appendix

### Example GraphQL query (`Characters.graphql`)

```graphql
query Characters($page: Int, $name: String) {
  characters(page: $page, filter: { name: $name }) {
    info { count pages next prev }
    results {
      id
      name
      status
      species
      image
      origin { name }
      episode { id name air_date }
    }
  }
}
```

### LLMProvider protocol (sketch)

```swift
protocol LLMProvider {
  func summarize(_ text: String, maxTokens: Int) async throws -> String
  func funFact(from text: String) async throws -> String
  func answer(question: String, context: String) async throws -> String
}
```

### OpenAIProvider (sketch)

```swift
struct OpenAIProvider: LLMProvider {
  let apiKey: String
  let baseURL: URL = URL(string: "https://api.openai.com/v1")!
  let model: String = "gpt-4o-mini"

  func summarize(_ text: String, maxTokens: Int) async throws -> String {
    let prompt = "Summarize succinctly (\(maxTokens) tokens max):\n\(text)"
    return try await chat(prompt: prompt)
  }

  func funFact(from text: String) async throws -> String {
    try await chat(prompt: "Extract one fun, spoiler-free fact:\n\(text)")
  }

  func answer(question: String, context: String) async throws -> String {
    try await chat(prompt: "Using only this context, answer concisely. If unknown, say so.\nContext:\n\(context)\n\nQ: \(question)")
  }

  private func chat(prompt: String) async throws -> String {
    struct Req: Encodable { let model: String; let messages: [[String: String]] }
    struct Res: Decodable { struct Choice: Decodable { struct Msg: Decodable { let content: String } let message: Msg }; let choices: [Choice] }

    var req = URLRequest(url: baseURL.appendingPathComponent("/chat/completions"))
    req.httpMethod = "POST"
    req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.httpBody = try JSONEncoder().encode(Req(model: model, messages: [["role": "user", "content": prompt]]))

    let (data, resp) = try await URLSession.shared.data(for: req)
    guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
      throw URLError(.badServerResponse)
    }
    let decoded = try JSONDecoder().decode(Res.self, from: data)
    return decoded.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
  }
}
```

---

