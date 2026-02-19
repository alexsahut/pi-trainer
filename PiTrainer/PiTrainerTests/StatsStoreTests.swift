//
//  StatsStoreTests.swift
//  PiTrainerTests
//
//  Created by Antigravity on 25/01/2026.
//

import XCTest
@testable import PiTrainer

@MainActor
final class StatsStoreTests: XCTestCase {
    
    var statsStore: StatsStore!
    var mockPersistence: MockPracticePersistence!
    var mockHistoryStore: SessionHistoryStore!
    
    override func setUp() async throws {
        try await super.setUp()
        mockPersistence = MockPracticePersistence()
        
        // Use a temporary directory for history store to avoid side effects
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        mockHistoryStore = try SessionHistoryStore(customDirectory: tempDir)
        
        statsStore = StatsStore(persistence: mockPersistence, historyStore: mockHistoryStore)
        RewardManager.shared.resetDoubleBang()
    }
    
    override func tearDown() async throws {
        statsStore = nil
        mockPersistence = nil
        mockHistoryStore = nil
        try await super.tearDown()
    }
    
    func testDoubleBangTriggerConditions() async {
        // Initial state: 0 XP, Novice grade, no record
        XCTAssertEqual(statsStore.totalCorrectDigits, 0)
        XCTAssertEqual(statsStore.currentGrade, .novice)
        XCTAssertFalse(RewardManager.shared.isDoubleBangActive)
        
        // 1. Create a first record (PB but no grade change)
        let record1 = SessionRecord(
            constant: .pi,
            mode: .strict,
            sessionMode: .test,
            attempts: 100,
            errors: 0,
            bestStreakInSession: 100,
            durationSeconds: 60,
            digitsPerMinute: 100,
            isCertified: true
        )
        
        statsStore.addSessionRecord(record1)
        XCTAssertEqual(statsStore.totalCorrectDigits, 100)
        XCTAssertFalse(RewardManager.shared.isDoubleBangActive, "Should not trigger on first record (not beating a previous record)")
        
        // 2. Beat record but no grade change
        let record2 = SessionRecord(
            constant: .pi,
            mode: .strict,
            sessionMode: .test,
            attempts: 150,
            errors: 0,
            bestStreakInSession: 150,
            durationSeconds: 90,
            digitsPerMinute: 100,
            isCertified: true
        )
        
        RewardManager.shared.resetDoubleBang()
        statsStore.addSessionRecord(record2)
        XCTAssertEqual(statsStore.totalCorrectDigits, 250) // 100 + 150
        XCTAssertFalse(RewardManager.shared.isDoubleBangActive, "Should not trigger on PB beating if grade didn't change")
        
        // 3. Reach grade change but no Record Beaten (not certified or lower score)
        // Need 1000 XP for Apprentice. Current is 250. Need 750 more.
        let record3 = SessionRecord(
            constant: .pi,
            mode: .learning,
            sessionMode: .learn,
            attempts: 800,
            errors: 0,
            bestStreakInSession: 800,
            durationSeconds: 600,
            digitsPerMinute: 80,
            isCertified: false // Not certified, won't count for PB
        )
        
        RewardManager.shared.resetDoubleBang()
        statsStore.addSessionRecord(record3)
        XCTAssertGreaterThanOrEqual(statsStore.totalCorrectDigits, 1000)
        XCTAssertEqual(statsStore.currentGrade, .apprentice)
        XCTAssertFalse(RewardManager.shared.isDoubleBangActive, "Should not trigger on Grade change if PB was not beaten")
        
        // 4. Record Beaten AND Grade Change simultaneously
        // Current XP: 1050. Next grade (Athlete) is at 5000. Need 3950 more.
        // Current Best Streak is 150.
        
        let record4 = SessionRecord(
            constant: .pi,
            mode: .strict,
            sessionMode: .test,
            attempts: 4000,
            errors: 0,
            bestStreakInSession: 4000,
            durationSeconds: 2000,
            digitsPerMinute: 120,
            isCertified: true
        )
        
        RewardManager.shared.resetDoubleBang()
        statsStore.addSessionRecord(record4)
        XCTAssertGreaterThanOrEqual(statsStore.totalCorrectDigits, 5000)
        XCTAssertEqual(statsStore.currentGrade, .athlete)
        XCTAssertTrue(RewardManager.shared.isDoubleBangActive, "DOUBLE BANG! Should trigger when both PB is beaten and Grade changes.")
    }
}

// MARK: - Mocks

class MockPracticePersistence: PracticePersistenceProtocol {
    var userDefaults: UserDefaults = .standard
    
    func getHighestIndex(for constantKey: String) -> Int { 0 }
    func saveHighestIndex(_ index: Int, for constantKey: String) {}
    func loadStats() -> [Constant : ConstantStats]? { nil }
    func saveStats(_ stats: [Constant : ConstantStats]) {}
    func loadSelectedConstant() -> String? { "pi" }
    func saveSelectedConstant(_ constantId: String) {}
    func loadSelectedMode() -> String? { nil }
    func saveSelectedMode(_ mode: String) {}
    func loadKeypadLayout() -> String? { nil }
    func saveKeypadLayout(_ layout: String) {}
    func loadAutoAdvance() -> Bool? { nil }
    func saveAutoAdvance(_ enabled: Bool) {}
    func loadSelectedGhostType() -> String? { nil }
    func saveSelectedGhostType(_ type: String) {}
    
    func saveLastChallengeDate(_ date: Date) {}
    func loadLastChallengeDate() -> Date? { nil }
    
    private var xp: Int = 0
    func loadTotalCorrectDigits() -> Int { xp }
    func saveTotalCorrectDigits(_ total: Int) { xp = total }
}
