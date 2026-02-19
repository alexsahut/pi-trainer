
import XCTest
@testable import PiTrainer

@MainActor
class SettingsTests: XCTestCase {
    var statsStore: StatsStore!
    var mockPersistence: SettingsMockPersistence!

    override func setUp() {
        super.setUp()
        mockPersistence = SettingsMockPersistence()
        // Initialize with dependencies
        statsStore = StatsStore(persistence: mockPersistence, historyStore: nil)
    }
    
    @MainActor
    func testAutoAdvancePersistence() {
        // 1. Verify Default (should be false)
        XCTAssertFalse(statsStore.isAutoAdvanceEnabled)
        
        // 2. Verify Set & Persist
        statsStore.isAutoAdvanceEnabled = true
        
        // 3. Verify it was saved to persistence
        XCTAssertTrue(mockPersistence.savedAutoAdvance == true, "Persistence should be updated")
        
        // 4. Verify Store reflects it
        XCTAssertTrue(statsStore.isAutoAdvanceEnabled)
        
        // 5. Toggle off
        statsStore.isAutoAdvanceEnabled = false
        XCTAssertTrue(mockPersistence.savedAutoAdvance == false, "Persistence should be updated to false")
    }
}

@MainActor
class SettingsMockPersistence: PracticePersistenceProtocol {
    var userDefaults: UserDefaults = .standard // Unused in mock logic
    var savedAutoAdvance: Bool?
    
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
    
    func saveSelectedGhostType(_ type: String) {}
    func loadSelectedGhostType() -> String? { nil }
    
    // Story 10.1: Mock Auto-Advance
    func saveAutoAdvance(_ enabled: Bool) { 
        savedAutoAdvance = enabled 
    }
    
    func loadAutoAdvance() -> Bool? { 
        return savedAutoAdvance 
    }
    
    func saveLastChallengeDate(_ date: Date) {}
    func loadLastChallengeDate() -> Date? { return nil }
    
    func saveTotalCorrectDigits(_ count: Int) {}
    func loadTotalCorrectDigits() -> Int { 0 }
}
