import XCTest
@testable import PiTrainer

@MainActor
class ChallengeScoreStoreTests: XCTestCase {

    var store: ChallengeScoreStore!
    let testDefaults = UserDefaults(suiteName: "ChallengeScoreStoreTests")!

    override func setUp() {
        super.setUp()
        testDefaults.removePersistentDomain(forName: "ChallengeScoreStoreTests")
        store = ChallengeScoreStore(defaults: testDefaults)
    }

    override func tearDown() {
        store = nil
        testDefaults.removePersistentDomain(forName: "ChallengeScoreStoreTests")
        super.tearDown()
    }

    func testBestScore_NilWhenNotSet() {
        XCTAssertNil(store.bestScore(for: .pi))
    }

    func testSaveBestScore_FirstScore_Saves() {
        store.saveBestScore(50, for: .pi)
        XCTAssertEqual(store.bestScore(for: .pi), 50)
    }

    func testSaveBestScore_HigherScore_Updates() {
        store.saveBestScore(50, for: .pi)
        store.saveBestScore(80, for: .pi)
        XCTAssertEqual(store.bestScore(for: .pi), 80)
    }

    func testSaveBestScore_LowerScore_DoesNotUpdate() {
        store.saveBestScore(80, for: .pi)
        store.saveBestScore(30, for: .pi)
        XCTAssertEqual(store.bestScore(for: .pi), 80)
    }

    func testSaveBestScore_EqualScore_DoesNotUpdate() {
        store.saveBestScore(80, for: .pi)
        store.saveBestScore(80, for: .pi)
        XCTAssertEqual(store.bestScore(for: .pi), 80)
    }

    func testBestScore_PerConstant_Independent() {
        store.saveBestScore(100, for: .pi)
        store.saveBestScore(50, for: .e)
        XCTAssertEqual(store.bestScore(for: .pi), 100)
        XCTAssertEqual(store.bestScore(for: .e), 50)
    }

    func testBestScore_NegativeScore_Saves() {
        store.saveBestScore(-25, for: .pi)
        XCTAssertEqual(store.bestScore(for: .pi), -25)
    }

    func testBestScore_NegativeScore_UpdatedByPositive() {
        store.saveBestScore(-25, for: .pi)
        store.saveBestScore(10, for: .pi)
        XCTAssertEqual(store.bestScore(for: .pi), 10)
    }

    // MARK: - New Record Detection (AC5)

    func testIsNewRecord_FirstScoreAlwaysRecord() {
        XCTAssertTrue(ChallengeScoreStore.isNewRecord(score: -25, previousBest: nil))
        XCTAssertTrue(ChallengeScoreStore.isNewRecord(score: 0, previousBest: nil))
        XCTAssertTrue(ChallengeScoreStore.isNewRecord(score: 100, previousBest: nil))
    }

    func testIsNewRecord_HigherScoreIsRecord() {
        XCTAssertTrue(ChallengeScoreStore.isNewRecord(score: 80, previousBest: 50))
    }

    func testIsNewRecord_EqualScoreIsNotRecord() {
        XCTAssertFalse(ChallengeScoreStore.isNewRecord(score: 50, previousBest: 50))
    }

    func testIsNewRecord_LowerScoreIsNotRecord() {
        XCTAssertFalse(ChallengeScoreStore.isNewRecord(score: 30, previousBest: 50))
    }

    // MARK: - Story 17.6: score = 0 edge case

    func testSaveBestScore_ZeroScore_DistinguishedFromNil() {
        // Verify that saving score=0 produces bestScore == 0 (not nil)
        XCTAssertNil(store.bestScore(for: .pi), "Initially should be nil (no score)")

        store.saveBestScore(0, for: .pi)

        let result = store.bestScore(for: .pi)
        XCTAssertNotNil(result, "Score of 0 should be distinguishable from nil")
        XCTAssertEqual(result, 0, "Best score should be exactly 0")
    }
}
