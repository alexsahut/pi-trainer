import XCTest
@testable import PiTrainer

final class GhostEngineTests: XCTestCase {
    
    var ghostEngine: GhostEngine!
    var mockPB: PersonalBestRecord!
    
    override func setUp() {
        super.setUp()
        // Mock timestamps: 1s, 2s, 3s, 4s, 5s (1 digit per second)
        let timestamps: [TimeInterval] = [1.0, 2.0, 3.0, 4.0, 5.0]
        
        mockPB = PersonalBestRecord(
            constant: .pi,
            digitCount: 5,
            totalTime: 5.0,
            cumulativeTimes: timestamps
        )
        
        ghostEngine = GhostEngine(personalBest: mockPB)
    }
    
    func testGhostPositionAtStart() {
        // At start, ghostPosition is 0 and engine hasn't started
        XCTAssertEqual(ghostEngine.ghostPosition, 0)
        
        // Test logic directly
        XCTAssertEqual(ghostEngine.calculateInterpolatedPosition(at: 10.0), 5) 
    }
    
    func testGhostPositionAfterSignal() {
        // Start engine
        ghostEngine.start()
        
        // Timestamps: [1.0, 2.0, 3.0, 4.0, 5.0]
        
        // 1. Midway (1.5s) -> 1.0 (start of segment 1) to 2.0 (end).
        // Segment 1 starts at 1.0 (index 0 implies start 0? No:
        // i=0: endTime=1.0, startTime=0.
        // i=1: endTime=2.0, startTime=1.0.
        
        // Elapsed 1.5 falls in i=1 (1.0 to 2.0).
        // progress = (1.5 - 1.0) / (2.0 - 1.0) = 0.5.
        // Result = Double(1) + 0.5 = 1.5.
        XCTAssertEqual(ghostEngine.calculateInterpolatedPosition(at: 1.5), 1.5)
        
        // 2. Exact Match (2.0s) -> Limit of segment 1.
        // i=1: elapsed <= 2.0.
        // progress = (2.0 - 1.0)/1.0 = 1.0.
        // Result = 1.0 + 1.0 = 2.0.
        XCTAssertEqual(ghostEngine.calculateInterpolatedPosition(at: 2.0), 2.0)
        
        // 3. Way Finished (100.0s) -> 5 digits
        XCTAssertEqual(ghostEngine.calculateInterpolatedPosition(at: 100.0), 5)
    }
    
    func testGhostCantRestart() {
        ghostEngine.start()
        // Should not crash or reset if start called again
        ghostEngine.start()
    }
}
