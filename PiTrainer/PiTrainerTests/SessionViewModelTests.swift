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

@MainActor
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
    
    
    func saveSelectedGhostType(_ type: String) {}
    func loadSelectedGhostType() -> String? { return nil }
    func saveAutoAdvance(_ enabled: Bool) {}
    func loadAutoAdvance() -> Bool? { return nil }
    
    func saveLastChallengeDate(_ date: Date) {}
    func loadLastChallengeDate() -> Date? { return nil }
    
    func saveTotalCorrectDigits(_ count: Int) {}
    func loadTotalCorrectDigits() -> Int { 0 }
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
            personalBestProvider: { _, _ in nil } // Mock PB provider to avoid FS access
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
        
        print("debug: selected constant: \(viewModel.selectedConstant)")
        print("debug: engine provider digits: \(viewModel.engine.allDigitsString)")
        
        // Then: Engine should be ready but not yet active (timer hasn't started)
        XCTAssertFalse(viewModel.isActive, "Session should NOT be active immediately after startSession (ready state)")
        
        // Mock 'e' provider expects 7 first
        // Note: SessionMockDigitsProvider for .e returns [7, 1, 8, 2, 8]
        // 7 is the first digit (index 0).
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

    func testStrictMode_EndsSessionImmediatelyOnError() async {
        // Given: Strict mode session
        viewModel.selectedMode = .test
        XCTAssertEqual(viewModel.selectedMode.practiceEngineMode, .strict, "Test mode should map to strict engine mode")
        
        // Setup expectation
        let saveExpectation = XCTestExpectation(description: "Session persistence must be triggered on strict failure")
        viewModel.onSaveSession = { record in
            XCTAssertEqual(record.sessionMode, .test)
            XCTAssertEqual(record.errors, 1, "Record should reflect the error that caused termination")
            saveExpectation.fulfill()
        }
        
        viewModel.startSession()
        
        // Verify start conditions
        XCTAssertFalse(viewModel.isActive)
        
        // When: Input incorrect digit
        // Mock provider expects 1, input 9
        viewModel.processInput(9)
        
        // Then:
        // 1. Session should end immediately
        // Note: engine.isActive wraps state == .running. Strict mode sets state=.finished on error.
        XCTAssertFalse(viewModel.isActive, "Session should end immediately in strict mode on error")
        
        // 2. Error flash should be triggered
        XCTAssertTrue(viewModel.showErrorFlash, "Error flash should be triggered")
        
        // 3. User progress should not advance
        XCTAssertEqual(viewModel.typedDigits, "", "Typed digits should not update on error in strict mode")
        
        // 4. Wait for async save
        await fulfillment(of: [saveExpectation], timeout: 1.0)
    }
    
    func testRevealGranular_TracksCorrectCount() {
        // When: Call reveal with specific counts
        viewModel.reveal(count: 1)
        viewModel.reveal(count: 9)
        
        // Then: Counter should be 10
        XCTAssertEqual(viewModel.revealsUsed, 10)
    }
    
    func testEndSession_IncludesRevealsUsed() async {
        // Given: assistance used
        viewModel.startSession()
        viewModel.reveal(count: 5)
        
        // When: End session
        let expectation = XCTestExpectation(description: "Saves record with revealsUsed")
        viewModel.onSaveSession = { record in
            XCTAssertEqual(record.revealsUsed, 5)
            expectation.fulfill()
        }
        await viewModel.endSession()
        
        // Then: verify
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testEndSession_IncludesSpeedMetrics() async {
        // Given: some input to generate speed
        viewModel.startSession()
        viewModel.processInput(1) // 3.1
        
        // When: End session
        let expectation = XCTestExpectation(description: "Saves record with speed metrics")
        viewModel.onSaveSession = { record in
            XCTAssertNotNil(record.maxCPS)
            expectation.fulfill()
        }
        await viewModel.endSession()
        
        // Then: verify
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func testConfigureForChallenge_SetsEngineParameters() {
        // Given: A challenge
        let challenge = Challenge(
            id: UUID(),
            date: Date(),
            constant: .pi,
            startIndex: 100,
            referenceSequence: "12345",
            expectedNextDigits: "67890"
        )
        
        // When: Configure (Method doesn't exist yet - RED)
        viewModel.configureForChallenge(challenge)
        viewModel.startSession()
        
        // Then: Engine should be initialized with correct indices/mode
        XCTAssertEqual(viewModel.engine.startIndex, 100)
        XCTAssertEqual(viewModel.engine.endIndex, 105) // 100 + 5 (len of "12345")
        XCTAssertEqual(viewModel.selectedMode.practiceEngineMode, .game)
    }
}
