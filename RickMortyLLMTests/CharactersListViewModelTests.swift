import XCTest
import Apollo
import ApolloTestSupport
@testable import RickMortyLLM

// Local mock service focused on list paging
@MainActor
final class ListMockGraphQLService: GraphQLService {
    // Pre-seeded pages: page -> (rows, next)
    var pages: [Int: ([CharactersQuery.Data.Characters.Result], Int?)] = [:]

    // Introspection for assertions
    private(set) var lastListPolicy: CachePolicy?
    private(set) var lastCharacterPolicy: CachePolicy?

    // List fetch
    func fetchCharacters(page: Int?, cachePolicy: CachePolicy) async throws
        -> ([CharactersQuery.Data.Characters.Result], next: Int?)
    {
        lastListPolicy = cachePolicy
        let key = page ?? 1
        return pages[key] ?? ([], nil)
    }

    // Not used in these tests, but required by protocol
    func fetchCharacter(id: String, cachePolicy: CachePolicy) async throws
        -> CharacterDetailsQuery.Data.Character?
    {
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

@MainActor
final class CharactersListViewModelTests: XCTestCase {

    func testLoadFirstPage_appendsAndSetsNext_cacheFirst() async {
        let svc = ListMockGraphQLService()
        let r1 = makeRow(id: "1", name: "Rick",  status: "Alive", species: "Human", image: "https://img1")
        let r2 = makeRow(id: "2", name: "Morty", status: "Alive", species: "Human", image: "https://img2")
        svc.pages[1] = ([r1, r2], 2)

        let vm = CharactersListViewModel(service: svc)
        await vm.loadNextPage()

        XCTAssertEqual(vm.items.map { $0.name ?? "" }, ["Rick", "Morty"])
        XCTAssertEqual(vm.nextPage, 2)
        XCTAssertEqual(svc.lastListPolicy, .returnCacheDataElseFetch)
    }

    func testLoadSecondPage_appendsUntilEnd() async {
        let svc = ListMockGraphQLService()
        svc.pages[1] = ([makeRow(id: "1", name: "Rick")], 2)
        svc.pages[2] = ([makeRow(id: "3", name: "Summer")], nil)

        let vm = CharactersListViewModel(service: svc)
        await vm.loadNextPage() // loads page 1
        await vm.loadNextPage() // loads page 2

        XCTAssertEqual(vm.items.map { $0.name ?? "" }, ["Rick", "Summer"])
        XCTAssertNil(vm.nextPage) // reached the end
    }

    func testRefresh_networkOnly_resetsItemsAndNext() async {
        let svc = ListMockGraphQLService()
        // First load returns Rick + indicates another page
        svc.pages[1] = ([makeRow(id: "1", name: "Rick")], 2)

        let vm = CharactersListViewModel(service: svc)
        await vm.loadNextPage()
        XCTAssertEqual(vm.items.map { $0.name ?? "" }, ["Rick"])
        XCTAssertEqual(vm.nextPage, 2)

        // Change server data then refresh (should bypass cache)
        svc.pages[1] = ([makeRow(id: "2", name: "Morty")], nil)
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
}

