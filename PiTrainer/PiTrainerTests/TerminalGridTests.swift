//
//  TerminalGridTests.swift
//  PiTrainerTests
//
//  Unit tests for TerminalGridView data models and logic.
//

import XCTest
@testable import PiTrainer

final class TerminalGridTests: XCTestCase {
    
    // MARK: - TerminalRow Tests
    
    func testTerminalRow_InitWithFullRow_IsComplete() {
        // Given 10 digits (a full row)
        let digits = [1, 4, 1, 5, 9, 2, 6, 5, 3, 5]
        
        // When creating a TerminalRow
        let row = TerminalRow(index: 0, digits: digits)
        
        // Then it should be marked complete
        XCTAssertTrue(row.isComplete)
        XCTAssertEqual(row.lineNumber, 10)
        XCTAssertEqual(row.id, 0)
        XCTAssertEqual(row.digits.count, 10)
    }
    
    func testTerminalRow_InitWithPartialRow_IsNotComplete() {
        // Given fewer than 10 digits
        let digits = [1, 4, 1, 5, 9]
        
        // When creating a TerminalRow
        let row = TerminalRow(index: 0, digits: digits)
        
        // Then it should not be complete
        XCTAssertFalse(row.isComplete)
        XCTAssertEqual(row.digits.count, 5)
    }
    
    func testTerminalRow_LineNumber_CalculatesCorrectly() {
        // Row indices map to line numbers: 0->10, 1->20, 2->30
        XCTAssertEqual(TerminalRow(index: 0, digits: Array(repeating: 0, count: 10)).lineNumber, 10)
        XCTAssertEqual(TerminalRow(index: 1, digits: Array(repeating: 0, count: 10)).lineNumber, 20)
        XCTAssertEqual(TerminalRow(index: 9, digits: Array(repeating: 0, count: 10)).lineNumber, 100)
    }
    
    func testTerminalRow_EmptyRow_IsNotComplete() {
        let row = TerminalRow(index: 0, digits: [])
        
        XCTAssertFalse(row.isComplete)
        XCTAssertEqual(row.digits.count, 0)
    }
    
    // MARK: - DigitState Tests
    
    func testDigitState_Equatable() {
        XCTAssertEqual(DigitState.normal, DigitState.normal)
        XCTAssertEqual(DigitState.active, DigitState.active)
        XCTAssertEqual(DigitState.error, DigitState.error)
        XCTAssertNotEqual(DigitState.normal, DigitState.active)
        XCTAssertNotEqual(DigitState.active, DigitState.error)
    }
    
    // MARK: - Row Generation Logic Tests
    
    func testRowGeneration_EmptyInput_NoRows() {
        // Given an empty typed digits string
        let typedDigits = ""
        let rows = generateRows(from: typedDigits)
        
        // Then no rows should be generated
        XCTAssertEqual(rows.count, 0)
    }
    
    func testRowGeneration_SingleDigit_OneIncompleteRow() {
        let typedDigits = "1"
        let rows = generateRows(from: typedDigits)
        
        XCTAssertEqual(rows.count, 1)
        XCTAssertFalse(rows[0].isComplete)
        XCTAssertEqual(rows[0].digits, [1])
    }
    
    func testRowGeneration_TenDigits_OneCompleteRow() {
        let typedDigits = "1415926535"
        let rows = generateRows(from: typedDigits)
        
        XCTAssertEqual(rows.count, 1)
        XCTAssertTrue(rows[0].isComplete)
        XCTAssertEqual(rows[0].lineNumber, 10)
    }
    
    func testRowGeneration_FifteenDigits_TwoRows() {
        let typedDigits = "141592653589793"
        let rows = generateRows(from: typedDigits)
        
        XCTAssertEqual(rows.count, 2)
        XCTAssertTrue(rows[0].isComplete)
        XCTAssertFalse(rows[1].isComplete)
        XCTAssertEqual(rows[1].digits.count, 5)
    }
    
    func testRowGeneration_TwentyDigits_TwoCompleteRows() {
        let typedDigits = "14159265358979323846"
        let rows = generateRows(from: typedDigits)
        
        XCTAssertEqual(rows.count, 2)
        XCTAssertTrue(rows[0].isComplete)
        XCTAssertTrue(rows[1].isComplete)
        XCTAssertEqual(rows[0].lineNumber, 10)
        XCTAssertEqual(rows[1].lineNumber, 20)
    }
    
    // MARK: - Helper (mirrors TerminalGridView logic)
    
    private func generateRows(from typedDigits: String) -> [TerminalRow] {
        let digits = typedDigits.compactMap { Int(String($0)) }
        var result: [TerminalRow] = []
        
        var index = 0
        while index < digits.count {
            let endIndex = min(index + 10, digits.count)
            let rowDigits = Array(digits[index..<endIndex])
            result.append(TerminalRow(index: result.count, digits: rowDigits))
            index += 10
        }
        
        return result
    }
}
