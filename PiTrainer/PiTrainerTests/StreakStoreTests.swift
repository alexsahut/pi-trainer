import XCTest
@testable import PiTrainer

@MainActor
final class StreakStoreTests: XCTestCase {
    
    var store: StreakStore!
    let calendar = Calendar.current
    
    override func setUp() {
        super.setUp()
        // Clear UserDefaults before each test
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        store = StreakStore()
    }
    
    func testInitialState() {
        XCTAssertEqual(store.currentStreak, 0)
        XCTAssertNil(store.lastPracticeDate)
    }
    
    func testFirstSessionIncrementsTo1() {
        store.recordSession()
        XCTAssertEqual(store.currentStreak, 1)
        XCTAssertNotNil(store.lastPracticeDate)
    }
    
    func testConsecutiveDayIncrements() {
        // 1. First day
        store.recordSession()
        XCTAssertEqual(store.currentStreak, 1)
        
        // 2. Mock "yesterday" as the last practice date
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        store.setTestLastDate(yesterday)
        
        // 3. Second day
        store.recordSession()
        XCTAssertEqual(store.currentStreak, 2)
    }
    
    func testSameDayDoesNotIncrement() {
        store.recordSession()
        XCTAssertEqual(store.currentStreak, 1)
        
        store.recordSession()
        XCTAssertEqual(store.currentStreak, 1)
    }
    
    func testMissedDayResetsTo1() {
        // 1. Establish a streak
        store.recordSession()
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: Date())!
        store.setTestLastDate(twoDaysAgo)
        
        // 2. Practice after gap
        store.recordSession()
        XCTAssertEqual(store.currentStreak, 1)
    }
    
    func testRefreshStreakResetsExpiredStreakTo0() {
        // 1. Establish a streak
        store.recordSession()
        XCTAssertEqual(store.currentStreak, 1)
        
        // 2. Wait 2 days (mock)
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: Date())!
        store.setTestLastDate(twoDaysAgo)
        
        // 3. Refresh
        store.refreshStreak()
        XCTAssertEqual(store.currentStreak, 0)
    }
}
