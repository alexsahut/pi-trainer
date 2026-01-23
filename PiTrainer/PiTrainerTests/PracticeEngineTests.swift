import XCTest
@testable import PiTrainer

class MockPracticePersistence: PracticePersistenceProtocol {
    var savedIndex: Int?
    var savedKey: String?
    var highestIndexToReturn: Int = 0
    var saveCallCount = 0
    
    func saveHighestIndex(_ index: Int, for constantKey: String) {
        savedIndex = index
        savedKey = constantKey
        saveCallCount += 1
    }
    
    func getHighestIndex(for constantKey: String) -> Int {
        return highestIndexToReturn
    }
    
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

final class MockDigitsProvider: DigitsProvider {
    var totalDigits: Int = 100
    var digits: [Int] = [1, 4, 1, 5, 9, 2, 6, 5, 3, 5] // First few digits of Pi
    
    var allDigitsString: String {
        return digits.map { String($0) }.joined()
    }
    
    func getDigit(at index: Int) -> Int? {
        guard index < totalDigits else { return nil }
        return digits[index % digits.count]
    }
    
    func loadDigits() throws {
        // No-op for mock
    }
}

final class PracticeEngineTests: XCTestCase {
    
    var provider: MockDigitsProvider!
    var persistence: MockPracticePersistence!
    var engine: PracticeEngine!
    
    override func setUp() {
        super.setUp()
        provider = MockDigitsProvider()
        persistence = MockPracticePersistence()
        // Default to Pi for general tests
        engine = PracticeEngine(constant: .pi, provider: provider, persistence: persistence)
    }
    
    // MARK: - Core Input Logic
    
    func testInputResult_Correct_ReturnsCorrectValidationResult() {
        try? engine.start(mode: .strict)
        // Expected: 1
        let result = engine.input(digit: 1)
        
        guard case .correct = result.validationResult else {
            XCTFail("Expected .correct, got \(result.validationResult)")
            return
        }
        XCTAssertTrue(result.isCorrect)
    }
    
    func testInputResult_Incorrect_ReturnsIncorrectValidationResult() {
        try? engine.start(mode: .strict)
        // Expected: 1, Input: 9
        let result = engine.input(digit: 9)
        
        if case let .incorrect(expected, actual) = result.validationResult {
            XCTAssertEqual(expected, 1)
            XCTAssertEqual(actual, 9)
        } else {
            XCTFail("Expected .incorrect(expected: 1, actual: 9), got \(result.validationResult)")
        }
        XCTAssertFalse(result.isCorrect)
    }
    
    // MARK: - Mode Logic
    
    func testStrictMode_EndsSessionOnFailure() {
        try? engine.start(mode: .strict)
        
        // Fail
        let result = engine.input(digit: 9)
        
        XCTAssertFalse(result.indexAdvanced)
        // Strict mode failure should END session
        XCTAssertFalse(engine.isActive)
        XCTAssertEqual(engine.currentIndex, 0)
        XCTAssertEqual(engine.errors, 1)
        XCTAssertEqual(engine.currentStreak, 0)
    }
    
    func testLearningMode_AdvancesOnFailure() {
        try? engine.start(mode: .learning)
        
        // Fail
        let result = engine.input(digit: 9)
        
        // Learning mode should continue but NOT advance (retry)
        XCTAssertTrue(engine.isActive)
        XCTAssertFalse(result.indexAdvanced)
        XCTAssertEqual(engine.currentIndex, 0) // Stay on index 0
        XCTAssertEqual(engine.errors, 1)
        XCTAssertEqual(engine.currentStreak, 0)
    }
    
    // MARK: - State Management
    
    func testStreak_IncrementsOnSuccess() {
        try? engine.start(mode: .strict)
        // 1
        _ = engine.input(digit: 1)
        XCTAssertEqual(engine.currentStreak, 1)
        
        // 4
        _ = engine.input(digit: 4)
        XCTAssertEqual(engine.currentStreak, 2)
        
        XCTAssertEqual(engine.bestStreak, 2)
    }
    
    func testReset_ClearsState() {
        try? engine.start(mode: .strict)
        _ = engine.input(digit: 1)
        XCTAssertEqual(engine.currentIndex, 1)
        
        engine.reset()
        
        XCTAssertFalse(engine.isActive)
        XCTAssertEqual(engine.currentIndex, 0)
        XCTAssertEqual(engine.attempts, 0)
        XCTAssertEqual(engine.errors, 0)
    }
    
    // MARK: - Advanced Features (moved from AdvancedTests)
    
    func testBackspace_DecrementsIndex() {
        try? engine.start(mode: .strict)
        _ = engine.input(digit: 1) // Advance to index 1
        _ = engine.input(digit: 4) // Advance to index 2
        XCTAssertEqual(engine.currentIndex, 2)
        
        engine.backspace()
        XCTAssertEqual(engine.currentIndex, 1)
    }

    // MARK: - State Management (New for Story 3.2)

    func testStart_SetsStateToReady() {
        try? engine.start(mode: .strict)
        // Should be ready but not yet active/running
        XCTAssertEqual(engine.state, .ready)
        XCTAssertFalse(engine.isActive) // isActive tracks .running only
    }

    func testFirstInput_TransitionsToRunning() {
        try? engine.start(mode: .strict)
        
        // First input
        _ = engine.input(digit: 1)
        
        XCTAssertEqual(engine.state, .running)
        XCTAssertTrue(engine.isActive)
        // Timer should have started now
        Thread.sleep(forTimeInterval: 0.1)
        XCTAssertGreaterThan(engine.elapsedTime, 0.05)
    }

    func testInput_WhenIdle_ReturnsIncorrectAndMaintainsState() {
        // Engine not started, state should be .idle (default)
        // Note: verify default state is idle if exposed, or assume start() hasn't been called
        
        let result = engine.input(digit: 1)
        XCTAssertFalse(result.indexAdvanced)
        XCTAssertFalse(result.isCorrect)
        XCTAssertEqual(engine.currentIndex, 0)
    }
    
    func testElapsedTime_ZeroInReadyState() {
        try? engine.start(mode: .strict)
        Thread.sleep(forTimeInterval: 0.1)
        // Should be 0 because timer starts on first input
        XCTAssertEqual(engine.elapsedTime, 0)
    }

    
    func testElapsedTime_IncreasesAfterStart() throws {
        try engine.start(mode: .strict)
        // Auto-start: timer only starts after first input
        _ = engine.input(digit: 1) // Start timer
        
        Thread.sleep(forTimeInterval: 0.1) // 100ms
        XCTAssertGreaterThan(engine.elapsedTime, 0.05, "Elapsed time should be > 50ms")
    }
    
    func testInput_WhenNotActive_ReturnsInactiveResult() {
        XCTAssertFalse(engine.isActive)
        let result = engine.input(digit: 1)
        XCTAssertFalse(result.isCorrect)
        XCTAssertFalse(result.indexAdvanced)
        XCTAssertEqual(engine.currentIndex, 0)
    }
    
    // MARK: - Persistence Integration
    
    func testPersistence_SavedOnCorrectInput() {
        // Setup with specific constant
        let engine = PracticeEngine(constant: .e, provider: provider, persistence: persistence)
        try? engine.start(mode: .strict)
        
        // 1 (Mock provider returns digits from Pi array, so 1 is correct for index 0 regardless of constant logic in this mock)
        _ = engine.input(digit: 1)
        
        XCTAssertEqual(persistence.saveCallCount, 1)
        XCTAssertEqual(persistence.savedIndex, 0)
        XCTAssertEqual(persistence.savedKey, "e") // Verify constant ID is used
    }
    
    func testPersistence_NotSavedOnIncorrectInput() {
        try? engine.start(mode: .strict)
        _ = engine.input(digit: 9)
        
        XCTAssertEqual(persistence.saveCallCount, 0)
    }
}

// MARK: - Story 9.4: Game Mode

final class PracticeEngineGameModeTests: XCTestCase {
    
    var provider: MockDigitsProvider!
    var persistence: MockPracticePersistence!
    var engine: PracticeEngine!
    
    override func setUp() {
        super.setUp()
        provider = MockDigitsProvider()
        persistence = MockPracticePersistence()
        // Default to Pi
        engine = PracticeEngine(constant: .pi, provider: provider, persistence: persistence)
    }

    func testGameMode_ErrorDoesNotEndSession() {
        // AC 1: La session ne s'arrête pas en cas d'erreur en mode GAME.
        engine.start(mode: .game)
        
        // Expected: 1, Input: 9 (Error)
        let result = engine.input(digit: 9)
        
        XCTAssertTrue(engine.isActive, "Session should remain active after error in Game Mode")
        XCTAssertFalse(result.indexAdvanced, "Index should not advance on error")
        XCTAssertEqual(engine.errors, 1, "Error count should increment")
    }

    func testGameMode_ErrorDoesNotAdvanceIndex() {
        // AC 2: L'utilisateur doit saisir le chiffre correct pour avancer
        engine.start(mode: .game)
        
        // Initial state
        XCTAssertEqual(engine.currentIndex, 0)
        
        // Input Error
        _ = engine.input(digit: 9)
        
        XCTAssertEqual(engine.currentIndex, 0, "Index should stay at 0 after error")
    }

    func testGameMode_CorrectInputAfterErrorAdvances() {
        // AC 2: L'utilisateur doit saisir le chiffre correct pour avancer
        engine.start(mode: .game)
        
        // 1. Error
        _ = engine.input(digit: 9)
        XCTAssertEqual(engine.currentIndex, 0)
        
        // 2. Correct Input (1)
        let result = engine.input(digit: 1)
        
        XCTAssertTrue(result.isCorrect)
        XCTAssertTrue(result.indexAdvanced)
        XCTAssertEqual(engine.currentIndex, 1, "Index should advance after correction")
        XCTAssertEqual(engine.errors, 1, "Error count should persist")
    }
    
    func testGameMode_MultipleErrorsAccumulate() {
        // AC 4 check (errors count)
        engine.start(mode: .game)
        
        _ = engine.input(digit: 9) // Error 1
        _ = engine.input(digit: 8) // Error 2
        
        XCTAssertEqual(engine.errors, 2)
        XCTAssertEqual(engine.currentIndex, 0)
    }
}

// MARK: - Story 10.2: Loop Reset

final class PracticeEngineLoopResetTests: XCTestCase {
    
    var provider: MockDigitsProvider!
    var persistence: MockPracticePersistence!
    var engine: PracticeEngine!
    
    override func setUp() {
        super.setUp()
        provider = MockDigitsProvider()
        persistence = MockPracticePersistence()
        engine = PracticeEngine(constant: .pi, provider: provider, persistence: persistence)
    }
    
    func testResetLoop_ResetsIndexAndStreak_ButKeepsGlobalStats() {
        // Setup: Start session with start index 10
        engine.start(mode: .learning, startIndex: 10, endIndex: 20)
        
        // 1. Advance a bit (Index 10 -> 12)
        // 10: "1" (from mock digits: 1,4,1,5,9,2,6,5,3,5 -> Index 10 is 1 again)
        // Mock digits are 10 length. Index 10 is 1. Index 11 is 4.
        // Let's assume mock is circular.
        
        // Input correct (10)
        _ = engine.input(digit: 1) // Correct
        XCTAssertEqual(engine.currentIndex, 11)
        XCTAssertEqual(engine.currentStreak, 1)
        
        // Input incorrect (11) - to have some errors
        _ = engine.input(digit: 9) // Error
        XCTAssertEqual(engine.errors, 1)
        XCTAssertEqual(engine.currentStreak, 0)
        
        // Input correct (11)
        _ = engine.input(digit: 4) // Correct
        XCTAssertEqual(engine.currentIndex, 12)
        XCTAssertEqual(engine.currentStreak, 1)
        XCTAssertEqual(engine.attempts, 3)
        
        // 2. Perform Reset Loop
        engine.resetLoop()
        
        // 3. Verify
        XCTAssertEqual(engine.currentIndex, 10, "Current index should reset to startIndex (10)")
        XCTAssertEqual(engine.currentStreak, 0, "Streak should reset to 0")
        
        // Global stats preserved
        XCTAssertEqual(engine.errors, 1, "Errors should be preserved")
        XCTAssertEqual(engine.attempts, 3, "Attempts should be preserved")
        XCTAssertGreaterThan(engine.elapsedTime, 0.05, "Elapsed time should be preserved")
        XCTAssertTrue(engine.isActive, "Session should remain active")
    }
}

// MARK: - SessionViewModel Integration Tests (Story 10.2 Loop Reset)

fileprivate class ResetLoopMockPersistence: PracticePersistenceProtocol {
    var userDefaults: UserDefaults = .standard
    func saveHighestIndex(_ index: Int, for constantKey: String) {}
    func getHighestIndex(for constantKey: String) -> Int { return 0 }
    func saveStats(_ stats: [Constant: ConstantStats]) {}
    func loadStats() -> [Constant: ConstantStats]? { return nil }
    func saveKeypadLayout(_ layout: String) {}
    func loadKeypadLayout() -> String? { return nil }
    func saveSelectedConstant(_ constant: String) {}
    func loadSelectedConstant() -> String? { return nil }
    func saveSelectedMode(_ mode: String) {}
    func loadSelectedMode() -> String? { return nil }
    func saveSelectedGhostType(_ type: String) {}
    func loadSelectedGhostType() -> String? { return nil }
    func saveAutoAdvance(_ enabled: Bool) {}
    func loadAutoAdvance() -> Bool? { return nil }
}

@MainActor
final class SessionViewModelLoopResetTests: XCTestCase {
    
    var viewModel: SessionViewModel!
    var provider: MockDigitsProvider! // Reuse existing mock
    var persistence: ResetLoopMockPersistence!
    var segmentStore: SegmentStore!
    
    override func setUp() async throws {
        provider = MockDigitsProvider()
        persistence = ResetLoopMockPersistence()
        segmentStore = SegmentStore()
        
        // Initialize VM with dependencies
        viewModel = SessionViewModel(
            persistence: persistence,
            providerFactory: { _ in self.provider },
            segmentStore: segmentStore
        )
    }
    
    func testResetLoop_ResetsViewModelState() {
        // Setup: Learn Mode
        viewModel.selectedMode = .learn
        
        // Start Session
        viewModel.startSession()
        
        // 1. Simulate inputs and errors
        // "1" is correct (Mock digits: 1,4,1...)
        viewModel.processInput(1)
        XCTAssertEqual(viewModel.typedDigits, "1")
        
        // "9" is incorrect
        viewModel.processInput(9) // Error
        
        // "4" is correct (index 1)
        viewModel.processInput(4)
        XCTAssertEqual(viewModel.typedDigits, "14")
        
        // Verify state before reset
        XCTAssertFalse(viewModel.indulgentErrorIndices.isEmpty, "Should track errors")
        XCTAssertEqual(viewModel.engine.currentIndex, 2)
        
        // 2. Perform Reset
        viewModel.resetLoop()
        
        // 3. Verify VM State cleared
        XCTAssertEqual(viewModel.typedDigits, "", "Typed digits should be cleared")
        XCTAssertTrue(viewModel.indulgentErrorIndices.isEmpty, "Error indices should be cleared")
        XCTAssertFalse(viewModel.isShowingErrorReveal)
        XCTAssertNil(viewModel.lastWrongInput)
        
        // 4. Verify Engine Reset (via VM)
        XCTAssertEqual(viewModel.engine.currentIndex, 0)
    }
}
