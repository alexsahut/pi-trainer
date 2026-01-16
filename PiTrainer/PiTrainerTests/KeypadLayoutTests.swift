
import XCTest
@testable import PiTrainer

final class KeypadLayoutTests: XCTestCase {
    
    func testPhoneLayout_DigitsOrder() {
        // Given
        let layout = KeypadLayout.phone
        
        // When
        let digits = layout.digits
        
        // Then
        // Phone: 1-2-3 on top
        XCTAssertEqual(digits, [1, 2, 3, 4, 5, 6, 7, 8, 9])
    }
    
    func testPCLayout_DigitsOrder() {
        // Given
        let layout = KeypadLayout.pc
        
        // When
        let digits = layout.digits
        
        // Then
        // PC: 7-8-9 on top
        XCTAssertEqual(digits, [7, 8, 9, 4, 5, 6, 1, 2, 3])
    }
    
    func testLocalizedNames() {
        // Basic check to ensure localization keys don't crash
        XCTAssertFalse(KeypadLayout.phone.localizedName.isEmpty)
        XCTAssertFalse(KeypadLayout.pc.localizedName.isEmpty)
    }
}
