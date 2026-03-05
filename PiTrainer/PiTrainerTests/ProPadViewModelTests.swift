import XCTest
@testable import PiTrainer

@MainActor
final class ProPadViewModelTests: XCTestCase {
    
    var viewModel: ProPadViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = ProPadViewModel()
        // Ensure haptics are enabled for testing
        HapticService.shared.isEnabled = true
    }
    
    func testDigitPressTriggersCallback() {
        let expectation = XCTestExpectation(description: "Digit callback triggered")
        var receivedDigit: Int?
        
        viewModel.onDigit = { digit in
            receivedDigit = digit
            expectation.fulfill()
        }
        
        viewModel.digitPressed(5)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedDigit, 5)
    }
    
    func testActionPressTriggersCallback() {
        let expectation = XCTestExpectation(description: "Action callback triggered")
        var receivedAction: ProPadViewModel.KeypadAction?
        
        viewModel.onAction = { action in
            receivedAction = action
            expectation.fulfill()
        }
        
        viewModel.actionPressed(.backspace)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedAction, .backspace)
    }
    
    func testHapticsCanBeDisabled() {
        HapticService.shared.isEnabled = false
        XCTAssertFalse(HapticService.shared.isEnabled)
        
        // This is a state test, hard to verify haptic engine calls without mocking,
        // but we verify the property persistence at least.
        HapticService.shared.isEnabled = true
        XCTAssertTrue(HapticService.shared.isEnabled)
    }
    
}
