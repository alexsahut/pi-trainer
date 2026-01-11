//
//  PiTrainerTests.swift
//  PiTrainerTests
//
//  Created by Alexandre SAHUT on 10/01/2026.
//

import XCTest
@testable import PiTrainer

final class PiTrainerTests: XCTestCase {
    
    // MARK: - PiDigitsProvider Tests
    
    func testPiDigitsProvider_LoadsDigitsSuccessfully() throws {
        let provider = PiDigitsProvider()
        let digits = try provider.loadDigits()
        
        XCTAssertFalse(digits.isEmpty, "Pi digits should not be empty")
        XCTAssertEqual(provider.totalDigits, 10000, "Should have exactly 10,000 digits")
    }
    
    func testPiDigitsProvider_AllCharactersAreDigits() throws {
        // Redundant as loading now validates and stores as numeric UInt8
        let provider = PiDigitsProvider()
        let digits = try provider.loadDigits()
        
        XCTAssertTrue(digits.allSatisfy { $0 <= 9 }, "All elements should be numeric digits 0-9")
    }
    
    func testPiDigitsProvider_CorrectFirstTwentyDigits() {
        let provider = PiDigitsProvider()
        
        // First 20 digits of Pi after decimal: 14159265358979323846
        let expectedDigits = [1, 4, 1, 5, 9, 2, 6, 5, 3, 5, 8, 9, 7, 9, 3, 2, 3, 8, 4, 6]
        
        for (index, expected) in expectedDigits.enumerated() {
            let digit = provider.getDigit(at: index)
            XCTAssertEqual(digit, expected, "Digit at index \(index) should be \(expected)")
        }
    }
    
    func testPiDigitsProvider_GetDigitAtBoundaries() {
        let provider = PiDigitsProvider()
        
        // Test first digit (index 0)
        XCTAssertNotNil(provider.getDigit(at: 0), "Should return digit at index 0")
        XCTAssertEqual(provider.getDigit(at: 0), 1, "First digit should be 1")
        
        // Test last digit (index 9999)
        XCTAssertNotNil(provider.getDigit(at: 9999), "Should return digit at index 9999")
        
        // Test out of bounds
        XCTAssertNil(provider.getDigit(at: -1), "Should return nil for negative index")
        XCTAssertNil(provider.getDigit(at: 10000), "Should return nil for index >= totalDigits")
        XCTAssertNil(provider.getDigit(at: 100000), "Should return nil for large out-of-bounds index")
    }
    
    func testPiDigitsProvider_TotalDigitsCount() {
        let provider = PiDigitsProvider()
        XCTAssertEqual(provider.totalDigits, 10000, "Total digits should be exactly 10,000")
    }
    
    // MARK: - PracticeEngine Tests - Initial State
    
    func testPracticeEngine_InitialState() {
        var engine = PracticeEngine()
        
        XCTAssertEqual(engine.currentIndex, 0, "Initial index should be 0")
        XCTAssertEqual(engine.attempts, 0, "Initial attempts should be 0")
        XCTAssertEqual(engine.errors, 0, "Initial errors should be 0")
        XCTAssertEqual(engine.currentStreak, 0, "Initial current streak should be 0")
        XCTAssertEqual(engine.bestStreak, 0, "Initial best streak should be 0")
        XCTAssertFalse(engine.isActive, "Engine should not be active initially")
        XCTAssertNil(engine.startTime, "Start time should be nil initially")
        XCTAssertEqual(engine.elapsedTime, 0, "Elapsed time should be 0 initially")
        XCTAssertEqual(engine.digitsPerMinute, 0, "DPM should be 0 initially")
    }
    
    func testPracticeEngine_StartInitializesCorrectly() {
        var engine = PracticeEngine()
        
        engine.start(mode: .strict)
        
        XCTAssertTrue(engine.isActive, "Engine should be active after start")
        XCTAssertEqual(engine.currentIndex, 0, "Index should be 0 after start")
        XCTAssertEqual(engine.attempts, 0, "Attempts should be 0 after start")
        XCTAssertEqual(engine.errors, 0, "Errors should be 0 after start")
        XCTAssertEqual(engine.currentStreak, 0, "Current streak should be 0 after start")
        XCTAssertEqual(engine.bestStreak, 0, "Best streak should be 0 after start")
        XCTAssertNotNil(engine.startTime, "Start time should be set after start")
    }
    
    // MARK: - PracticeEngine Tests - Correct Input
    
    func testPracticeEngine_CorrectInput_AdvancesIndex() {
        var engine = PracticeEngine()
        engine.start(mode: .strict)
        
        // First digit of Pi is 1
        let result = engine.input(digit: 1)
        
        XCTAssertTrue(result.isCorrect, "Input should be correct")
        XCTAssertEqual(result.expectedDigit, 1, "Expected digit should be 1")
        XCTAssertTrue(result.indexAdvanced, "Index should advance on correct input")
        XCTAssertEqual(result.currentIndex, 1, "Current index should be 1")
        XCTAssertEqual(engine.currentIndex, 1, "Engine index should be 1")
        XCTAssertEqual(engine.attempts, 1, "Attempts should be 1")
        XCTAssertEqual(engine.errors, 0, "Errors should be 0")
        XCTAssertEqual(engine.currentStreak, 1, "Current streak should be 1")
        XCTAssertEqual(engine.bestStreak, 1, "Best streak should be 1")
    }
    
    func testPracticeEngine_MultipleCorrectInputs_UpdatesStreak() {
        var engine = PracticeEngine()
        engine.start(mode: .strict)
        
        // First 5 digits: 1, 4, 1, 5, 9
        let digits = [1, 4, 1, 5, 9]
        
        for (index, digit) in digits.enumerated() {
            let result = engine.input(digit: digit)
            XCTAssertTrue(result.isCorrect, "Digit \(digit) at position \(index) should be correct")
            XCTAssertTrue(result.indexAdvanced, "Index should advance")
            XCTAssertEqual(engine.currentStreak, index + 1, "Streak should be \(index + 1)")
            XCTAssertEqual(engine.bestStreak, index + 1, "Best streak should be \(index + 1)")
        }
        
        XCTAssertEqual(engine.currentIndex, 5, "Index should be 5 after 5 correct inputs")
        XCTAssertEqual(engine.attempts, 5, "Attempts should be 5")
        XCTAssertEqual(engine.errors, 0, "Errors should be 0")
    }
    
    // MARK: - PracticeEngine Tests - Strict Mode
    
    func testPracticeEngine_StrictMode_IncorrectInput_DoesNotAdvance() {
        var engine = PracticeEngine()
        engine.start(mode: .strict)
        
        // First digit is 1, input wrong digit
        let result = engine.input(digit: 9)
        
        XCTAssertFalse(result.isCorrect, "Input should be incorrect")
        XCTAssertEqual(result.expectedDigit, 1, "Expected digit should be 1")
        XCTAssertFalse(result.indexAdvanced, "Index should NOT advance in strict mode")
        XCTAssertEqual(result.currentIndex, 0, "Current index should still be 0")
        XCTAssertEqual(engine.currentIndex, 0, "Engine index should still be 0")
        XCTAssertEqual(engine.attempts, 1, "Attempts should be 1")
        XCTAssertEqual(engine.errors, 1, "Errors should be 1")
        XCTAssertEqual(engine.currentStreak, 0, "Current streak should be 0")
        XCTAssertTrue(engine.isActive, "Engine should still be active in strict mode after error")
    }
    
    func testPracticeEngine_StrictMode_RetryAfterError() {
        var engine = PracticeEngine()
        engine.start(mode: .strict)
        
        // First digit is 1
        // Try wrong digit
        let wrongResult = engine.input(digit: 9)
        XCTAssertFalse(wrongResult.isCorrect)
        XCTAssertEqual(engine.currentIndex, 0, "Index should not advance")
        
        // Try correct digit
        let correctResult = engine.input(digit: 1)
        XCTAssertTrue(correctResult.isCorrect)
        XCTAssertEqual(engine.currentIndex, 1, "Index should advance after correct retry")
        XCTAssertEqual(engine.attempts, 2, "Should have 2 attempts")
        XCTAssertEqual(engine.errors, 1, "Should have 1 error")
    }
    
    func testPracticeEngine_StrictMode_ErrorResetsCurrentStreak() {
        var engine = PracticeEngine()
        engine.start(mode: .strict)
        
        // Input 3 correct digits: 1, 4, 1
        engine.input(digit: 1)
        engine.input(digit: 4)
        engine.input(digit: 1)
        
        XCTAssertEqual(engine.currentStreak, 3, "Streak should be 3")
        XCTAssertEqual(engine.bestStreak, 3, "Best streak should be 3")
        
        // Input wrong digit (5th digit is 9, input 0)
        let result = engine.input(digit: 0)
        
        XCTAssertFalse(result.isCorrect)
        XCTAssertEqual(engine.currentStreak, 0, "Current streak should reset to 0")
        XCTAssertEqual(engine.bestStreak, 3, "Best streak should remain 3")
    }
    
    // MARK: - PracticeEngine Tests - Learning Mode
    
    func testPracticeEngine_LearningMode_IncorrectInput_AdvancesIndex() {
        var engine = PracticeEngine()
        engine.start(mode: .learning)
        
        // First digit is 1, input wrong digit
        let result = engine.input(digit: 9)
        
        XCTAssertFalse(result.isCorrect, "Input should be incorrect")
        XCTAssertEqual(result.expectedDigit, 1, "Expected digit should be 1")
        XCTAssertTrue(result.indexAdvanced, "Index SHOULD advance in learning mode")
        XCTAssertEqual(result.currentIndex, 1, "Current index should be 1")
        XCTAssertEqual(engine.currentIndex, 1, "Engine index should be 1")
        XCTAssertEqual(engine.attempts, 1, "Attempts should be 1")
        XCTAssertEqual(engine.errors, 1, "Errors should be 1")
        XCTAssertEqual(engine.currentStreak, 0, "Current streak should be 0")
        XCTAssertTrue(engine.isActive, "Engine should still be active")
    }
    
    func testPracticeEngine_LearningMode_ContinuesAfterError() {
        var engine = PracticeEngine()
        engine.start(mode: .learning)
        
        // Input wrong digit for first position
        let wrongResult = engine.input(digit: 9)
        XCTAssertFalse(wrongResult.isCorrect)
        XCTAssertEqual(wrongResult.expectedDigit, 1)
        XCTAssertEqual(engine.currentIndex, 1, "Should advance to index 1")
        
        // Continue with correct digit for second position (4)
        let correctResult = engine.input(digit: 4)
        XCTAssertTrue(correctResult.isCorrect)
        XCTAssertEqual(engine.currentIndex, 2, "Should advance to index 2")
        XCTAssertEqual(engine.currentStreak, 1, "Streak should be 1 after correct input")
    }
    
    // MARK: - PracticeEngine Tests - Streak Tracking
    
    func testPracticeEngine_BestStreakPreserved() {
        var engine = PracticeEngine()
        engine.start(mode: .strict)
        
        // Get 5 correct: 1,4,1,5,9
        for digit in [1, 4, 1, 5, 9] {
            engine.input(digit: digit)
        }
        XCTAssertEqual(engine.bestStreak, 5)
        
        // Make error
        engine.input(digit: 0) // wrong
        XCTAssertEqual(engine.currentStreak, 0)
        XCTAssertEqual(engine.bestStreak, 5, "Best streak should be preserved")
        
        // Get 3 more correct
        engine.input(digit: 2) // correct retry for index 5
        engine.input(digit: 6) // index 6
        engine.input(digit: 5) // index 7
        
        XCTAssertEqual(engine.currentStreak, 3)
        XCTAssertEqual(engine.bestStreak, 5, "Best streak should still be 5")
    }
    
    // MARK: - PracticeEngine Tests - Backspace
    
    func testPracticeEngine_Backspace_DecreasesIndex() {
        var engine = PracticeEngine()
        engine.start(mode: .strict)
        
        // Input 3 correct digits
        engine.input(digit: 1)
        engine.input(digit: 4)
        engine.input(digit: 1)
        XCTAssertEqual(engine.currentIndex, 3)
        
        // Backspace
        engine.backspace()
        XCTAssertEqual(engine.currentIndex, 2, "Index should decrease by 1")
    }
    
    func testPracticeEngine_Backspace_AtIndexZero_DoesNothing() {
        var engine = PracticeEngine()
        engine.start(mode: .strict)
        
        XCTAssertEqual(engine.currentIndex, 0)
        
        engine.backspace()
        XCTAssertEqual(engine.currentIndex, 0, "Index should remain 0")
    }
    
    // MARK: - PracticeEngine Tests - Reset
    
    func testPracticeEngine_Reset_ClearsAllState() {
        var engine = PracticeEngine()
        engine.start(mode: .strict)
        
        // Do some practice
        engine.input(digit: 1)
        engine.input(digit: 4)
        engine.input(digit: 0) // error
        
        XCTAssertGreaterThan(engine.attempts, 0)
        XCTAssertGreaterThan(engine.errors, 0)
        
        // Reset
        engine.reset()
        
        XCTAssertEqual(engine.currentIndex, 0)
        XCTAssertEqual(engine.attempts, 0)
        XCTAssertEqual(engine.errors, 0)
        XCTAssertEqual(engine.currentStreak, 0)
        XCTAssertEqual(engine.bestStreak, 0)
        XCTAssertFalse(engine.isActive)
        XCTAssertNil(engine.startTime)
        XCTAssertEqual(engine.elapsedTime, 0)
    }
    
    // MARK: - PracticeEngine Tests - Statistics
    
    func testPracticeEngine_Statistics_AttemptsAndErrors() {
        var engine = PracticeEngine()
        engine.start(mode: .strict)
        
        // 3 correct + 2 errors + retry 2 correct
        engine.input(digit: 1) // correct
        engine.input(digit: 4) // correct
        engine.input(digit: 1) // correct
        engine.input(digit: 0) // error (expected 5)
        engine.input(digit: 5) // correct retry
        engine.input(digit: 0) // error (expected 9)
        engine.input(digit: 9) // correct retry
        
        XCTAssertEqual(engine.attempts, 7, "Should have 7 total attempts")
        XCTAssertEqual(engine.errors, 2, "Should have 2 errors")
    }
    
    func testPracticeEngine_ElapsedTime_Increases() {
        var engine = PracticeEngine()
        engine.start(mode: .strict)
        
        let time1 = engine.elapsedTime
        
        // Wait a bit
        Thread.sleep(forTimeInterval: 0.1)
        
        let time2 = engine.elapsedTime
        
        XCTAssertGreaterThan(time2, time1, "Elapsed time should increase")
    }
    
    func testPracticeEngine_DigitsPerMinute_Calculation() {
        var engine = PracticeEngine()
        engine.start(mode: .strict)
        
        // Input correct digits
        for digit in [1, 4, 1, 5, 9] {
            engine.input(digit: digit)
        }
        
        // Wait a bit to ensure elapsed time > 0
        Thread.sleep(forTimeInterval: 0.1)
        
        let dpm = engine.digitsPerMinute
        XCTAssertGreaterThan(dpm, 0, "DPM should be greater than 0")
        
        // With 5 correct digits and ~0.1 seconds, DPM should be very high
        // 5 correct / (0.1/60) minutes = ~3000 DPM
        XCTAssertGreaterThan(dpm, 100, "DPM should be reasonably high")
    }
    
    func testPracticeEngine_DigitsPerMinute_WithErrors() {
        var engine = PracticeEngine()
        engine.start(mode: .strict)
        
        // 3 correct, 1 error = 3 correct digits, 4 attempts
        engine.input(digit: 1) // correct
        engine.input(digit: 4) // correct
        engine.input(digit: 1) // correct
        engine.input(digit: 0) // error
        
        Thread.sleep(forTimeInterval: 0.1)
        
        let dpm = engine.digitsPerMinute
        let correctDigits = engine.attempts - engine.errors
        
        XCTAssertEqual(correctDigits, 3, "Should have 3 correct digits")
        XCTAssertGreaterThan(dpm, 0, "DPM should be greater than 0")
    }
    
    // MARK: - PracticeEngine Tests - Edge Cases
    
    func testPracticeEngine_InputWhenNotActive_ReturnsCurrentState() {
        var engine = PracticeEngine()
        
        // Don't start, just input
        let result = engine.input(digit: 1)
        
        XCTAssertFalse(result.isCorrect, "Should not be correct when not active")
        XCTAssertEqual(result.currentIndex, 0)
        XCTAssertEqual(engine.attempts, 0, "Attempts should not increase when not active")
    }
    
    func testPracticeEngine_MultipleStartCalls_ResetsState() {
        var engine = PracticeEngine()
        engine.start(mode: .strict)
        
        // Do some practice
        engine.input(digit: 1)
        engine.input(digit: 4)
        
        XCTAssertEqual(engine.currentIndex, 2)
        XCTAssertEqual(engine.attempts, 2)
        
        // Start again
        engine.start(mode: .learning)
        
        XCTAssertEqual(engine.currentIndex, 0, "Should reset to 0")
        XCTAssertEqual(engine.attempts, 0, "Should reset attempts")
        XCTAssertEqual(engine.errors, 0, "Should reset errors")
    }
}
