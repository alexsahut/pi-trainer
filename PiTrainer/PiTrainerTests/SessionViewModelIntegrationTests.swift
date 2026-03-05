import XCTest
@testable import PiTrainer

@MainActor
class SessionViewModelIntegrationTests: XCTestCase {
    
    var viewModel: SessionViewModel!
    var mockPersistence: SVM_MockPersistence!
    var mockSegmentStore: SegmentStore!

    override func setUp() async throws {
        mockPersistence = SVM_MockPersistence()
        mockSegmentStore = SegmentStore()
        
        // Reset singleton for isolation (if feasible, otherwise we rely on injection)
        await PersonalBestStore.shared.reset() 
        
        // Setup ViewModel with dependency injection
        viewModel = SessionViewModel(
            persistence: mockPersistence,
            providerFactory: { _ in SVM_MockDigitsProvider() },
            segmentStore: mockSegmentStore,
            personalBestProvider: { constant, type in
                return PersonalBestStore.shared.getRecord(for: constant, type: .crown)
            }
        )
    }

    // MARK: - Certification Logic Tests
    
    func testCertificationWithOneError_GameMode_IsCertified() async {
        // Given: Game mode allows certification with errors (Story 9.6: firstErrorSnapshot logic)
        viewModel.selectedMode = .game
        viewModel.startSession()

        // When: User inputs 1 correct, then 1 wrong
        viewModel.processInput(1) // Correct (Index 0: 1)
        viewModel.processInput(3) // Wrong (Index 1: Expected 4, got 3)
        // Game mode: VICTORY STOP triggers (currentIndex > ghostTotal of 0)

        // Then: Session ends and IS certified (game mode tolerates errors)
        await viewModel.endSession(shouldDismiss: false)

        let status = viewModel.sessionEndStatus
        // Game mode with 1 error, no ghost, no prior Crown PR:
        // VICTORY STOP triggers (currentIndex > ghostTotal of 0)
        // endSession evaluates Crown PR via firstErrorSnapshot → new record
        XCTAssertEqual(status.title, "NEW RECORD!", "Game mode: 1 error with no prior PR should yield NEW RECORD! via firstErrorSnapshot. Got: \(status.title)")
    }
    
    func testCertificationSucceedsWithZeroErrors_GameMode() async {
        // Given
        viewModel.selectedMode = .game
        viewModel.startSession()
        
        // When: Perfect run (3 digits)
        viewModel.processInput(1) // 1
        viewModel.processInput(4) // 4
        viewModel.processInput(1) // 1
        
        // Then
        await viewModel.endSession()
        
        // Check Status (assuming it beat previous null record)
        let status = viewModel.sessionEndStatus
        XCTAssertTrue(
            status.title == "NEW RECORD!" || status.title == "CERTIFIED",
            "Perfect session should be certified. Got: \(status.title)"
        )
    }
    
    // MARK: - Ghost Selection Tests
    
    func testGhostSelectionPrioritizesCrown() async {
        // Given: Both Crown and Lightning records exist
        let times = Array(repeating: 0.1, count: 100)
        let crownRecord = PersonalBestRecord(constant: .pi, type: .crown, digitCount: 100, totalTime: 100, cumulativeTimes: times, date: Date())
        let lightningRecord = PersonalBestRecord(constant: .pi, type: .lightning, digitCount: 50, totalTime: 20, cumulativeTimes: times, date: Date())
        
        await PersonalBestStore.shared.save(record: crownRecord)
        await PersonalBestStore.shared.save(record: lightningRecord)
        
        // Re-init VM to trigger ghost selection logic
        viewModel = SessionViewModel(
            persistence: mockPersistence,
            providerFactory: { _ in SVM_MockDigitsProvider() },
            segmentStore: mockSegmentStore,
            personalBestProvider: nil
        )
        
        viewModel.selectedMode = .game
        viewModel.startSession()
        
        // Then
        XCTAssertNotNil(viewModel.ghostEngine)
        // Current Default implementation: Fetches CROWN.
        // So with Crown present, this should PASS.
        XCTAssertEqual(viewModel.ghostEngine?.totalDigits, 100, "Should select Crown (100 digits)")
    }
    
    func testGhostSelectionFallbacksToLightning() async {
        // Given: Only Lightning record exists
        let times = Array(repeating: 0.1, count: 50)
        let lightningRecord = PersonalBestRecord(constant: .pi, type: .lightning, digitCount: 50, totalTime: 20, cumulativeTimes: times, date: Date())
        
        await PersonalBestStore.shared.reset()
        await PersonalBestStore.shared.save(record: lightningRecord)
        
        // Re-init VM with DEFAULT provider logic
        viewModel = SessionViewModel(
            persistence: mockPersistence,
            providerFactory: { _ in SVM_MockDigitsProvider() },
            segmentStore: mockSegmentStore
            // personalBestProvider defaults to nil -> triggers default internal logic
        )
        
        viewModel.selectedMode = .game
        viewModel.startSession()
        
        // Then: Default provider has Crown → Lightning fallback
        XCTAssertNotNil(viewModel.ghostEngine, "Ghost Engine should use Lightning fallback when Crown is missing")
        XCTAssertEqual(viewModel.ghostEngine?.totalDigits, 50, "Should select Lightning when Crown is missing")
    }
}

// MARK: - Mocks

@MainActor
class SVM_MockPersistence: PracticePersistenceProtocol {
    var userDefaults: UserDefaults = .standard // Dummy
    
    func loadStats() -> [Constant : ConstantStats]? { return [:] }
    func saveStats(_ stats: [Constant : ConstantStats]) {}
    func saveKeypadLayout(_ layout: String) {}
    func loadKeypadLayout() -> String? { return nil }
    func saveSelectedConstant(_ constant: String) {}
    func loadSelectedConstant() -> String? { return nil }
    func saveSelectedMode(_ mode: String) {}
    func loadSelectedMode() -> String? { return nil }
    func saveHighestIndex(_ index: Int, for constantKey: String) {}
    func getHighestIndex(for constantKey: String) -> Int { return 0 }
    
    func saveSelectedGhostType(_ type: String) {}
    func loadSelectedGhostType() -> String? { return nil }
    func saveAutoAdvance(_ enabled: Bool) {}
    func loadAutoAdvance() -> Bool? { return nil }
    
    func saveLastChallengeDate(_ date: Date) {}
    func loadLastChallengeDate() -> Date? { return nil }
    
    func saveTotalCorrectDigits(_ count: Int) {}
    func loadTotalCorrectDigits() -> Int { 0 }
}

class SVM_MockDigitsProvider: DigitsProvider {
    var totalDigits: Int = 1000
    var allDigitsString: String = "14159265358979323846264338327950288419716939937510"
    
    func getDigit(at index: Int) -> Int? {
        if index < totalDigits {
            let piDigits = allDigitsString
            let charIndex = piDigits.index(piDigits.startIndex, offsetBy: index % piDigits.count)
            return Int(String(piDigits[charIndex]))
        }
        return nil
    }
    
    func loadDigits() throws {}
}
