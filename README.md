RickMortyLLM

SwiftUI app that explores the Rick & Morty universe via GraphQL (Apollo iOS) and adds lightweight AI insights with an LLM (OpenAI gpt-3.5-turbo). Built with MVVM, async/await, Apollo normalized cache, and a tiny local summary cache. Includes Favorites, “Ask a question”, Accessibility, Dark Mode, unit tests, and GitHub Actions CI.

Optional: add your CI badge once the workflow runs
![iOS CI](https://github.com/<your-username>/RickMortyLLM/actions/workflows/ios-ci.yml/badge.svg)

Features

Browse characters (paginated list) and view rich details (episodes, locations).

LLM summary of a character (2–3 sentences) and “Ask a question” about the character.

Favorites (UserDefaults) + filter in list.

Apollo normalized cache + small summary cache keyed by character id.

Accessible UI (Dynamic Type, VoiceOver labels, sufficient contrast) + Dark Mode.

Unit tests for ViewModels using ApolloTestSupport schema mocks.

GitHub Actions: build & test on a simulator.

Tech Stack

SwiftUI, MVVM, async/await

Apollo iOS (1.23) for GraphQL + codegen

Public GraphQL: Rick & Morty API — https://rickandmortyapi.com/graphql

LLM: OpenAI gpt-3.5-turbo (fallback to stub when key is missing)

UserDefaults for favorites

XCTest, ApolloTestSupport for tests

GitHub Actions CI

Demo / Screenshots (optional)

Drop images in Docs/ and link them here.

Demo video (optional): upload to GitHub Releases, or a public link, then add:
[Watch the demo](https://…)

Getting Started
Requirements

Xcode 16.x (project format 77)

iOS 17+ target

Swift Package Manager (SPM)

1) Clone
git clone https://github.com/<your-username>/RickMortyLLM.git
cd RickMortyLLM

2) Dependencies

Open RickMortyLLM.xcodeproj (or workspace if you use one). Xcode will resolve SPM packages automatically.

3) GraphQL Codegen (if you didn’t commit Generated/)

If Generated/ is already in the repo, you can skip this.

Ensure apollo-ios-cli (executable) is at the repo root.

Run:

./apollo-ios-cli fetch-schema
./apollo-ios-cli generate


This uses apollo-codegen-config.json:

Downloads the schema to GraphQL/Schema/RickMorty.graphqls

Generates schema & operation models into Generated/

4) Add your OpenAI API Key (two options)

Option A — Info.plist (simple):

Add a new key OpenAIAPIKey to your app Info.plist.

Value: your API key string.

The app reads it via:

// AppConfig.swift
var openAIKey: String {
  (Bundle.main.object(forInfoDictionaryKey: "OpenAIAPIKey") as? String) ?? ""
}


If empty/missing → the app falls back to StubLLM (no network).

Option B — Xcode build setting (kept out of VCS):

Create Config/Secrets.xcconfig (git-ignored) with:

OPENAI_API_KEY = sk-...


In Build Settings → Other Swift Flags (Debug/Release), add:

-D OPENAI_API_KEY=\"$(OPENAI_API_KEY)\"


Read it in AppConfig.swift using #if or ProcessInfo.processInfo.environment (your choice).
(Info.plist is simpler for this take-home.)

5) Run

Select a simulator and Run.

On first launch, Landing shows “AI: OpenAI (key detected)” or “AI: Stub (no key)”.

Chosen APIs

GraphQL: Rick & Morty API

Operations:

Characters (paginated list)

CharacterDetails (by id)

LLM: OpenAI gpt-3.5-turbo

Endpoint: POST /v1/chat/completions

Prompting kept short & deterministic-ish (temperature: 0.3)

When no key is set, the app uses StubLLM with canned responses.

Architecture

SwiftUI + MVVM

*ViewModel holds state, calls GraphQLService & LLMClient

Views are thin renderers

GraphQLClient (Apollo)

Configured with normalized cache (SQLite)

GraphQLService protocol to DI in tests

Cache policies used:

List: .returnCacheDataElseFetch for pagination

Detail: .returnCacheDataElseFetch (fast), .fetchIgnoringCacheCompletely on pull-to-refresh

LLMClient protocol

OpenAIClient (real) + StubLLM (fallback/testing)

summarizeCharacter & answerAboutCharacter

SummaryCache

Simple UserDefaults/file-based cache keyed by character id

Set on first summarize; shown immediately on next open

FavoritesStore

Set of favorite ids persisted in UserDefaults

Badge/toggle + “Favorites only” filter

Tests

Enable Apollo Test Mocks in apollo-codegen-config.json so codegen outputs RickMortyLLMTests/Generated/TestMocks.

In Xcode, add that folder to RickMortyLLMTests (Create groups, don’t copy).

Tests use:

MockGraphQLService (DI)

MockLLM (counts calls + returns fixed strings)

ApolloTestSupport.Mock<SchemaObject> → convert to SelectionSet with .from(...).

Run:

cmd + U     # in Xcode
# or CI: see .github/workflows/ios-ci.yml

Accessibility & Dark Mode

Uses Dynamic Type friendly text styles and minimumScaleFactor where needed.

Adds accessibility labels for AI summary and answers.

Colors rely on system roles for contrast; images have labels when important.

Dark Mode: the palette is system-adaptable; views use Materials and semantic colors.

CI (GitHub Actions)

Workflow at .github/workflows/ios-ci.yml:

Selects Xcode 16.2

Auto-picks a real simulator UDID from -showdestinations

Caches SPM, builds, runs unit tests

Uploads TestResults.xcresult artifact

If your project uses a workspace, swap -project → -workspace in the YAML.

Trade-offs & Limitations

LLM latency/cost: network round-trip & quota errors (handled; falls back to clear error).

Determinism: summaries can vary; we use a low temperature to reduce drift.

Caching: Apollo cache + small summary cache; not a full offline experience.

Schema/codegen coupling: generated files can be large; for the take-home, committed for simplicity.

Error handling: surfaced to the user via alerts/snackbars; could be richer (retry/backoff).

Privacy: Character context is sent to OpenAI only when “Summarize”/“Ask” is tapped.

Future Enhancements

Search & filters (species/status).

Offline summaries persisted with versioning.

Snapshot/UI tests with accessibility checks.

Multi-provider LLM swap (Cohere/Gemini) via the same LLMClient.

Better prompt templates & safety rails.

License & Credits

Rick & Morty API by rickandmortyapi.com

OpenAI API for LLM

This project is for educational/demo purposes.

Add your license of choice (MIT/Apache-2.0) as LICENSE.

Quick Setup TL;DR

Open in Xcode 16.x (scheme Shared)

(Optional) Run Apollo codegen: ./apollo-ios-cli fetch-schema && ./apollo-ios-cli generate

Add OpenAIAPIKey to Info.plist (or use StubLLM)

Run on simulator → tap a character → Summarize with AI / Ask a question
