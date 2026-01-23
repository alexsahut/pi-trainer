
import XCTest
@testable import PiTrainer

class PracticeEngineIndulgentTests: XCTestCase {
    
    var engine: PracticeEngine!
    
    override func setUp() {
        super.setUp()
        // Use PI for testing
        engine = PracticeEngine(constant: .pi, provider: FileDigitsProvider.pi)
    }
    
    // MARK: - Strict Mode Tests
    
    func testStrictMode_IgnoresIndulgentMode() {
        // Given
        engine.start(mode: .strict)
        engine.isIndulgent = true
        
        // When
        let result = engine.input(digit: 9) // 3 is correct, 9 is wrong
        
        // Then
        XCTAssertFalse(result.isCorrect)
        XCTAssertTrue(engine.state == .finished, "Strict mode typically finishes session on error")
        XCTAssertFalse(result.indexAdvanced, "Strict mode should not advance on error even if indulgent")
    }
    
    // MARK: - Learn Mode Tests
    
    func testLearnMode_IndulgentOff_DoesNotAdvanceOnError() {
        // Given
        engine.start(mode: .learning)
        engine.isIndulgent = false
        let startIndex = engine.currentIndex
        
        // When
        let result = engine.input(digit: 9) // Wrong
        
        // Then
        XCTAssertFalse(result.isCorrect)
        XCTAssertEqual(engine.currentIndex, startIndex, "Standard Learn Mode should NOT advance on error")
        XCTAssertFalse(result.indexAdvanced)
        XCTAssertEqual(engine.errors, 1)
    }
    
    func testLearnMode_IndulgentOn_AdvancesOnError() {
        // Given
        engine.start(mode: .learning)
        engine.isIndulgent = true
        let startIndex = engine.currentIndex
        
        // When
        let result = engine.input(digit: 9) // Wrong
        
        // Then
        XCTAssertFalse(result.isCorrect)
        XCTAssertEqual(engine.currentIndex, startIndex + 1, "Indulgent Mode SHOULD advance on error")
        XCTAssertTrue(result.indexAdvanced)
        XCTAssertEqual(engine.errors, 1)
    }
    
    // MARK: - Game Mode Tests
    
    func testGameMode_IndulgentOn_AdvancesOnError() {
        // Given
        engine.start(mode: .game)
        engine.isIndulgent = true
        let startIndex = engine.currentIndex
        
        // When
        let result = engine.input(digit: 9) // Wrong
        
        // Then
        XCTAssertFalse(result.isCorrect)
        // Game mode standard behavior (Story 9.4) is valid: false, fatal: false, advance: false.
        // With Indulgent: valid: false, fatal: false, advance: TRUE.
        XCTAssertEqual(engine.currentIndex, startIndex + 1, "Indulgent Mode in Game SHOULD advance index")
        XCTAssertTrue(result.indexAdvanced)
        XCTAssertEqual(engine.errors, 1)
    }
}
