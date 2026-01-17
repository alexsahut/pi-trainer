//
//  SessionHistoryStoreTests.swift
//  PiTrainerTests
//
//  Created by Antigravity on 16/01/2026.
//

import XCTest
@testable import PiTrainer

final class SessionHistoryStoreTests: XCTestCase {
    
    var store: SessionHistoryStore!
    let testConstant: Constant = .pi
    let testDirectory: URL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    
    override func setUp() {
        super.setUp()
        do {
            // Create a dedicated temp directory for this test run
            try FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true)
            store = try SessionHistoryStore(customDirectory: testDirectory)
        } catch {
            XCTFail("Failed to initialize SessionHistoryStore: \(error)")
        }
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: testDirectory)
        store = nil
        super.tearDown()
    }
    
    private func getHistoryFileURL(for constant: Constant) -> URL {
        return testDirectory.appendingPathComponent("session_history_\(constant.id).json")
    }
    
    func testSaveAndLoadHistory() async throws {
        // Given
        let records = [
            createRecord(id: UUID(), errors: 1),
            createRecord(id: UUID(), errors: 2)
        ]
        
        // When
        try await store.saveHistory(records, for: testConstant)
        let loadedRecords = try await store.loadHistory(for: testConstant)
        
        // Then
        XCTAssertEqual(loadedRecords.count, 2)
        XCTAssertEqual(loadedRecords[0].id, records[0].id)
        XCTAssertEqual(loadedRecords[1].id, records[1].id)
    }
    
    func testFIFO_200SessionLimit() async throws {
        // When: Add 210 records using appendRecord (which is the real production path)
        for i in 1...210 {
            let record = createRecord(id: UUID(), errors: i)
            _ = try await store.appendRecord(record, for: testConstant)
        }
        
        let loadedRecords = try await store.loadHistory(for: testConstant)
        
        // Then
        XCTAssertEqual(loadedRecords.count, 200)
        
        // In newest-first strategy:
        // Index 0 should be the LAST one added (errors: 210)
        XCTAssertEqual(loadedRecords.first?.errors, 210)
        // Index 199 should be the oldest kept (errors: 11, since 1-10 were dropped)
        XCTAssertEqual(loadedRecords.last?.errors, 11)
    }
    
    func testMultipleConstants_SeparateFiles() async throws {
        // Given
        let piRecord = createRecord(constant: .pi)
        let eRecord = createRecord(constant: .e)
        
        // When
        try await store.saveHistory([piRecord], for: .pi)
        try await store.saveHistory([eRecord], for: .e)
        
        let loadedPi = try await store.loadHistory(for: .pi)
        let loadedE = try await store.loadHistory(for: .e)
        
        // Then
        XCTAssertEqual(loadedPi.count, 1)
        XCTAssertEqual(loadedPi.first?.id, piRecord.id)
        XCTAssertEqual(loadedE.count, 1)
        XCTAssertEqual(loadedE.first?.id, eRecord.id)
    }
    
    func testLoadHistory_FileNotFound_ReturnsEmpty() async throws {
        // When
        let records = try await store.loadHistory(for: .phi)
        
        // Then
        XCTAssertTrue(records.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func createRecord(
        constant: Constant = .pi,
        mode: PracticeEngine.Mode = .strict,
        date: Date = Date(),
        id: UUID = UUID(),
        errors: Int = 0
    ) -> SessionRecord {
        return SessionRecord(
            id: id,
            date: date,
            constant: constant,
            mode: mode,
            attempts: 10 + errors,
            errors: errors,
            bestStreakInSession: 10,
            durationSeconds: 60,
            digitsPerMinute: 30.0,
            revealsUsed: 0,
            minCPS: nil,
            maxCPS: 0
        )
    }
}
