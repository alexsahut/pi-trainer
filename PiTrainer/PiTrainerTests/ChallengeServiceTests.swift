import XCTest
@testable import PiTrainer

// MARK: - Challenge Mocks

@MainActor
class ChallengeMockPersistence: PracticePersistenceProtocol {
    var userDefaults: UserDefaults = .standard
    var highestIndices: [String: Int] = [:]
    var lastChallengeDate: Date?
    
    func saveHighestIndex(_ index: Int, for constantKey: String) {
        highestIndices[constantKey] = index
    }
    func getHighestIndex(for constantKey: String) -> Int {
        return highestIndices[constantKey] ?? 0
    }
    
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
    func saveAutoAdvance(_ enabled: Bool) {}
    func loadAutoAdvance() -> Bool? { nil }
    
    func saveLastChallengeDate(_ date: Date) {
        lastChallengeDate = date
    }
    func loadLastChallengeDate() -> Date? {
        return lastChallengeDate
    }
    
    func saveTotalCorrectDigits(_ count: Int) {}
    func loadTotalCorrectDigits() -> Int { 0 }
}

class ChallengeMockDigitsProvider: DigitsProvider {
    var digits: String
    
    init(digits: String) {
        self.digits = digits
    }
    
    var totalDigits: Int { digits.count }
    var allDigitsString: String { digits }
    
    func getDigit(at index: Int) -> Int? {
        guard index >= 0 && index < digits.count else { return nil }
        let charIndex = digits.index(digits.startIndex, offsetBy: index)
        return Int(String(digits[charIndex])) ?? 0 // careful with conversion
    }
    
    func loadDigits() throws {}
}

// MARK: - Challenge Service Tests

@MainActor
final class ChallengeServiceTests: XCTestCase {
    
    var persistence: ChallengeMockPersistence!
    var provider: ChallengeMockDigitsProvider!
    var service: ChallengeService!
    
    override func setUp() {
        super.setUp()
        persistence = ChallengeMockPersistence()
        provider = ChallengeMockDigitsProvider(digits: "1234567890")
        service = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in self.provider }
        )
    }
    
    func testChallengeStructure() {
        let date = Date()
        let id = UUID()
        let challenge = Challenge(
            id: id,
            date: date,
            constant: .pi,
            startIndex: 10,
            referenceSequence: "314",
            expectedNextDigits: "159"
        )
        
        XCTAssertEqual(challenge.id, id)
    }
    
    func testServiceConformance() {
        XCTAssertTrue(service is ChallengeServiceProtocol)
    }
    
    func testCalculateMUS_SimpleSequence() {
        // sequence: 1 2 1 3
        let digits = Array("1213".utf8)
        let length = ChallengeService.calculateMUS(in: digits, at: 0)
        XCTAssertEqual(length, 2) // "12" is unique. "1" is not.
    }
    
    func testCalculateMUS_NoRepeat() {
        let digits = Array("1234".utf8)
        let length = ChallengeService.calculateMUS(in: digits, at: 0)
        XCTAssertEqual(length, 1) // "1" is unique
    }

    func testCalculateMUS_Overlap() {
        let digits = Array("1212".utf8)
        let length = ChallengeService.calculateMUS(in: digits, at: 0)
        XCTAssertEqual(length, 3) // "121" is unique. "12" repeats at index 2.
    }
    
    func testGenerateDailyChallenge_Deterministic() async {
        persistence.saveHighestIndex(5, for: Constant.pi.id)
        provider = ChallengeMockDigitsProvider(digits: "1415926535") // 10 digits
        
        // Re-init service with a local provider reference to avoid capture issues
        guard let testProvider = provider else {
            XCTFail("Provider should not be nil")
            return
        }
        service = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in testProvider }
        )
        
        let date = Date(timeIntervalSince1970: 1700000000)
        
        guard let challenge1 = await service.generateDailyChallenge(for: .pi, date: date, grade: .novice) else {
            XCTFail("challenge1 should generate (highestIndex: \(persistence.getHighestIndex(for: Constant.pi.id)))")
            return
        }
        
        guard let challenge2 = await service.generateDailyChallenge(for: .pi, date: date, grade: .novice) else {
            XCTFail("challenge2 should generate")
            return
        }
        
        XCTAssertEqual(challenge1.date, challenge2.date, "Dates should be equal")
        XCTAssertEqual(challenge1.startIndex, challenge2.startIndex, "Start indices should be equal (Deterministic RNG)")
        
        XCTAssertEqual(challenge1.constant, .pi)
        XCTAssertLessThanOrEqual(challenge1.startIndex, 4, "Start index \(challenge1.startIndex) should be <= 4")
    }
    
    func testPersistence_Completion() {
        let date = Date()
        XCTAssertFalse(service.isChallengeCompleted(for: date))
        
        service.markChallengeAsCompleted(for: date)
        XCTAssertTrue(service.isChallengeCompleted(for: date))
        
        // Test different day
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        XCTAssertFalse(service.isChallengeCompleted(for: tomorrow))
    }
    
    func testPiSequence_Index0() {
        let digits = Array("1415926535".utf8)
        let length = ChallengeService.calculateMUS(in: digits, at: 0)
        XCTAssertEqual(length, 2, "MUS for '1' at 0 in '1415926535' should be 2 ('14')")
    }
    
    func testPerformance_CalculateMUS() {
        // 10k digits
        var digits: [UInt8] = []
        for _ in 0..<10000 {
            digits.append(UInt8(48 + Int.random(in: 0...9))) // ASCII 0-9
        }
        
        // Measure
        self.measure {
            _ = ChallengeService.calculateMUS(in: digits, at: 0)
        }
    }
    
    func testGenerateRandomChallenge_Variation() async {
        // Setup a provider with enough data
        provider = ChallengeMockDigitsProvider(digits: "141592653589793238462643383279") // 30 digits
        
        // Re-init service
        guard let testProvider = provider else {
            XCTFail("Provider nil")
            return
        }
        service = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in testProvider }
        )
        
        // We expect different challenges if we call it multiple times, unlike Daily
        let grade: Grade = .novice
        persistence.saveHighestIndex(20, for: Constant.pi.id)
        
        let challenge1 = await service.generateRandomChallenge(for: .pi, grade: grade)
        let challenge2 = await service.generateRandomChallenge(for: .pi, grade: grade)
        
        XCTAssertNotNil(challenge1)
        XCTAssertNotNil(challenge2)
        
        // Check IDs are unique (random generation)
        XCTAssertNotEqual(challenge1?.id, challenge2?.id)
        
        // Check date is recent (created now)
        XCTAssertLessThan(abs(challenge1!.date.timeIntervalSinceNow), 5.0)
    }

    func testChallengeGenerationRespectsScope() async {
        // Setup: highestIndex = 10. Challenge length for novice = 3.
        // If startIndex is 9, expected digits would be at 10, 11, 12, which is out of scope.
        persistence.saveHighestIndex(10, for: Constant.pi.id)
        provider = ChallengeMockDigitsProvider(digits: "141592653589793238462643383279") // 30 digits
        
        service = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in self.provider }
        )
        
        for _ in 0..<50 {
            guard let challenge = await service.generateRandomChallenge(for: .pi, grade: .novice) else {
                continue // Some might fail if MUS is hard to find, but we care about those that SUCCEED
            }
            
            let totalReached = challenge.startIndex + challenge.referenceSequence.count + challenge.expectedNextDigits.count
            XCTAssertLessThanOrEqual(totalReached, 10, "Challenge reached index \(totalReached) but highestIndex is 10. StartIndex: \(challenge.startIndex), Prompt: \(challenge.referenceSequence), Expected: \(challenge.expectedNextDigits)")
        }
    }
    
    // Story 15.1: CR-1 — Verify empty sequence doesn't crash
    func testIsUnique_EmptySequence_DoesNotCrash() {
        let digits: [UInt8] = Array("1234567890".utf8)
        // calculateMUS starts with length=1 so this should never happen in normal flow,
        // but the guard ensures defensive safety
        let result = ChallengeService.calculateMUS(in: digits, at: digits.count)
        // At position == count, pos + length > count immediately, returns -1
        XCTAssertEqual(result, -1)
    }
}

// MARK: - Challenge Hub ViewModel Tests

@MainActor
final class ChallengeHubViewModelTests: XCTestCase {
    var vm: ChallengeHubViewModel!
    var persistence: ChallengeMockPersistence!
    var provider: ChallengeMockDigitsProvider!
    var service: ChallengeService!
    
    override func setUp() async throws {
        try await super.setUp()
        persistence = ChallengeMockPersistence()
        provider = ChallengeMockDigitsProvider(digits: "141592653589793238462643383279") // 30 digits
        persistence.saveHighestIndex(15, for: Constant.pi.id)
        
        service = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in self.provider }
        )
        
        vm = ChallengeHubViewModel(service: service)
    }
    
    func testTrainNow_GeneratesChallenge() async {
        // Ensure initial state
        XCTAssertNil(vm.presentedChallenge)
        
        // Act
        await vm.trainNow()
        
        // Assert
        XCTAssertNotNil(vm.presentedChallenge, "Presented challenge should be populated")
        XCTAssertNotNil(vm.presentedChallenge?.date, "Should have a valid date")
        
        // Verify it's not marked as completed automatically
        XCTAssertFalse(service.isChallengeCompleted(for: Date()), "Random challenge should not affect daily completion status")
    }
}
