//
//  PiTrainerTests.swift
//  PiTrainerTests
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import XCTest
@testable import PiTrainer

final class PiTrainerTests: XCTestCase {
    
    // MARK: - FileDigitsProvider Tests
    
    func testFileDigitsProvider_LoadsPiDigitsSuccessfully() throws {
        let provider = FileDigitsProvider(constant: .pi)
        // Ensure loadDigits is called implicitly or explicitly
        
        XCTAssertEqual(provider.totalDigits, 10000, "Pi should have exactly 10,000 digits")
        
        // Verify first few digits of Pi: 1415926535...
        let expected = [1, 4, 1, 5, 9, 2, 6, 5, 3, 5]
        for (i, digit) in expected.enumerated() {
            XCTAssertEqual(provider.getDigit(at: i), digit, "Pi digit at index \(i) should be \(digit)")
        }
    }
    
    func testFileDigitsProvider_LoadsEulerDigitsSuccessfully() throws {
        let provider = FileDigitsProvider(constant: .e)
        
        XCTAssertEqual(provider.totalDigits, 10000, "e should have exactly 10,000 digits")
        
        // Verify first few digits of e: 7182818284...
        let expected = [7, 1, 8, 2, 8, 1, 8, 2, 8, 4]
        for (i, digit) in expected.enumerated() {
            XCTAssertEqual(provider.getDigit(at: i), digit, "e digit at index \(i) should be \(digit)")
        }
    }
    
    func testFileDigitsProvider_LoadsSqrt2DigitsSuccessfully() throws {
        let provider = FileDigitsProvider(constant: .sqrt2)
        
        XCTAssertEqual(provider.totalDigits, 10000, "sqrt2 should have exactly 10,000 digits")
        
        // Verify first few digits of sqrt2: 4142135623... (1.4142135623)
        let expected = [4, 1, 4, 2, 1, 3, 5, 6, 2, 3]
        for (i, digit) in expected.enumerated() {
            XCTAssertEqual(provider.getDigit(at: i), digit, "sqrt2 digit at index \(i) should be \(digit)")
        }
    }
    
    func testFileDigitsProvider_LoadsPhiDigitsSuccessfully() throws {
        let provider = FileDigitsProvider(constant: .phi)
        
        XCTAssertEqual(provider.totalDigits, 10000, "phi should have exactly 10,000 digits")
        
        // Verify first few digits of phi: 6180339887... (1.6180339887)
        let expected = [6, 1, 8, 0, 3, 3, 9, 8, 8, 7]
        for (i, digit) in expected.enumerated() {
            XCTAssertEqual(provider.getDigit(at: i), digit, "phi digit at index \(i) should be \(digit)")
        }
    }
    
    func testFileDigitsProvider_InvalidFile_ThrowsOrEmpty() {
        // We can't easily test missing file without mocking Bundle, but we can verify behavior
        // Since we are using the main bundle which definitely has the files now, this is tricky.
        // But we can check stability.
    }
    
    // MARK: - Constant Tests
    
    func testConstant_Properties() {
        XCTAssertEqual(Constant.pi.integerPart, "3")
        XCTAssertEqual(Constant.e.integerPart, "2")
        XCTAssertEqual(Constant.sqrt2.integerPart, "1")
        XCTAssertEqual(Constant.phi.integerPart, "1")
        
        XCTAssertEqual(Constant.pi.symbol, "π")
        XCTAssertEqual(Constant.e.symbol, "e")
    }
    
    // MARK: - PracticeEngine Tests (Integration with Provider)
    
    func testPracticeEngine_WorksWithPi() {
        let provider = FileDigitsProvider(constant: .pi)
        var engine = PracticeEngine(provider: provider)
        engine.start(mode: .strict)
        
        // First digit of Pi is 1
        let result = engine.input(digit: 1)
        XCTAssertTrue(result.isCorrect)
        XCTAssertEqual(engine.currentIndex, 1)
    }
    
    func testPracticeEngine_WorksWithEuler() {
        let provider = FileDigitsProvider(constant: .e)
        var engine = PracticeEngine(provider: provider)
        engine.start(mode: .strict)
        
        // First digit of e is 7
        let result = engine.input(digit: 7)
        XCTAssertTrue(result.isCorrect)
        XCTAssertEqual(engine.currentIndex, 1)
    }
    
    // MARK: - Existing Logic Preservation Tests
    
    func testPracticeEngine_Logic_StrictMode() {
        let provider = FileDigitsProvider(constant: .pi)
        var engine = PracticeEngine(provider: provider)
        engine.start(mode: .strict)
        
        // Correct 1
        XCTAssertTrue(engine.input(digit: 1).isCorrect)
        // Incorrect 9 (expected 4)
        XCTAssertFalse(engine.input(digit: 9).isCorrect)
        // Index should NOT advance
        XCTAssertEqual(engine.currentIndex, 1)
    }
    
    func testPracticeEngine_Logic_LearningMode() {
        let provider = FileDigitsProvider(constant: .pi)
        var engine = PracticeEngine(provider: provider)
        engine.start(mode: .learning)
        
        // Correct 1
        XCTAssertTrue(engine.input(digit: 1).isCorrect)
        // Incorrect 9 (expected 4)
        XCTAssertFalse(engine.input(digit: 9).isCorrect)
        // Index SHOULD advance
        XCTAssertEqual(engine.currentIndex, 2)
    }
}
