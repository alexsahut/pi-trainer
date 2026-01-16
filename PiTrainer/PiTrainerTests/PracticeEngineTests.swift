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
}

final class MockDigitsProvider: DigitsProvider {
    var totalDigits: Int = 100
    var digits: [Int] = [1, 4, 1, 5, 9, 2, 6, 5, 3, 5] // First few digits of Pi
    
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
        engine = PracticeEngine(provider: provider, persistence: persistence)
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
        
        // Learning mode should continue
        XCTAssertTrue(engine.isActive)
        XCTAssertTrue(result.indexAdvanced)
        XCTAssertEqual(engine.currentIndex, 1)
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
    
    func testElapsedTime_IncreasesAfterStart() throws {
        try engine.start(mode: .strict)
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
        try? engine.start(mode: .strict)
        _ = engine.input(digit: 1)
        
        XCTAssertEqual(persistence.saveCallCount, 1)
        XCTAssertEqual(persistence.savedIndex, 0)
    }
    
    func testPersistence_NotSavedOnIncorrectInput() {
        try? engine.start(mode: .strict)
        _ = engine.input(digit: 9)
        
        XCTAssertEqual(persistence.saveCallCount, 0)
    }
}
