import XCTest
@testable import PiTrainer

// Redeclare mocks for full isolation in HorizonLineTests
class HorizonMockDigitsProvider: DigitsProvider {
    var totalDigits: Int = 10
    var allDigitsString: String = "1415926535"
    private var digits = [1, 4, 1, 5, 9, 2, 6, 5, 3, 5]
    
    func getDigit(at index: Int) -> Int? {
        guard index < digits.count else { return nil }
        return digits[index]
    }
    func loadDigits() throws {}
}

class HorizonMockPersistence: PracticePersistenceProtocol {
    var userDefaults: UserDefaults { .standard }
    func saveHighestIndex(_ index: Int, for constantKey: String) {}
    func getHighestIndex(for constantKey: String) -> Int { 0 }
    func saveStats(_ stats: [Constant : ConstantStats]) {}
    func loadStats() -> [Constant : ConstantStats]? { nil }
    func saveKeypadLayout(_ layout: String) {}
    func loadKeypadLayout() -> String? { nil }
    func saveSelectedConstant(_ constant: String) {}
    func loadSelectedConstant() -> String? { nil }
    func saveSelectedMode(_ mode: String) {}
    func loadSelectedMode() -> String? { nil }
}

@MainActor
final class HorizonLineTests: XCTestCase {
    
    var viewModel: SessionViewModel!
    var mockPersistence: HorizonMockPersistence!
    var mockPB: PersonalBestRecord!
    
    override func setUp() {
        super.setUp()
        mockPersistence = HorizonMockPersistence()
        
        // Mock PB for Ghost: 5 digits, 1 sec each
        mockPB = PersonalBestRecord(
            constant: .pi,
            digitCount: 5,
            totalTime: 5.0,
            cumulativeTimes: [1.0, 2.0, 3.0, 4.0, 5.0]
        )
        
        viewModel = SessionViewModel(
            persistence: mockPersistence,
            providerFactory: { _ in HorizonMockDigitsProvider() },
            personalBestProvider: { _ in self.mockPB }
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockPersistence = nil
        mockPB = nil
        super.tearDown()
    }
    
    func testPlayerEffectivePosition() {
        // Given: Session started in Strict mode (Game)
        viewModel.selectedMode = .test
        viewModel.startSession()
        
        // When: 3 correct inputs (Pi: 1, 4, 1)
        viewModel.processInput(1)
        viewModel.processInput(4)
        viewModel.processInput(1)
        
        // Then: Position should be 3
        print("DEBUG: Pre-error - Index: \(viewModel.engine.currentIndex), Errors: \(viewModel.engine.errors)")
        XCTAssertEqual(viewModel.playerEffectivePosition, 3)
        
        // When: 1 error (in Strict mode, session ends)
        viewModel.processInput(9) // Wrong
        
        print("DEBUG: Post-error - Index: \(viewModel.engine.currentIndex), Errors: \(viewModel.engine.errors), State: \(viewModel.engine.state)")
        
        // Then: Position should be 3 (currentIndex) - 1 (errors) = 2
        XCTAssertEqual(viewModel.playerEffectivePosition, 2)
    }
    
    func testProgressRatios() {
        // Given: Started with 5-digit PB
        viewModel.selectedMode = .test
        viewModel.startSession()
        
        // Total digits for mapping should be 5 (from Ghost PB)
        XCTAssertEqual(viewModel.totalDigitsForMapping, 5)
        
        // When: No progress
        XCTAssertEqual(viewModel.playerProgressRatio, 0.0)
        
        // When: 1 correct digit (1/5 = 0.2)
        viewModel.processInput(1)
        XCTAssertEqual(viewModel.playerProgressRatio, 0.2)
        
        // When: 5 correct digits (5/5 = 1.0)
        viewModel.processInput(4)
        viewModel.processInput(1)
        viewModel.processInput(5)
        viewModel.processInput(9)
        XCTAssertEqual(viewModel.playerProgressRatio, 1.0)
        
        // When: Ghost at start (0.0)
        XCTAssertEqual(viewModel.ghostProgressRatio, 0.0)
    }
}
