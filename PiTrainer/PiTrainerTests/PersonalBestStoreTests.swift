//
//  PersonalBestStoreTests.swift
//  PiTrainerTests
//
//  Created by Automation on 21/01/2026.
//

import XCTest
@testable import PiTrainer

@MainActor
final class PersonalBestStoreTests: XCTestCase {
    
    var store: PersonalBestStore!
    var testDirectoryName: String!
    let fileManager = FileManager.default
    
    override func setUp() async throws {
        try await super.setUp()
        testDirectoryName = "TestPersonalBests-\(UUID().uuidString)"
        store = PersonalBestStore(storageDirectoryName: testDirectoryName)
    }
    
    override func tearDown() async throws {
        // Cleanup test directory
        if let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let testDir = docs.appendingPathComponent(testDirectoryName)
            try? fileManager.removeItem(at: testDir)
        }
        store = nil
        try await super.tearDown()
    }
    
// MARK: - Crown PR (Distance)
    
    func testSave_CrownPR_NewRecord_Saves() async {
        let record = PersonalBestRecord(
            constant: .pi,
            type: .crown,
            digitCount: 10,
            totalTime: 5.0,
            cumulativeTimes: [] // Mock empty for store logic test
        )
        
        await store.save(record: record)
        
        let saved = store.getRecord(for: .pi, type: .crown)
        XCTAssertNotNil(saved)
        XCTAssertEqual(saved?.digitCount, 10)
    }
    
    func testSave_CrownPR_BetterDistance_Overwrites() async {
        let oldRecord = PersonalBestRecord(constant: .pi, type: .crown, digitCount: 10, totalTime: 5.0, cumulativeTimes: [])
        await store.save(record: oldRecord)
        
        let newRecord = PersonalBestRecord(constant: .pi, type: .crown, digitCount: 11, totalTime: 6.0, cumulativeTimes: [])
        await store.save(record: newRecord)
        
        let saved = store.getRecord(for: .pi, type: .crown)
        XCTAssertEqual(saved?.digitCount, 11)
    }
    
    func testSave_CrownPR_WorseDistance_Ignored() async {
        let oldRecord = PersonalBestRecord(constant: .pi, type: .crown, digitCount: 10, totalTime: 5.0, cumulativeTimes: [])
        await store.save(record: oldRecord)
        
        let newRecord = PersonalBestRecord(constant: .pi, type: .crown, digitCount: 5, totalTime: 2.0, cumulativeTimes: [])
        await store.save(record: newRecord)
        
        let saved = store.getRecord(for: .pi, type: .crown)
        XCTAssertEqual(saved?.digitCount, 10)
    }
    
    func testSave_CrownPR_TieBreak_BetterTime_Overwrites() async {
        let oldRecord = PersonalBestRecord(constant: .pi, type: .crown, digitCount: 10, totalTime: 5.0, cumulativeTimes: [])
        await store.save(record: oldRecord)
        
        // Same distance (10), Better time (4.0)
        let newRecord = PersonalBestRecord(constant: .pi, type: .crown, digitCount: 10, totalTime: 4.0, cumulativeTimes: [])
        await store.save(record: newRecord)
        
        let saved = store.getRecord(for: .pi, type: .crown)
        XCTAssertEqual(saved?.digitCount, 10)
        XCTAssertEqual(saved?.totalTime, 4.0)
    }
    
    func testSave_CrownPR_TieBreak_WorseTime_Ignored() async {
        let oldRecord = PersonalBestRecord(constant: .pi, type: .crown, digitCount: 10, totalTime: 5.0, cumulativeTimes: [])
        await store.save(record: oldRecord)
        
        // Same distance, Worse time (6.0)
        let newRecord = PersonalBestRecord(constant: .pi, type: .crown, digitCount: 10, totalTime: 6.0, cumulativeTimes: [])
        await store.save(record: newRecord)
        
        let saved = store.getRecord(for: .pi, type: .crown)
        XCTAssertEqual(saved?.totalTime, 5.0)
    }
    
    // MARK: - Lightning PR (Speed)
    
    func testSave_LightningPR_UnderThreshold_Ignored() async {
        // Threshold is digitCount >= 10. Use digitCount < 10 to verify rejection.
        let record = PersonalBestRecord(constant: .pi, type: .lightning, digitCount: 5, totalTime: 2.0, cumulativeTimes: [])

        await store.save(record: record)

        let saved = store.getRecord(for: .pi, type: .lightning)
        XCTAssertNil(saved, "Should not save Lightning PR if digitCount < 10")
    }
    
    func testSave_LightningPR_AboveThreshold_NewRecord_Saves() async {
        let record = PersonalBestRecord(constant: .pi, type: .lightning, digitCount: 60, totalTime: 30.0, cumulativeTimes: [])
        // CPS = 2.0
        
        await store.save(record: record)
        
        let saved = store.getRecord(for: .pi, type: .lightning)
        XCTAssertNotNil(saved)
        XCTAssertEqual(saved?.digitCount, 60)
    }
    
    func testSave_LightningPR_BetterSpeed_Overwrites() async {
        let oldRecord = PersonalBestRecord(constant: .pi, type: .lightning, digitCount: 60, totalTime: 60.0, cumulativeTimes: [])
        // CPS = 1.0
        await store.save(record: oldRecord)
        
        let newRecord = PersonalBestRecord(constant: .pi, type: .lightning, digitCount: 60, totalTime: 30.0, cumulativeTimes: [])
        // CPS = 2.0
        await store.save(record: newRecord)
        
        let saved = store.getRecord(for: .pi, type: .lightning)
        XCTAssertEqual(saved?.totalTime, 30.0)
    }
    
    func testSave_LightningPR_WorseSpeed_Ignored() async {
        let oldRecord = PersonalBestRecord(constant: .pi, type: .lightning, digitCount: 60, totalTime: 30.0, cumulativeTimes: [])
        // CPS = 2.0
        await store.save(record: oldRecord)
        
        let newRecord = PersonalBestRecord(constant: .pi, type: .lightning, digitCount: 60, totalTime: 60.0, cumulativeTimes: [])
        // CPS = 1.0
        await store.save(record: newRecord)
        
        let saved = store.getRecord(for: .pi, type: .lightning)
        XCTAssertEqual(saved?.totalTime, 30.0)
    }
    
    func testSave_LightningPR_JustBelowThreshold_Ignored() async {
        // Boundary: 9 digits (threshold is >= 10, so 9 must be rejected)
        let record = PersonalBestRecord(constant: .pi, type: .lightning, digitCount: 9, totalTime: 4.0, cumulativeTimes: [])
        await store.save(record: record)

        let saved = store.getRecord(for: .pi, type: .lightning)
        XCTAssertNil(saved, "Should not save Lightning PR if digitCount == 9 (< 10)")
    }

    func testSave_LightningPR_ExactlyThreshold_Saves() async {
        // Boundary check: Exactly 10 digits (threshold is digitCount >= 10)
        let record = PersonalBestRecord(constant: .pi, type: .lightning, digitCount: 10, totalTime: 5.0, cumulativeTimes: [])
        await store.save(record: record)

        let saved = store.getRecord(for: .pi, type: .lightning)
        XCTAssertNotNil(saved)
        XCTAssertEqual(saved?.digitCount, 10)
    }
}
