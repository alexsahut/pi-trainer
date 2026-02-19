//
//  GradeTests.swift
//  PiTrainerTests
//
//  Created by Alexandre SAHUT on 24/01/2026.
//

import XCTest
@testable import PiTrainer

@MainActor
class GradeMockPersistence: PracticePersistenceProtocol {
    var userDefaults: UserDefaults = .standard
    func saveHighestIndex(_ index: Int, for constantKey: String) {}
    func getHighestIndex(for constantKey: String) -> Int { 0 }
    func saveStats(_ stats: [Constant: ConstantStats]) {}
    func loadStats() -> [Constant: ConstantStats]? { nil }
    func saveKeypadLayout(_ layout: String) {}
    func loadKeypadLayout() -> String? { nil }
    func saveSelectedConstant(_ constant: String) {}
    func loadSelectedConstant() -> String? { nil }
    func saveSelectedMode(_ mode: String) {}
    func loadSelectedMode() -> String? { nil }
    func saveSelectedGhostType(_ type: String) {}
    func loadSelectedGhostType() -> String? { nil }
    func saveAutoAdvance(_ enabled: Bool) {}
    func loadAutoAdvance() -> Bool? { nil }
    func saveLastChallengeDate(_ date: Date) {}
    func loadLastChallengeDate() -> Date? { nil }
    func saveTotalCorrectDigits(_ count: Int) {}
    func loadTotalCorrectDigits() -> Int { 0 }
}

@MainActor
final class GradeTests: XCTestCase {
    
    func testGradeFromXP() {
        XCTAssertEqual(Grade.from(xp: 0), Grade.novice)
        XCTAssertEqual(Grade.from(xp: 500), Grade.novice)
        XCTAssertEqual(Grade.from(xp: 999), Grade.novice)
        
        XCTAssertEqual(Grade.from(xp: 1000), Grade.apprentice)
        XCTAssertEqual(Grade.from(xp: 4999), Grade.apprentice)
        
        XCTAssertEqual(Grade.from(xp: 5000), Grade.athlete)
        XCTAssertEqual(Grade.from(xp: 19999), Grade.athlete)
        
        XCTAssertEqual(Grade.from(xp: 20000), Grade.expert)
        XCTAssertEqual(Grade.from(xp: 99999), Grade.expert)
        
        XCTAssertEqual(Grade.from(xp: 100000), Grade.grandmaster)
        XCTAssertEqual(Grade.from(xp: 1000000), Grade.grandmaster)
    }
    
    func testStatsStore_XPAccumulation() async {
        // Given
        let persistence = GradeMockPersistence()
        let store = StatsStore(persistence: persistence)
        
        // When: Adding a session with 10 attempts and 2 errors (8 correct)
        let record = SessionRecord(
            id: UUID(),
            date: Date(),
            constant: .pi,
            mode: .strict,
            sessionMode: .test,
            attempts: 10,
            errors: 2,
            bestStreakInSession: 5,
            durationSeconds: 10,
            digitsPerMinute: 60,
            revealsUsed: 0,
            minCPS: 1.0,
            maxCPS: 2.0,
            segmentStart: nil,
            segmentEnd: nil,
            loops: 1,
            isCertified: true,
            wasVictory: true,
            beatenPRTypes: nil
        )
        
        store.addSessionRecord(record)
        
        // Wait for async update (addSessionRecord triggers Task for save and recalculate)
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Then
        XCTAssertEqual(store.totalCorrectDigits, 8, "XP should be calculated as attempts - errors")
        XCTAssertEqual(store.currentGrade, Grade.novice)
    }
}
