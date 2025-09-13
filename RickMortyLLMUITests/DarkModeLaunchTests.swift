//
//  DarkModeLaunchTests.swift
//  RickMortyLLMUITests
//
//  Created by Joshua Cleetus on 9/13/25.
//

import Foundation
import XCTest

final class DarkModeLaunchTests: XCTestCase {
  func testLaunchDarkMode() {
    let app = XCUIApplication()
    app.launchArguments += ["-AppleInterfaceStyle", "Dark"]
    app.launch()
    XCTAssertTrue(app.staticTexts["Rick & Morty Explorer"].exists)
  }
}
