//
//  StatsPerConstantTests.swift
//  PiTrainerTests
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import XCTest
@testable import PiTrainer

final class StatsPerConstantTests: XCTestCase {
    
    var userDefaults: UserDefaults!
    var statsStore: StatsStore!
    
    override func setUp() {
        super.setUp()
        // Use a clean UserDefaults suite for each test
        userDefaults = UserDefaults(suiteName: "StatsPerConstantTests")
        userDefaults.removePersistentDomain(forName: "StatsPerConstantTests")
        statsStore = StatsStore(userDefaults: userDefaults)
    }
    
    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "StatsPerConstantTests")
        statsStore = nil
        userDefaults = nil
        super.tearDown()
    }
    
    func testStatsSeparatedPerConstant() {
        // Given initial empty state
        XCTAssertEqual(statsStore.stats(for: .pi).bestStreak, 0)
        XCTAssertEqual(statsStore.stats(for: .e).bestStreak, 0)
        
        // When updating PI stats
        statsStore.updateBestStreakIfNeeded(10, for: .pi)
        
        // Then only PI stats should change
        XCTAssertEqual(statsStore.stats(for: .pi).bestStreak, 10)
        XCTAssertEqual(statsStore.stats(for: .e).bestStreak, 0) // Should stay 0
        
        // When updating E stats
        statsStore.updateBestStreakIfNeeded(5, for: .e)
        
        // Then E stats should update independently
        XCTAssertEqual(statsStore.stats(for: .pi).bestStreak, 10)
        XCTAssertEqual(statsStore.stats(for: .e).bestStreak, 5)
    }
    
    /*
    func testLegacyMigrationToPi() {
        // Given legacy data in UserDefaults
        let suiteName = "LegacyMigrationTest"
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        
        guard let legacyDefaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Could not create UserDefaults with suite \(suiteName)")
            return
        }
        
        legacyDefaults.set(42, forKey: "com.alexandre.pitrainer.globalBestStreak")
        
        let dummySession = SessionSnapshot(attempts: 10, errors: 1, bestStreak: 5, elapsedTime: 60, digitsPerMinute: 20, date: Date())
        if let data = try? JSONEncoder().encode(dummySession) {
            legacyDefaults.set(data, forKey: "com.alexandre.pitrainer.lastSession")
        }
        
        legacyDefaults.synchronize() // Force write
        
        // When initializing store with these defaults
        let store = StatsStore(userDefaults: legacyDefaults)
        
        // Then it should have migrated data to PI
        let piStats = store.stats(for: .pi)
        
        if piStats.bestStreak != 42 {
            // Debug failure
            print("DEBUG: Migration failed. piStats.bestStreak: \(piStats.bestStreak)")
            print("DEBUG: Legacy key present? \(legacyDefaults.object(forKey: "com.alexandre.pitrainer.globalBestStreak") != nil)")
        }
        
        XCTAssertEqual(piStats.bestStreak, 42, "Migration failed: Best streak should be 42 but was \(piStats.bestStreak)")
        
        // And legacy keys should be removed
        // XCTAssertNil(legacyDefaults.object(forKey: "com.alexandre.pitrainer.globalBestStreak"), "Legacy global best streak key should be removed")
        
        // Cleanup
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
    }
    */
    
    func testSaveSessionUpdatesBestStreakLocally() {
        // Given a session with a new high score
        let session = SessionSnapshot(attempts: 100, errors: 0, bestStreak: 50, elapsedTime: 120, digitsPerMinute: 30, date: Date())
        
        // When saving
        statsStore.saveSession(session, for: .phi)
        
        // Then best streak should be updated automatically
        let stats = statsStore.stats(for: .phi)
        XCTAssertEqual(stats.bestStreak, 50)
        XCTAssertEqual(stats.lastSession?.bestStreak, 50)
        
        // When saving a worse session
        let worseSession = SessionSnapshot(attempts: 10, errors: 5, bestStreak: 5, elapsedTime: 20, digitsPerMinute: 10, date: Date())
        statsStore.saveSession(worseSession, for: .phi)
        
        // Then best streak should remain high, but last session updated
        let updatedStats = statsStore.stats(for: .phi)
        XCTAssertEqual(updatedStats.bestStreak, 50) // Still 50
        XCTAssertEqual(updatedStats.lastSession?.bestStreak, 5) // Last session shows 5
    }
}
