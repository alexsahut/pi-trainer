import XCTest
@testable import PiTrainer

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
    
    // MARK: - Ghost Mode Tests
    
    func testOpacityBaselineIs20Percent() {
        // Initial state
        XCTAssertEqual(viewModel.opacity, 0.2, "Initial opacity should be 20%")
    }
    
    func testOpacityDropsTo5PercentWhenStreak20() {
        // When streak reaches 20
        viewModel.updateStreak(20)
        
        // Then target opacity should be 0.05
        XCTAssertEqual(viewModel.opacity, 0.05, "Opacity should drop to 5% at streak 20")
    }
    
    func testOpacityResetsWhenStreakFallsBelow20() {
        // Given streak is 20 (Ghost Mode active)
        viewModel.updateStreak(20)
        XCTAssertEqual(viewModel.opacity, 0.05)
        
        // When streak falls below 20 (e.g. error)
        viewModel.updateStreak(0)
        
        // Then opacity should return to 0.2
        XCTAssertEqual(viewModel.opacity, 0.2, "Opacity should return to 20% when streak < 20")
    }
    
    func testOpacityReturnsTo20PercentAfterInactivity() {
        // Given streak is 20 (Ghost Mode active)
        viewModel.updateStreak(20)
        // Use a short threshold for testing
        viewModel.inactivityThreshold = 0.2
        XCTAssertEqual(viewModel.opacity, 0.05)
        
        let expectation = XCTestExpectation(description: "Opacity returns to 20% after inactivity")
        
        // We trigger a digit press to start the timer
        viewModel.digitPressed(1)
        XCTAssertEqual(viewModel.opacity, 0.05)
        
        // Wait slightly more than threshold
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if self.viewModel.opacity == 0.2 {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testInactivityTimerResetsOnNewInput() {
        // Given streak is 20
        viewModel.updateStreak(20)
        // Use a short threshold for testing
        viewModel.inactivityThreshold = 0.5
        
        // When we press a digit
        viewModel.digitPressed(1)
        
        // And wait 0.3 seconds (less than 0.5s threshold)
        let expectation = XCTestExpectation(description: "Opacity stays at 5% after reset")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(self.viewModel.opacity, 0.05)
            // Press another digit to reset timer
            self.viewModel.digitPressed(2)
            
            // Wait another 0.3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                XCTAssertEqual(self.viewModel.opacity, 0.05, "Opacity should still be 5% because timer was reset")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Integration Simulation
    
    func testPracticeEngineIntegration() {
        // This test simulates the data flow: Engine -> SessionView -> ProPadView -> ViewModel
        
        // 1. Start at streak 0 (Opacity 0.2)
        XCTAssertEqual(viewModel.opacity, 0.2)
        
        // 2. Reach streak 20 (Opacity 0.05)
        viewModel.updateStreak(20)
        XCTAssertEqual(viewModel.opacity, 0.05)
        
        // 3. Simulate continuous typing (resets timer, keeps opacity 0.05)
        for i in 1...10 {
            viewModel.digitPressed(i % 10)
            XCTAssertEqual(viewModel.opacity, 0.05, "Opacity should stay at 5% during active typing at streak 20")
        }
        
        // 4. Simulate error (streak 20 -> 0)
        viewModel.updateStreak(0)
        XCTAssertEqual(viewModel.opacity, 0.2, "Opacity should return to 20% immediately on error reset")
    }
}
