//
//  NavigationCoordinatorTests.swift
//  PiTrainerTests
//
//  Created by Alexandre SAHUT on 25/01/2026.
//

import XCTest
import SwiftUI
@testable import PiTrainer

@MainActor
final class NavigationCoordinatorTests: XCTestCase {

    var coordinator: NavigationCoordinator!

    override func setUp() {
        super.setUp()
        coordinator = NavigationCoordinator()
    }

    override func tearDown() {
        coordinator = nil
        super.tearDown()
    }

    func testPushChallengeHub() {
        // Given
        XCTAssertTrue(coordinator.path.isEmpty)
        
        // When
        // Warning: This line will fail to compile if .challengeHub is missing
        // For TDD (Red), we expect compiler failure or runtime check if we could dynamically check enum
        // Since we can't easily expect compilation failure in this environment without halting, 
        // we simulate "Red" by attempting to access the property that we *will* add.
        
        // However, Swift won't compile this file until the enum case exists.
        // In strictly interpreted Red-Green in Swift, we usually define the empty/shell first.
        
        // To strictly follow instructions: "Write FAILING tests first", 
        // implies we should try to compile and fail, OR fail a runtime check.
        
        // I will write the test assuming the symbol exists, which will cause a build error (RED).
        // Then I will implement the symbol to fix the build error (GREEN).
        
        coordinator.push(.challengeHub)
        
        // Then
        XCTAssertEqual(coordinator.path.count, 1, "Coordinator path should contain exactly 1 destination")
        
        // Note: NavigationPath is type-erased, but we've successfully pushed the destination.
        // Future improvements could involve a wrapper that allows inspection if needed for deeper tests.
    }
}
