//  CharacterDetailViewModelTests.swift
//  RickMortyLLMTests

import XCTest
import Apollo               
import ApolloTestSupport
@testable import RickMortyLLM


@MainActor
final class CharacterDetailViewModelTests: XCTestCase {

    // Helper: build a Character selection set from a schema mock
    private func makeCharacter(
        id: String, name: String,
        status: String? = nil, species: String? = nil,
        gender: String? = nil, image: String? = nil,
        origin: String? = nil, location: String? = nil
    ) -> CharacterDetailsQuery.Data.Character {
        let mock = Mock<Character>(
            episode: [],
            gender: gender,
            id: id,
            image: image,
            location: location.map { Mock<Location>(name: $0) },
            name: name,
            origin: origin.map { Mock<Location>(name: $0) },
            species: species,
            status: status,
            type: nil
        )
        // Convert schema mock -> selection set used by the VM
        return .from(mock)
    }

    func testLoad_usesCacheFirst_andSetsCharacter() async {
        let svc = MockGraphQLService()
        svc.characterByID["1"] = makeCharacter(
            id: "1", name: "Rick Sanchez", status: "Alive",
            species: "Human", gender: "Male", image: "https://img",
            origin: "Earth (C-137)", location: "Citadel of Ricks"
        )

        // Pre-seed summary cache to verify it surfaces immediately
        SummaryCache.write("Cached summary", for: "1")
        defer { SummaryCache.remove(for: "1") }

        let vm = CharacterDetailViewModel(llm: MockLLM(), service: svc)
        await vm.load(id: "1")

        XCTAssertEqual(vm.character?.name, "Rick Sanchez")
        XCTAssertEqual(vm.summary, "Cached summary") // came from cache
        XCTAssertEqual(svc.lastCharacterPolicy, .returnCacheDataElseFetch)
    }

    func testRefresh_bypassesCache() async {
        let svc = MockGraphQLService()
        svc.characterByID["1"] = makeCharacter(id: "1", name: "Rick")
        let vm = CharacterDetailViewModel(llm: MockLLM(), service: svc)

        await vm.load(id: "1")
        await vm.refresh()

        XCTAssertEqual(svc.lastCharacterPolicy, .fetchIgnoringCacheCompletely)
    }

    func testSummarize_skipsWhenAlreadyHaveSummary_unlessForced() async {
        let svc = MockGraphQLService()
        svc.characterByID["2"] = makeCharacter(id: "2", name: "Morty")
        let llm = MockLLM()
        let vm = CharacterDetailViewModel(llm: llm, service: svc)

        await vm.load(id: "2")
        vm.summary = "Existing" // simulate cached/previous summary

        // Should NOT call LLM
        await vm.summarize()
        XCTAssertEqual(llm.summarizeCallCount, 0)

        // Force refresh should call LLM and update text + cache
        await vm.summarize(forceRefresh: true)
        XCTAssertEqual(llm.summarizeCallCount, 1)
        XCTAssertEqual(vm.summary, "Mock summary")
        XCTAssertEqual(SummaryCache.read(for: "2"), "Mock summary")
        SummaryCache.remove(for: "2")
    }

    func testClearCachedSummary_removesCacheAndMemory() async {
        let svc = MockGraphQLService()
        svc.characterByID["3"] = makeCharacter(id: "3", name: "Summer")
        let vm = CharacterDetailViewModel(llm: MockLLM(), service: svc)

        await vm.load(id: "3")
        SummaryCache.write("Hello", for: "3")
        vm.summary = "Hello"

        vm.clearCachedSummary()

        XCTAssertNil(vm.summary)
        XCTAssertNil(SummaryCache.read(for: "3"))
    }

    func testAsk_callsLLM_andSetsAnswer() async {
        let svc = MockGraphQLService()
        svc.characterByID["4"] = makeCharacter(id: "4", name: "Beth")
        let llm = MockLLM()
        let vm = CharacterDetailViewModel(llm: llm, service: svc)

        await vm.load(id: "4")
        vm.question = "Is Beth human?"
        await vm.ask()

        XCTAssertEqual(llm.answerCallCount, 1)
        XCTAssertEqual(vm.answer, "Mock answer")
        XCTAssertFalse(vm.isAnswering)
    }

    func testAsk_ignoresEmptyQuestion() async {
        let svc = MockGraphQLService()
        svc.characterByID["5"] = makeCharacter(id: "5", name: "Jerry")
        let llm = MockLLM()
        let vm = CharacterDetailViewModel(llm: llm, service: svc)

        await vm.load(id: "5")
        vm.question = "   " // whitespace only
        await vm.ask()

        XCTAssertEqual(llm.answerCallCount, 0)
        XCTAssertNil(vm.answer)
    }
}

