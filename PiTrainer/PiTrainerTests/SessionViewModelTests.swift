//
//  SessionViewModelTests.swift
//  PiTrainerTests
//
//  Created by Alexandre SAHUT on 12/01/2026.
//

import XCTest
@testable import PiTrainer

// Mocks unique to SessionViewModelTests
class SessionMockDigitsProvider: DigitsProvider {
    var digits = [1, 4, 1, 5, 9]
    var totalDigits: Int { digits.count }
    
    init() { }
    
    func getDigit(at index: Int) -> Int? { 
        guard index < digits.count else { return nil }
        return digits[index] 
    }
    func loadDigits() throws {}
}

class SessionMockPracticePersistence: PracticePersistenceProtocol {
    init() { }
    func saveHighestIndex(_ index: Int, for constantKey: String) {}
    func getHighestIndex(for constantKey: String) -> Int { return 0 }
}

@MainActor
final class SessionViewModelTests: XCTestCase {
    
    var statsStore: StatsStore!
    var viewModel: SessionViewModel!
    var testDefaults: UserDefaults!
    var persistence: SessionMockPracticePersistence!
    
    override func setUp() async throws {
        try await super.setUp()

        let suiteName = "SessionViewModelTests-\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("Failed to create user defaults")
        }
        testDefaults = defaults
        testDefaults.removePersistentDomain(forName: suiteName)
        
        statsStore = StatsStore(userDefaults: testDefaults)
        persistence = SessionMockPracticePersistence()
        
        viewModel = SessionViewModel(
            persistence: persistence,
            providerFactory: { _ in 
                return SessionMockDigitsProvider() 
            }
        )

    }

    
    override func tearDown() {
        viewModel = nil
        statsStore = nil
        testDefaults = nil
        super.tearDown()
    }
    
    func testStartSession_UsesSelectedConstant() {
        // Given: Selection 'e'
        statsStore.selectedConstant = .e
        // Configure VM manually as HomeView would
        viewModel.selectedConstant = .e
        
        // When: Start session
        viewModel.startSession()
        
        // Then: Engine should be active and expect 1 (Mock provider uses 1, 4, 1...)
        XCTAssertTrue(viewModel.isActive, "Session should be active after startSession")
        
        viewModel.processInput(1)
        
        XCTAssertEqual(viewModel.lastCorrectDigit, 1, "VM should register 1 as correct from mock provider")
        XCTAssertEqual(viewModel.typedDigits, "1")
        XCTAssertNil(viewModel.expectedDigit)
    }
    
    func testStartSession_SwitchesBackToPi() {
        // Given: Started with e
        statsStore.selectedConstant = .e
        viewModel.selectedConstant = .e
        viewModel.startSession()
        XCTAssertTrue(viewModel.isActive)
        
        // When: Switch back to Pi
        statsStore.selectedConstant = .pi
        viewModel.selectedConstant = .pi
        viewModel.startSession()
        
        // Then: Engine should be active and expect 1
        XCTAssertTrue(viewModel.isActive, "Session should be active after switching back to Pi")
        viewModel.processInput(1)
        
        XCTAssertEqual(viewModel.lastCorrectDigit, 1, "VM should register 1 as correct when Pi is selected")
        XCTAssertEqual(viewModel.typedDigits, "1")
    }

    func testStrictMode_EndsSessionImmediatelyOnError() {
        // Given: Strict mode session
        viewModel.selectedMode = .strict
        viewModel.startSession()
        
        // Verify start conditions
        XCTAssertTrue(viewModel.isActive)
        XCTAssertFalse(viewModel.showErrorFlash)
        
        // When: Input incorrect digit
        // Mock provider expects 1, input 9
        viewModel.processInput(9)
        
        // Then:
        // 1. Session should end immediately
        XCTAssertFalse(viewModel.isActive, "Session should end immediately in strict mode on error")
        
        // 2. Error flash should be triggered
        // Note: showErrorFlash is animated, but the property should be true immediately inside the withAnimation block
        XCTAssertTrue(viewModel.showErrorFlash, "Error flash should be triggered")
        
        // 3. User progress should not advance (typedDigits same)
        XCTAssertEqual(viewModel.typedDigits, "", "Typed digits should not update on error in strict mode")
        
        // 4. Session data should be saved
        let saveExpectation = XCTestExpectation(description: "Session persistence should be triggered")
        viewModel.onSaveSession = { record in
            XCTAssertEqual(record.mode, .strict)
            XCTAssertEqual(record.errors, 1)
            saveExpectation.fulfill()
        }
        
        // Re-trigger input to separate expectation setup from previous actions if needed, 
        // but since the previous input already ended the session, we need to reset and retry 
        // OR better: Start a fresh flow in this test with the expectation set UP FRONT.
        
        // Let's restart the flow for clarity:
        viewModel.reset()
        viewModel.selectedMode = .strict
        
        // Setup expectation BEFORE input
        let saveExpectation2 = XCTestExpectation(description: "Session persistence must be triggered on strict failure")
        viewModel.onSaveSession = { record in
            XCTAssertEqual(record.mode, .strict)
            XCTAssertEqual(record.errors, 1) // 1 error causes end
            saveExpectation2.fulfill()
        }
        
        viewModel.startSession()
        viewModel.processInput(9) // Incorrect
        
        wait(for: [saveExpectation2], timeout: 1.0)
    }
}
