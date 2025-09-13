//
//  FavoritesStoreTests.swift
//  RickMortyLLM
//
//  Created by Joshua Cleetus on 9/13/25.
//

import Foundation
import XCTest
@testable import RickMortyLLM

final class FavoritesStoreTests: XCTestCase {
    @MainActor
    func testTogglePersists() {
        let store = FavoritesStore.shared

        // clean slate for these ids
        ["X","Y"].forEach { if store.contains($0) { store.remove($0) } }

        store.add("X")
        XCTAssertTrue(store.contains("X"))

        store.toggle("X") // remove
        XCTAssertFalse(store.contains("X"))

        store.toggle("Y") // add
        XCTAssertTrue(store.contains("Y"))
    }
}
