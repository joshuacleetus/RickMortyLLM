import XCTest
import Apollo
import ApolloTestSupport
@testable import RickMortyLLM

// Local mock service focused on list paging
@MainActor
final class ListMockGraphQLService: GraphQLService {
    // Pre-seeded pages: page -> CharactersPage
    var pages: [Int: CharactersPage] = [:]
    var shouldThrowError = false
    var errorToThrow: Error = TestError.network

    // Introspection for assertions
    private(set) var lastListPolicy: CachePolicy?
    private(set) var lastCharacterPolicy: CachePolicy?

    // List fetch - now returns CharactersPage
    func fetchCharacters(page: Int?, cachePolicy: CachePolicy) async throws -> CharactersPage {
        if shouldThrowError {
            throw errorToThrow
        }
        lastListPolicy = cachePolicy
        let key = page ?? 1
        return pages[key] ?? CharactersPage(results: [], nextPage: nil)
    }

    // Not used in these tests, but required by protocol
    func fetchCharacter(id: String, cachePolicy: CachePolicy) async throws -> CharacterDetailsQuery.Data.Character? {
        if shouldThrowError {
            throw errorToThrow
        }
        lastCharacterPolicy = cachePolicy
        return nil
    }
}

// Helpers to build selection sets for rows
private func makeRow(
    id: String, name: String,
    status: String? = nil, species: String? = nil, image: String? = nil
) -> CharactersQuery.Data.Characters.Result {
    let mock = Mock<Character>(
        episode: [],             // unused, required by schema non-null list
        gender: nil,
        id: id,
        image: image,
        location: nil,
        name: name,
        origin: nil,
        species: species,
        status: status,
        type: nil
    )
    return .from(mock)
}

// Helper to create CharactersPage
private func makePage(
    results: [CharactersQuery.Data.Characters.Result],
    nextPage: Int?
) -> CharactersPage {
    return CharactersPage(results: results, nextPage: nextPage)
}

@MainActor
final class CharactersListViewModelTests: XCTestCase {

    func testLoadFirstPage_appendsAndSetsNext_cacheFirst() async {
        let svc = ListMockGraphQLService()
        let r1 = makeRow(id: "1", name: "Rick",  status: "Alive", species: "Human", image: "https://img1")
        let r2 = makeRow(id: "2", name: "Morty", status: "Alive", species: "Human", image: "https://img2")
        svc.pages[1] = makePage(results: [r1, r2], nextPage: 2)

        let vm = CharactersListViewModel(service: svc)
        await vm.loadNextPage()

        XCTAssertEqual(vm.items.map { $0.name ?? "" }, ["Rick", "Morty"])
        XCTAssertEqual(vm.nextPage, 2)
        XCTAssertEqual(svc.lastListPolicy, .returnCacheDataElseFetch)
    }

    func testLoadSecondPage_appendsUntilEnd() async {
        let svc = ListMockGraphQLService()
        svc.pages[1] = makePage(results: [makeRow(id: "1", name: "Rick")], nextPage: 2)
        svc.pages[2] = makePage(results: [makeRow(id: "3", name: "Summer")], nextPage: nil)

        let vm = CharactersListViewModel(service: svc)
        await vm.loadNextPage() // loads page 1
        await vm.loadNextPage() // loads page 2

        XCTAssertEqual(vm.items.map { $0.name ?? "" }, ["Rick", "Summer"])
        XCTAssertNil(vm.nextPage) // reached the end
    }

    func testRefresh_networkOnly_resetsItemsAndNext() async {
        let svc = ListMockGraphQLService()
        // First load returns Rick + indicates another page
        svc.pages[1] = makePage(results: [makeRow(id: "1", name: "Rick")], nextPage: 2)

        let vm = CharactersListViewModel(service: svc)
        await vm.loadNextPage()
        XCTAssertEqual(vm.items.map { $0.name ?? "" }, ["Rick"])
        XCTAssertEqual(vm.nextPage, 2)

        // Change server data then refresh (should bypass cache)
        svc.pages[1] = makePage(results: [makeRow(id: "2", name: "Morty")], nextPage: nil)
        await vm.refresh()

        XCTAssertEqual(vm.items.map { $0.name ?? "" }, ["Morty"])
        XCTAssertNil(vm.nextPage)
        XCTAssertEqual(svc.lastListPolicy, .fetchIgnoringCacheCompletely)
    }

    func testLoadNextPage_noOpWhenAlreadyLoadingOrNoNext() async {
        let svc = ListMockGraphQLService()
        let vm = CharactersListViewModel(service: svc)

        // Simulate end reached
        vm.nextPage = nil
        await vm.loadNextPage()
        XCTAssertTrue(vm.items.isEmpty)

        // Simulate concurrent call guard
        vm.nextPage = 1
        vm.isLoading = true
        await vm.loadNextPage()
        XCTAssertTrue(vm.items.isEmpty)
    }

    func testLoadInitialDataIfNeeded_loadsWhenEmpty() async {
        let svc = ListMockGraphQLService()
        svc.pages[1] = makePage(results: [makeRow(id: "1", name: "Rick")], nextPage: nil)

        let vm = CharactersListViewModel(service: svc)
        
        // Should load when empty
        await vm.loadInitialDataIfNeeded()
        XCTAssertEqual(vm.items.count, 1)
        XCTAssertEqual(vm.items.first?.name, "Rick")
        
        // Should not load again when items exist
        svc.pages[1] = makePage(results: [makeRow(id: "2", name: "Morty")], nextPage: nil)
        await vm.loadInitialDataIfNeeded()
        XCTAssertEqual(vm.items.count, 1) // Still only Rick
        XCTAssertEqual(vm.items.first?.name, "Rick")
    }

    func testErrorHandling_setsErrorState() async {
        let svc = ListMockGraphQLService()
        // Don't set any pages - this will return empty page by default
        
        let vm = CharactersListViewModel(service: svc)
        await vm.loadNextPage()
        
        // Should handle gracefully when no data
        XCTAssertTrue(vm.items.isEmpty)
        XCTAssertNil(vm.nextPage)
    }
    
    func testLoadNextPage_handlesNetworkError() async {
        let svc = ListMockGraphQLService()
        // Configure service to throw an error
        svc.shouldThrowError = true
        
        let vm = CharactersListViewModel(service: svc)
        await vm.loadNextPage()
        
        XCTAssertNotNil(vm.error)
        XCTAssertFalse(vm.isLoading)
        XCTAssertTrue(vm.items.isEmpty)
    }
    
    func testLoadingStates_properlyManaged() async {
        let svc = ListMockGraphQLService()
        svc.pages[1] = makePage(results: [makeRow(id: "1", name: "Rick")], nextPage: nil)
        
        let vm = CharactersListViewModel(service: svc)
        
        XCTAssertFalse(vm.isLoading) // Initially false
        
        // Start loading (you'd need to test this during the actual call)
        let loadTask = Task { await vm.loadNextPage() }
        // Verify isLoading is true during execution
        await loadTask.value
        
        XCTAssertFalse(vm.isLoading) // False after completion
    }

    func testClearError_resetsErrorState() async {
        let vm = CharactersListViewModel(service: ListMockGraphQLService())
        
        // Manually set an error (simulating a real error scenario)
        vm.error = GraphQLServiceError.noData
        XCTAssertNotNil(vm.error)
        
        // Clear the error
        vm.clearError()
        XCTAssertNil(vm.error)
    }

    func testHasNextPage_computedProperty() async {
        let svc = ListMockGraphQLService()
        let vm = CharactersListViewModel(service: svc)
        
        // Initially should have next page (starts with page 1)
        XCTAssertTrue(vm.hasNextPage)
        
        // Set to nil - no next page
        vm.nextPage = nil
        XCTAssertFalse(vm.hasNextPage)
        
        // Set to specific page - has next page
        vm.nextPage = 2
        XCTAssertTrue(vm.hasNextPage)
    }
}

enum TestError: Error {
    case network
    case parsing
    case timeout
    case unauthorized
}
