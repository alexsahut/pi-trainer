import XCTest
import SwiftUI
@testable import PiTrainer

@MainActor
final class AtmosphericFeedbackTests: XCTestCase {
    
    var viewModel: SessionViewModel!
    
    override func setUp() async throws {
        // Initialize ViewModel
        viewModel = SessionViewModel()
        
        // Setup Game Mode which has the Ghost
        viewModel.selectedMode = .game
        
        // Ensure we have a working provider that loads digits
        // The default init uses FileDigitsProvider which loads from bundle. 
        // In tests, bundle resources might be tricky if not set up correctly in test target, 
        // but Unit Tests usually host the app, so main bundle is available.
        // We trigger startSession to initialize the engines.
        viewModel.startSession()
    }
    
    override func tearDown() {
        viewModel = nil
    }
    
    // MARK: - Color Logic Tests
    // Advance = Cyan (#00F2FF)
    // Behind = Orange (#FF6B00)
    // Neutral = Clear/Black
    
    func testAtmosphericColor_WhenAhead_ReturnsCyan() {
        // Arrange
        // Simulate: Player typed 10 digits correctly. Errors = 0.
        // Ghost should be behind.
        
        // 1. Enter correct digits
        let digits = "3141592653" // 10 digits
        for char in digits {
             viewModel.processInput(Int(String(char))!)
        }
        
        // 2. We need Ghost to be slower. 
        // Ghost position is time-based.
        // If we check logic immediately (at "now"), ghost pos is 0 (or close to 0 if time hasn't advanced).
        // Player pos is 10. Delta = 10 > 0 -> Ahead.
        
        // Act
        // Use current date. Since we just started (and assumed 0 time passed for ghost effectively if we are fast), 
        // ghost is at 0.
        let color = viewModel.atmosphericColor(at: Date())
        
        // Assert
        XCTAssertEqual(color, DesignSystem.Colors.cyanElectric, "Should be Cyan when ahead")
    }
    
    func testAtmosphericColor_WhenBehind_ReturnsOrange() {
        // Arrange
        // Player is at 0.
        // Ghost needs to be at > 0.
        
        // Simulate time passing. 
        // We know ghost position logic depends on Date(). 
        // We can pass a date in the future to `atmosphericColor`.
        let futureDate = Date().addingTimeInterval(10) // 10 seconds later
        
        // Act
        let color = viewModel.atmosphericColor(at: futureDate)
        
        // Assert
        XCTAssertEqual(color, DesignSystem.Colors.orangeElectric, "Should be Orange when behind")
    }
    
    func testAtmosphericColor_WhenEqual_ReturnsClear() {
        // Arrange
        // Player 0, Ghost 0 (at immediate start)
        
        // Act
        let color = viewModel.atmosphericColor(at: Date())
        
        // Assert
        // In the implementation, 'clear' is used for neutral/equal
        XCTAssertEqual(color, .clear, "Should be Clear when equal")
    }
    
    func testAtmosphericColor_IgnoreInLearnMode() {
        // Arrange
        viewModel.selectedMode = .learn
        viewModel.startSession()
        
        // Even if we are ahead (conceptually), Learn mode checks might behave differently 
        // BUT the func atmosphericDelta checks for ghostEngine.
        // In Learn mode, ghostEngine is nil (usually).
        
        // Act
        let color = viewModel.atmosphericColor(at: Date())
        
        // Assert
        // If ghostEngine is nil, delta is 0 -> clear.
        XCTAssertEqual(color, .clear, "Should be Clear in Learn mode (no ghost)")
    }
    
    // MARK: - Opacity Logic Tests
    
    func testAtmosphericOpacity_WhenEqual_ReturnsZero() {
         let opacity = viewModel.atmosphericOpacity(at: Date())
         XCTAssertEqual(opacity, 0.0, accuracy: 0.001)
    }
    
    func testAtmosphericOpacity_WhenLowDiff_ReturnsMinOpacity() {
        // Player at 1, Ghost at 0
        viewModel.processInput(3) // "3" is first digit of Pi
        
        // Check immediately so ghost is approx 0
        let date = Date()
        let opacity = viewModel.atmosphericOpacity(at: date)
        
        // Delta = 1. Ratio = 1/5 = 0.2.
        // Opacity = 0.05 + (0.2 * 0.15) = 0.08
        XCTAssertEqual(opacity, 0.08, accuracy: 0.01)
    }
    
    func testAtmosphericOpacity_WhenSaturated_ReturnsMaxOpacity() {
        // Player at 10, Ghost at 0
        let digits = "3141592653"
        for char in digits {
            viewModel.processInput(Int(String(char))!)
        }
        
        let date = Date()
        let opacity = viewModel.atmosphericOpacity(at: date)
        
        // Delta = 10. Ratio = 10/5 = 2 -> Clamped to 1.
        // Opacity = 0.05 + (1.0 * 0.15) = 0.20
        XCTAssertEqual(opacity, 0.20, accuracy: 0.001)
    }
}
