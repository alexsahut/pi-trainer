//
//  KeypadLayoutTests.swift
//  PiTrainerTests
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import XCTest
@testable import PiTrainer

final class KeypadLayoutTests: XCTestCase {

    func testPhoneLayoutDigits() {
        let layout = KeypadLayout.phone
        let expectedDigits = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        XCTAssertEqual(layout.digits, expectedDigits)
    }

    func testPCLayoutDigits() {
        let layout = KeypadLayout.pc
        let expectedDigits = [7, 8, 9, 4, 5, 6, 1, 2, 3]
        XCTAssertEqual(layout.digits, expectedDigits)
    }
}
