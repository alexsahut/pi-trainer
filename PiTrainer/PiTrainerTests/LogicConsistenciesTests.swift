import XCTest
@testable import PiTrainer

@MainActor
final class LogicConsistenciesTests: XCTestCase {
    
    var viewModel: SessionViewModel!
    var statsStore: StatsStore!
    var tempDir: URL!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Reset UserDefaults
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        
        // Isolate History
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let historyStore = try SessionHistoryStore(customDirectory: tempDir)
        
        statsStore = StatsStore(historyStore: historyStore)
        
        // Mock PB for all tests to ensure ghost is available if needed
        // 3.141592653...
        // Index 1: 1, Index 2: 4, Index 3: 1, Index 4: 5, Index 5: 9...
        let mockPB = PersonalBestRecord(constant: .pi, type: .crown, digitCount: 10, totalTime: 10, cumulativeTimes: Array(repeating: 1.0, count: 10))
        
        viewModel = SessionViewModel(personalBestProvider: { _ in
            return mockPB
        })
        viewModel.onSaveSession = { [weak statsStore] record in
            statsStore?.addSessionRecord(record)
        }
    }
    
    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: tempDir)
        try await super.tearDown()
    }
    
    func testGameMode_Defeat_NotCertified() async {
        viewModel.selectedMode = .game
        viewModel.startSession()
        
        viewModel.processInput(1) 
        viewModel.isDefeatedByGhost = true
        viewModel.endSession() 
        
        // Wait for async update
        try? await Task.sleep(nanoseconds: 500_000_000) 
        
        let history = statsStore.history(for: .pi)
        print("debug: defeat history count: \(history.count)")
        if let record = history.first {
            print("debug: defeat record isCertified: \(record.isCertified)")
            XCTAssertFalse(record.isCertified, "Defeat should NOT be certified")
            XCTAssertEqual(record.wasVictory, false, "Defeat should have wasVictory = false")
        } else {
            XCTFail("Record should have been saved")
        }
        
        XCTAssertEqual(statsStore.bestStreak(for: .pi), 0, "Non-certified run should not update Best Streak")
    }
    
    func testGameMode_SuddenDeath_IsCertified() async {
        viewModel.selectedMode = .game
        viewModel.startSession()
        
        viewModel.processInput(1) // Correct (pos 1)
        viewModel.processInput(4) // Correct (pos 2)
        
        // Ensure ghost is started and we have a delta
        let delta = viewModel.atmosphericDelta(at: Date())
        print("debug: suddenDeath delta: \(delta)")
        XCTAssertTrue(delta > 0, "Player should be ahead of ghost for Sudden Death")
        
        viewModel.processInput(3) // Error -> Sudden Death
        
        // Wait for async update
        try? await Task.sleep(nanoseconds: 500_000_000) 
        
        print("debug: suddenDeath isActive: \(viewModel.isActive)")
        XCTAssertFalse(viewModel.isActive, "Session should have ended by Sudden Death")
        
        let history = statsStore.history(for: .pi)
        if let session = history.first {
            print("debug: suddenDeath record isCertified: \(session.isCertified)")
            XCTAssertTrue(session.isCertified, "Sudden Death Victory SHOULD be certified")
            XCTAssertEqual(session.wasVictory, true, "Sudden Death should have wasVictory = true")
        } else {
            XCTFail("Record should have been saved")
        }
        
        XCTAssertEqual(statsStore.bestStreak(for: .pi), 2, "Certified Sudden Death should update Best Streak")
    }
    
    func testPracticeMode_Error_NotCertified() async {
        viewModel.selectedMode = .practice
        viewModel.startSession()
        
        viewModel.processInput(1) // Correct
        viewModel.processInput(4) // Correct
        viewModel.processInput(3) // Error (Correct is 1)
        
        viewModel.endSession()
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        let session = statsStore.history(for: .pi).first
        XCTAssertNotNil(session)
        XCTAssertFalse(session!.isCertified, "Practice session with error should NOT be certified")
        XCTAssertEqual(statsStore.bestStreak(for: .pi), 0, "Non-certified run should not update Best Streak")
        XCTAssertNil(statsStore.stats(for: .pi).bestSession, "Non-certified run should not set Best Session")
    }
    
    func testTestMode_Perfect_IsCertified() async {
        viewModel.selectedMode = .test
        viewModel.startSession()
        
        viewModel.processInput(1)
        viewModel.processInput(4)
        viewModel.processInput(1)
        
        viewModel.endSession() 
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        let session = statsStore.history(for: .pi).first
        XCTAssertNotNil(session, "Session should be saved")
        XCTAssertTrue(session?.isCertified == true, "Perfect Test session SHOULD be certified")
        XCTAssertEqual(statsStore.bestStreak(for: .pi), 3, "Certified session should update Best Streak")
    }
    
    func testTestMode_Fail_IsCertified() async {
        viewModel.selectedMode = .test
        viewModel.startSession()
        
        viewModel.processInput(1) // pos 1: 1
        viewModel.processInput(4) // pos 2: 4
        viewModel.processInput(3) // pos 3: Error (1 expected) -> Session ends
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        XCTAssertFalse(viewModel.isActive, "Test session should end on first error")
        XCTAssertEqual(viewModel.engine.errors, 1)
        XCTAssertEqual(viewModel.engine.bestStreak, 2)
        
        let session = statsStore.history(for: .pi).first
        XCTAssertNotNil(session, "Session should be saved automatically on fail")
        XCTAssertTrue(session?.isCertified == true, "Test session failing on error SHOULD be certified")
        XCTAssertEqual(statsStore.bestStreak(for: .pi), 2, "Certified session with error should update Best Streak")
    }
}
