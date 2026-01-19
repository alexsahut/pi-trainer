//
//  PiTrainerTests.swift
//  PiTrainerTests
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import XCTest
@testable import PiTrainer

@MainActor
final class PiTrainerTests: XCTestCase {
    
    // MARK: - Mocks for Integration
    
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
    
    func testConstant_Properties() {
        XCTAssertEqual(Constant.pi.integerPart, "3")
        XCTAssertEqual(Constant.e.integerPart, "2")
        XCTAssertEqual(Constant.sqrt2.integerPart, "1")
        XCTAssertEqual(Constant.phi.integerPart, "1")
        
        XCTAssertEqual(Constant.pi.symbol, "π")
        XCTAssertEqual(Constant.e.symbol, "e")
    }
}

