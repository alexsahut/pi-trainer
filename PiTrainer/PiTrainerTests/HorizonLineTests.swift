import XCTest
@testable import PiTrainer

// Redeclare mocks for full isolation in HorizonLineTests
class HorizonMockDigitsProvider: DigitsProvider {
    var totalDigits: Int = 10
    var allDigitsString: String = "1415926535"
    private var digits = [1, 4, 1, 5, 9, 2, 6, 5, 3, 5]
    
    deinit {
        print("DEBUG: HorizonMockDigitsProvider deinit completed")
    }
    
    func getDigit(at index: Int) -> Int? {
        guard index < digits.count else { return nil }
        return digits[index]
    }
    func loadDigits() throws {}
}

class HorizonMockPersistence: PracticePersistenceProtocol {
    var userDefaults: UserDefaults { .standard }
    
    deinit {
        print("DEBUG: HorizonMockPersistence deinit completed")
    }
    
    func saveHighestIndex(_ index: Int, for constantKey: String) {}
    func getHighestIndex(for constantKey: String) -> Int { 0 }
    func saveStats(_ stats: [Constant : ConstantStats]) {}
    func loadStats() -> [Constant : ConstantStats]? { nil }
    func saveKeypadLayout(_ layout: String) {}
    func loadKeypadLayout() -> String? { nil }
    func saveSelectedConstant(_ constant: String) {}
    func loadSelectedConstant() -> String? { nil }
    func saveSelectedMode(_ mode: String) {}
    func loadSelectedMode() -> String? { return nil }
    
    func saveSelectedGhostType(_ type: String) {}
    func loadSelectedGhostType() -> String? { return nil }
    func saveAutoAdvance(_ enabled: Bool) {}
    func loadAutoAdvance() -> Bool? { return nil }
    
    func saveLastChallengeDate(_ date: Date) {}
    func loadLastChallengeDate() -> Date? { return nil }
    
    func saveTotalCorrectDigits(_ count: Int) {}
    func loadTotalCorrectDigits() -> Int { 0 }
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
            personalBestProvider: { [mockPB] _, _ in mockPB }
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockPersistence = nil
        mockPB = nil
        super.tearDown()
    }
    
    func testPlayerEffectivePosition() {
        // Given: Session started in Test mode (Strict)
        viewModel.selectedMode = .test
        viewModel.startSession()
        
        // When: 3 correct inputs (Pi: 1, 4, 1)
        viewModel.processInput(1)
        viewModel.processInput(4)
        viewModel.processInput(1)
        
        // Then: playerEffectivePosition = 3.0 (3 correct, 0 errors)
        XCTAssertEqual(viewModel.playerEffectivePosition, 3.0)
        
        // When: 1 error (in Test/Strict mode, session ends)
        viewModel.processInput(9) // Wrong (expected 5)
        
        // Then: Position should be 3.0 (currentIndex stays at 3) - 1.0 (error) = 2.0
        XCTAssertEqual(viewModel.playerEffectivePosition, 2.0)
    }
    
    func testProgressRatios() {
        // Given: Started with 5-digit PB in Test mode
        viewModel.selectedMode = .test
        viewModel.startSession()
        
        // Total digits for mapping: no ghost in test mode, uses fallback 100
        XCTAssertEqual(viewModel.totalDigitsForMapping, 100)
        
        // When: No progress
        XCTAssertEqual(viewModel.playerProgressRatio, 0.0)
        
        // When: 1 correct digit (1/100 = 0.01)
        viewModel.processInput(1)
        XCTAssertEqual(viewModel.playerProgressRatio, 0.01)
        
        // When: 5 correct digits (5/100 = 0.05)
        viewModel.processInput(4)
        viewModel.processInput(1)
        viewModel.processInput(5)
        viewModel.processInput(9)
        XCTAssertEqual(viewModel.playerProgressRatio, 0.05)
    }
}
