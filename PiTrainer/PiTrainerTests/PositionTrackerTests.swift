import XCTest
@testable import PiTrainer

/// Tests for Story 2.2: Suivi de Position "Position Tracker"
///
/// Acceptance Criteria:
/// - A discreet indicator displays the index of the next expected decimal
/// - The indicator increments instantly after each correct validation
final class PositionTrackerTests: XCTestCase {
    
    var provider: MockDigitsProvider!
    var persistence: MockPracticePersistence!
    var engine: PracticeEngine!
    
    override func setUp() {
        super.setUp()
        provider = MockDigitsProvider()
        persistence = MockPracticePersistence()
        engine = PracticeEngine(constant: .pi, provider: provider, persistence: persistence)
        try? engine.start(mode: .strict)
    }
    
    // MARK: - Position Display Tests
    
    func testPositionTracker_DisplaysCorrectInitialIndex() {
        // GIVEN: A new practice session started
        // WHEN: Checking the position
        
        // THEN: Position should show "1" (first decimal, 1-based for UX)
        // Engine internally uses 0-based index, UI displays as currentIndex + 1
        XCTAssertEqual(engine.currentIndex, 0, "Engine should start at index 0 (0-based)")
        
        // UI would display: engine.currentIndex + 1 = 0 + 1 = 1
        let displayedPosition = engine.currentIndex + 1
        XCTAssertEqual(displayedPosition, 1, "Displayed position should be 1 (1-based)")
    }
    
    func testPositionTracker_IncrementsOnCorrectDigit() {
        // GIVEN: Position at 1
        let initialIndex = engine.currentIndex
        
        // WHEN: Entering correct digit (expected: 1)
        _ = engine.input(digit: 1)
        
        // THEN: Position should increment to 2
        XCTAssertEqual(engine.currentIndex, initialIndex + 1, "Engine index should increment")
        
        // UI would display: engine.currentIndex + 1 = 1 + 1 = 2
        let displayedPosition = engine.currentIndex + 1
        XCTAssertEqual(displayedPosition, 2, "Displayed position should be 2")
    }
    
    func testPositionTracker_DoesNotIncrementOnIncorrectDigit_StrictMode() {
        // GIVEN: Position at 1 in strict mode
        try? engine.start(mode: .strict)
        
        // WHEN: Entering incorrect digit
        _ = engine.input(digit: 9)
        
        // THEN: Position should remain at 1 (session ends in strict mode)
        XCTAssertEqual(engine.currentIndex, 0, "Strict mode: index stays at 0 on error")
        XCTAssertFalse(engine.isActive, "Session should end in strict mode on error")
        
        // UI would still display: engine.currentIndex + 1 = 0 + 1 = 1
        let displayedPosition = engine.currentIndex + 1
        XCTAssertEqual(displayedPosition, 1, "Displayed position should remain 1")
    }
    
    func testPositionTracker_IncrementsOnIncorrectDigit_LearningMode() {
        // GIVEN: Position at 1 in learning mode
        try? engine.start(mode: .learning)
        
        // WHEN: Entering incorrect digit
        _ = engine.input(digit: 9)
        
        // THEN: Position should still increment (learning mode continues)
        XCTAssertEqual(engine.currentIndex, 1, "Learning mode: index advances even on error")
        XCTAssertTrue(engine.isActive, "Session should continue in learning mode on error")
        
        // UI would display: engine.currentIndex + 1 = 1 + 1 = 2
        let displayedPosition = engine.currentIndex + 1
        XCTAssertEqual(displayedPosition, 2, "Displayed position should be 2")
    }
    
    // MARK: - Sequence Tests
    
    func testPositionTracker_TracksMultipleDigits() {
        // GIVEN: A session in progress
        // Expected sequence: 1, 2, 3, 4, 5...
        
        // WHEN: Entering 5 correct digits
        _ = engine.input(digit: 1) // Index 0 -> 1
        _ = engine.input(digit: 2) // Index 1 -> 2
        _ = engine.input(digit: 3) // Index 2 -> 3
        _ = engine.input(digit: 4) // Index 3 -> 4
        _ = engine.input(digit: 5) // Index 4 -> 5
        
        // THEN: Position should be at 6 (next expected)
        XCTAssertEqual(engine.currentIndex, 5, "Engine should be at index 5 (0-based)")
        
        // UI would display: engine.currentIndex + 1 = 5 + 1 = 6
        let displayedPosition = engine.currentIndex + 1
        XCTAssertEqual(displayedPosition, 6, "Displayed position should be 6")
    }
    
    func testPositionTracker_ResetOnSessionRestart() {
        // GIVEN: A session with progress
        _ = engine.input(digit: 1)
        _ = engine.input(digit: 2)
        XCTAssertEqual(engine.currentIndex, 2, "Index should be at 2 after 2 correct inputs")
        
        // WHEN: Resetting and starting new session
        engine.reset()
        try? engine.start(mode: .strict)
        
        // THEN: Position should be back to 1
        XCTAssertEqual(engine.currentIndex, 0, "Engine should reset to index 0")
        
        // UI would display: engine.currentIndex + 1 = 0 + 1 = 1
        let displayedPosition = engine.currentIndex + 1
        XCTAssertEqual(displayedPosition, 1, "Displayed position should reset to 1")
    }
}
