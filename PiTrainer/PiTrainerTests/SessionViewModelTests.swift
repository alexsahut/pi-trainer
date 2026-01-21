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
    private let constant: Constant
    private var digits: [UInt8] = []
    
    var totalDigits: Int { digits.count }
    var allDigitsString: String { digits.map { String($0) }.joined() }
    
    init(constant: Constant = .pi) { 
        self.constant = constant
        // Return first 5 decimals based on constant
        switch constant {
        case .pi:    digits = [1, 4, 1, 5, 9]
        case .e:     digits = [7, 1, 8, 2, 8]
        case .phi:   digits = [6, 1, 8, 0, 3]
        case .sqrt2: digits = [4, 1, 4, 2, 1]
        }
    }
    
    func getDigit(at index: Int) -> Int? { 
        guard index < digits.count else { return nil }
        return Int(digits[index]) 
    }
    func loadDigits() throws {}
}

class SessionMockPracticePersistence: PracticePersistenceProtocol {
    init() { }
    func saveHighestIndex(_ index: Int, for constantKey: String) {}
    func getHighestIndex(for constantKey: String) -> Int { return 0 }
    func saveStats(_ stats: [Constant: ConstantStats]) {}
    func loadStats() -> [Constant: ConstantStats]? { return nil }
    func saveKeypadLayout(_ layout: String) {}
    func loadKeypadLayout() -> String? { return nil }
    func saveSelectedConstant(_ constant: String) {}
    func loadSelectedConstant() -> String? { return nil }
    
    // Added for Protocol Conformance
    var userDefaults: UserDefaults { return .standard } // Mock return
    func saveSelectedMode(_ mode: String) {}
    func loadSelectedMode() -> String? { return nil }
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
        
        let persistenceService = PracticePersistence(userDefaults: testDefaults)
        statsStore = StatsStore(persistence: persistenceService)
        persistence = SessionMockPracticePersistence()
        
        viewModel = SessionViewModel(
            persistence: persistence,
            providerFactory: { constant in 
                return SessionMockDigitsProvider(constant: constant) 
            },
            personalBestProvider: { _ in nil } // Mock PB provider to avoid FS access
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
        
        // Then: Engine should be ready but not yet active (timer hasn't started)
        XCTAssertFalse(viewModel.isActive, "Session should NOT be active immediately after startSession (ready state)")
        
        // Mock 'e' provider expects 7 first
        viewModel.processInput(7)
        
        XCTAssertTrue(viewModel.isActive, "Session should be active after first input")
        XCTAssertEqual(viewModel.lastCorrectDigit, 7, "VM should register 7 as correct from mock 'e' provider")
        XCTAssertEqual(viewModel.typedDigits, "7")
        XCTAssertNil(viewModel.expectedDigit)
    }
    
    func testStartSession_SwitchesBackToPi() {
        // Given: Started with e
        statsStore.selectedConstant = .e
        viewModel.selectedConstant = .e
        viewModel.startSession()
        XCTAssertFalse(viewModel.isActive, "Session should NOT be active after startSession")
        
        // When: Switch back to Pi
        statsStore.selectedConstant = .pi
        viewModel.selectedConstant = .pi
        viewModel.startSession()
        
        // Then: Engine should be ready but not yet active
        XCTAssertFalse(viewModel.isActive, "Session should NOT be active after switching back to Pi")
        
        viewModel.processInput(1)
        
        XCTAssertTrue(viewModel.isActive, "Session should be active after input")
        XCTAssertEqual(viewModel.lastCorrectDigit, 1, "VM should register 1 as correct when Pi is selected")
        XCTAssertEqual(viewModel.typedDigits, "1")
    }

    func testStrictMode_EndsSessionImmediatelyOnError() {
        // Given: Strict mode session
        viewModel.selectedMode = .test
        viewModel.startSession()
        
        // Verify start conditions
        XCTAssertFalse(viewModel.isActive)
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
            XCTAssertEqual(record.sessionMode, .test)
            XCTAssertEqual(record.errors, 1)
            saveExpectation.fulfill()
        }
        
        // Re-trigger input to separate expectation setup from previous actions if needed, 
        // but since the previous input already ended the session, we need to reset and retry 
        // OR better: Start a fresh flow in this test with the expectation set UP FRONT.
        
        // Let's restart the flow for clarity:
        viewModel.reset()
        viewModel.selectedMode = .test
        
        // Setup expectation BEFORE input
        let saveExpectation2 = XCTestExpectation(description: "Session persistence must be triggered on strict failure")
        viewModel.onSaveSession = { record in
            XCTAssertEqual(record.sessionMode, .test)
            XCTAssertEqual(record.errors, 1) // 1 error causes end
            saveExpectation2.fulfill()
        }
        
        viewModel.startSession()
        viewModel.processInput(9) // Incorrect
        
        wait(for: [saveExpectation2], timeout: 1.0)
    }
    
    func testRevealGranular_TracksCorrectCount() {
        // When: Call reveal with specific counts
        viewModel.reveal(count: 1)
        viewModel.reveal(count: 9)
        
        // Then: Counter should be 10
        XCTAssertEqual(viewModel.revealsUsed, 10)
    }
    
    func testEndSession_IncludesRevealsUsed() {
        // Given: assistance used
        viewModel.startSession()
        viewModel.reveal(count: 5)
        
        // When: End session
        let expectation = XCTestExpectation(description: "Saves record with revealsUsed")
        viewModel.onSaveSession = { record in
            XCTAssertEqual(record.revealsUsed, 5)
            expectation.fulfill()
        }
        viewModel.endSession()
        
        // Then: verify
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testEndSession_IncludesSpeedMetrics() {
        // Given: some input to generate speed
        viewModel.startSession()
        viewModel.processInput(1) // 3.1
        
        // When: End session
        let expectation = XCTestExpectation(description: "Saves record with speed metrics")
        viewModel.onSaveSession = { record in
            XCTAssertNotNil(record.maxCPS)
            expectation.fulfill()
        }
        viewModel.endSession()
        
        // Then: verify
        wait(for: [expectation], timeout: 1.0)
    }
}
