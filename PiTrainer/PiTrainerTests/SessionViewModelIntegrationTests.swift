import XCTest
@testable import PiTrainer

@MainActor
class SessionViewModelIntegrationTests: XCTestCase {
    
    var viewModel: SessionViewModel!
    var mockPersistence: SVM_MockPersistence!
    var mockPersonalBestStore: MockPersonalBestStore!
    var mockSegmentStore: SegmentStore!

    override func setUp() async throws {
        mockPersistence = SVM_MockPersistence()
        mockPersonalBestStore = MockPersonalBestStore() // We need to mock the singleton or inject a provider
        mockSegmentStore = SegmentStore()
        
        // Reset singleton for isolation (if feasible, otherwise we rely on injection)
        await PersonalBestStore.shared.reset() 
        
        // Setup ViewModel with dependency injection
        viewModel = SessionViewModel(
            persistence: mockPersistence,
            providerFactory: { _ in SVM_MockDigitsProvider() },
            segmentStore: mockSegmentStore,
            personalBestProvider: { constant in
                return PersonalBestStore.shared.getRecord(for: constant, type: .crown)
            }
        )
    }

    // MARK: - Certification Logic Tests
    
    func testCertificationFailsWithOneError_GameMode() async {
        // Given
        viewModel.selectedMode = .game
        viewModel.startSession()
        
        // Mock Provider Digits: 1, 4, 1, 5, 9...
        // When: User inputs 1 correct, then 1 wrong
        viewModel.processInput(1) // Correct (Index 0: 1)
        viewModel.processInput(3) // Wrong (Index 1: Expected 4, got 3)
        // Errors: 1
        
        // Then: Finish session
        viewModel.endSession(shouldDismiss: false)
        
        // Expectation: Not certified because errors > 0 (Strict Requirement)
        // With current legacy code (errors <= 1), this SHOULD be certified.
        // So we expect the Status to be "NEW RECORD" (Certified) currently.
        // Therefore, XCTAssertNotEqual("NEW RECORD") should FAIL on the legacy code.
        // If it passes, it means legacy code is already strict OR my assumption is wrong.
        
        let status = viewModel.sessionEndStatus
        XCTAssertNotEqual(status.title, "NEW RECORD", "Session with 1 error should NOT be a NEW RECORD (Certified)")
    }
    
    func testCertificationSucceedsWithSuddenDeath_GameMode() async {
        // Given
        viewModel.selectedMode = .game
        viewModel.startSession()
        
        // Mock Ghost starting... user typed 1 digit
        viewModel.processInput(1) 
        
        // Wait for ghost to advance? No, easier to mock ghost position or just trigger the logic
        // In SVM_MockDigitsProvider, 50 digits is short enough.
        
        // Let's assume we are ahead of ghost (delta > 0)
        // With current Mock, ghost is at PB.
        // We need a PB to have a ghost.
        let times = Array(repeating: 1.0, count: 10)
        let record = PersonalBestRecord(constant: .pi, type: .crown, digitCount: 10, totalTime: 10, cumulativeTimes: times)
        await PersonalBestStore.shared.save(record: record)
        
        viewModel.startSession() // Re-start with PB
        viewModel.processInput(1) // Start Ghost
        viewModel.processInput(4) // Second correct digit
        
        // Force a delta > 0
        // Player: 2 correct, 1 error -> Effective pos = 1 (max(0, 2-1))
        // Ghost: at start ~0.
        // Delta = 1.
        
        // When: User makes error while ahead
        XCTAssertTrue(viewModel.ghostEngine != nil, "GhostEngine should be initialized")
        XCTAssertEqual(viewModel.currentIndex, 2, "CurrentIndex should be 2")
        
        viewModel.processInput(3) // Wrong digit
        
        // Then: Should trigger Sudden Death
        XCTAssertFalse(viewModel.isActive, "Session should have ended by Sudden Death")
        
        // Certification check
        let status = viewModel.sessionEndStatus
        XCTAssertEqual(status.title, "CERTIFIED", "Sudden Death victory should be certified")
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
        viewModel.endSession()
        
        // Check Status (assuming it beat previous null record)
        let status = viewModel.sessionEndStatus
        XCTAssertEqual(status.title, "NEW RECORD", "Perfect session should be certified and marked NEW RECORD")
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
        
        // Then
        // Current Default implementation: Fetches CROWN only.
        // So with Crown MISSING, this should FAIL (ghostEngine will be nil).
        // This confirms the "RED" state (Bug: Fallback missing).
        XCTAssertNotNil(viewModel.ghostEngine, "Ghost Engine should interpret Lightning record if Crown is missing")
        XCTAssertEqual(viewModel.ghostEngine?.totalDigits, 50, "Should select Lightning when Crown is missing")
    }
}

// MARK: - Mocks

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
}

class MockPersonalBestStore {
    // Helper to reset singleton for tests
}

struct SVM_MockDigitsProvider: DigitsProvider {
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
    
    mutating func loadDigits() throws {}
}
