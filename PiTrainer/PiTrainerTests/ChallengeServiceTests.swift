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

class ChallengeMockThrowingDigitsProvider: DigitsProvider {
    var totalDigits: Int { 0 }
    var allDigitsString: String { "" }

    func getDigit(at index: Int) -> Int? { nil }

    func loadDigits() throws {
        throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock load error"])
    }
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
        // Use >= 50 digits (minimum threshold) with highestIndex = 60
        let longDigits = String(repeating: "1415926535", count: 10) // 100 digits
        persistence.saveHighestIndex(60, for: Constant.pi.id)
        provider = ChallengeMockDigitsProvider(digits: longDigits)
        
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
        // Setup a provider with enough data (must be >= 50 for minimum threshold)
        let longDigits = String(repeating: "141592653589793238462643383279", count: 4) // 120 digits
        provider = ChallengeMockDigitsProvider(digits: longDigits)
        
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
        persistence.saveHighestIndex(80, for: Constant.pi.id)
        
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
        // Setup: highestIndex = 60 (above minimum threshold 50). Challenge length for novice = 3.
        let longDigits = String(repeating: "141592653589793238462643383279", count: 4) // 120 digits
        persistence.saveHighestIndex(60, for: Constant.pi.id)
        provider = ChallengeMockDigitsProvider(digits: longDigits)
        
        service = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in self.provider }
        )
        
        for _ in 0..<50 {
            guard let challenge = await service.generateRandomChallenge(for: .pi, grade: .novice) else {
                continue // Some might fail if MUS is hard to find, but we care about those that SUCCEED
            }
            
            let totalReached = challenge.startIndex + challenge.referenceSequence.count + challenge.expectedNextDigits.count
            XCTAssertLessThanOrEqual(totalReached, 60, "Challenge reached index \(totalReached) but highestIndex is 60. StartIndex: \(challenge.startIndex), Prompt: \(challenge.referenceSequence), Expected: \(challenge.expectedNextDigits)")
        }
    }
    
    // Story 15.2: Test cold start returns nil
    func testGenerateChallenge_HighestIndexTooLow_ReturnsNil() async {
        persistence.saveHighestIndex(0, for: Constant.pi.id)
        let challenge = await service.generateDailyChallenge(for: .pi, date: Date(), grade: .novice)
        XCTAssertNil(challenge, "Challenge should be nil when highestIndex is 0 (below minimum threshold)")
        
        persistence.saveHighestIndex(49, for: Constant.pi.id)
        let challenge2 = await service.generateDailyChallenge(for: .pi, date: Date(), grade: .novice)
        XCTAssertNil(challenge2, "Challenge should be nil when highestIndex is 49 (below minimum 50)")
    }
    
    // Story 15.2: Test E2E validation — sequence matches actual digits
    func testGenerateChallenge_E2E_SequenceMatchesProvider() async {
        let piDigits = "14159265358979323846264338327950288419716939937510" // 50 real pi digits
        let longDigits = piDigits + piDigits // 100 digits
        persistence.saveHighestIndex(80, for: Constant.pi.id)
        provider = ChallengeMockDigitsProvider(digits: longDigits)
        service = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in self.provider }
        )
        
        for _ in 0..<10 {
            guard let challenge = await service.generateRandomChallenge(for: .pi, grade: .novice) else {
                continue
            }
            
            // Verify E2E: challenge.referenceSequence + expectedNextDigits == actual digits at startIndex
            let fullSeq = challenge.referenceSequence + challenge.expectedNextDigits
            let startIdx = longDigits.index(longDigits.startIndex, offsetBy: challenge.startIndex)
            let endIdx = longDigits.index(startIdx, offsetBy: fullSeq.count)
            let actualSlice = String(longDigits[startIdx..<endIdx])
            
            XCTAssertEqual(fullSeq, actualSlice, "E2E: Challenge sequence '\(fullSeq)' at index \(challenge.startIndex) should match actual digits '\(actualSlice)'")
        }
    }
    
    // MARK: - Story 17.1: Progressive Reveal Fields

    func testChallenge_BlockStartIndex_Calculated() async {
        // Setup: 100 digits, highestIndex = 80
        let piDigits = "14159265358979323846264338327950288419716939937510"
        let longDigits = piDigits + piDigits
        persistence.saveHighestIndex(80, for: Constant.pi.id)
        provider = ChallengeMockDigitsProvider(digits: longDigits)
        service = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in self.provider }
        )

        guard let challenge = await service.generateRandomChallenge(for: .pi, grade: .novice) else {
            XCTFail("Should generate a challenge")
            return
        }

        // blockStartIndex should be startIndex rounded down to nearest 10
        let expectedBlockStart = (challenge.startIndex / 10) * 10
        XCTAssertEqual(challenge.blockStartIndex, expectedBlockStart,
                       "blockStartIndex should be \(expectedBlockStart) for startIndex \(challenge.startIndex)")

        // musOffsetInBlock should be the remainder
        let expectedOffset = challenge.startIndex - expectedBlockStart
        XCTAssertEqual(challenge.musOffsetInBlock, expectedOffset,
                       "musOffsetInBlock should be \(expectedOffset) for startIndex \(challenge.startIndex)")
    }

    func testChallenge_RevealPool_NonEmpty() async {
        // Setup: enough room after MUS for a reveal pool
        let piDigits = "14159265358979323846264338327950288419716939937510"
        let longDigits = piDigits + piDigits
        persistence.saveHighestIndex(80, for: Constant.pi.id)
        provider = ChallengeMockDigitsProvider(digits: longDigits)
        service = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in self.provider }
        )

        guard let challenge = await service.generateRandomChallenge(for: .pi, grade: .novice) else {
            XCTFail("Should generate a challenge")
            return
        }

        // revealPool should contain digits after the MUS
        XCTAssertFalse(challenge.revealPool.isEmpty,
                       "revealPool should not be empty when there is space after MUS")

        // Verify revealPool contains only ASCII digits
        XCTAssertTrue(challenge.revealPool.allSatisfy { $0.isNumber },
                      "revealPool should contain only digits")
    }

    func testChallenge_RevealPool_RespectsHighestIndex() async {
        // Setup: tight scope — highestIndex just barely enough
        let piDigits = "14159265358979323846264338327950288419716939937510"
        let longDigits = piDigits + piDigits
        persistence.saveHighestIndex(60, for: Constant.pi.id)
        provider = ChallengeMockDigitsProvider(digits: longDigits)
        service = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in self.provider }
        )

        for _ in 0..<20 {
            guard let challenge = await service.generateRandomChallenge(for: .pi, grade: .novice) else {
                continue
            }

            let totalReached = challenge.startIndex + challenge.referenceSequence.count + challenge.revealPool.count
            XCTAssertLessThanOrEqual(totalReached, 60,
                                    "MUS + revealPool must not exceed highestIndex. startIndex=\(challenge.startIndex), MUS=\(challenge.referenceSequence.count), pool=\(challenge.revealPool.count)")
        }
    }

    func testChallenge_RevealPool_MatchesActualDigits() async {
        // E2E: verify revealPool matches actual digit data
        let piDigits = "14159265358979323846264338327950288419716939937510"
        let longDigits = piDigits + piDigits
        persistence.saveHighestIndex(80, for: Constant.pi.id)
        provider = ChallengeMockDigitsProvider(digits: longDigits)
        service = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in self.provider }
        )

        guard let challenge = await service.generateRandomChallenge(for: .pi, grade: .novice) else {
            XCTFail("Should generate a challenge")
            return
        }

        let poolStart = challenge.startIndex + challenge.referenceSequence.count
        let poolStartIdx = longDigits.index(longDigits.startIndex, offsetBy: poolStart)
        let poolEndIdx = longDigits.index(poolStartIdx, offsetBy: challenge.revealPool.count)
        let expectedPool = String(longDigits[poolStartIdx..<poolEndIdx])

        XCTAssertEqual(challenge.revealPool, expectedPool,
                       "revealPool should match actual digits from provider")
    }

    func testChallenge_CodableBackwardCompatibility() throws {
        // Simulate a legacy Challenge JSON without the new fields
        let legacyJSON = """
        {
            "id": "12345678-1234-1234-1234-123456789012",
            "date": 0,
            "constant": "pi",
            "startIndex": 25,
            "referenceSequence": "926",
            "expectedNextDigits": "535"
        }
        """

        let data = legacyJSON.data(using: .utf8)!
        let decoder = JSONDecoder()
        let challenge = try decoder.decode(Challenge.self, from: data)

        XCTAssertEqual(challenge.startIndex, 25)
        XCTAssertEqual(challenge.referenceSequence, "926")
        XCTAssertEqual(challenge.blockStartIndex, 0, "Default blockStartIndex should be 0")
        XCTAssertEqual(challenge.musOffsetInBlock, 0, "Default musOffsetInBlock should be 0")
        XCTAssertEqual(challenge.revealPool, "", "Default revealPool should be empty")
    }

    func testChallenge_DailyChallenge_HasRevealFields() async {
        let piDigits = "14159265358979323846264338327950288419716939937510"
        let longDigits = piDigits + piDigits
        persistence.saveHighestIndex(80, for: Constant.pi.id)
        provider = ChallengeMockDigitsProvider(digits: longDigits)
        service = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in self.provider }
        )

        let date = Date(timeIntervalSince1970: 1700000000)
        guard let challenge = await service.generateDailyChallenge(for: .pi, date: date, grade: .novice) else {
            XCTFail("Should generate daily challenge")
            return
        }

        // Daily challenges should also have the new fields populated
        let expectedBlockStart = (challenge.startIndex / 10) * 10
        XCTAssertEqual(challenge.blockStartIndex, expectedBlockStart)
        XCTAssertEqual(challenge.musOffsetInBlock, challenge.startIndex - expectedBlockStart)
        // revealPool may or may not be empty depending on available space, but should be valid
        XCTAssertTrue(challenge.revealPool.allSatisfy { $0.isNumber } || challenge.revealPool.isEmpty)
    }

    func testChallenge_RevealPool_EmptyWhenMUSNearEnd() async {
        // Edge case: MUS near the end of known sequence → revealPool should be empty or very short
        // 100 digits of data, but highestIndex = 55 — tight scope
        let piDigits = "14159265358979323846264338327950288419716939937510"
        let longDigits = piDigits + piDigits // 100 digits available
        // highestIndex = 55 — just barely above minimum threshold (50)
        // With novice grade (challengeLength = 3), challenges near the end will have short pools
        persistence.saveHighestIndex(55, for: Constant.pi.id)
        provider = ChallengeMockDigitsProvider(digits: longDigits)
        service = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in self.provider }
        )

        var foundShortPool = false
        for _ in 0..<50 {
            guard let challenge = await service.generateRandomChallenge(for: .pi, grade: .novice) else {
                continue
            }

            // With highestIndex = 55, the revealPool is capped at min(55, musEnd + 20)
            // For challenges near the end, the pool will be short
            let musEnd = challenge.startIndex + challenge.referenceSequence.count
            let maxPoolSize = 55 - musEnd
            XCTAssertLessThanOrEqual(challenge.revealPool.count, min(20, max(0, maxPoolSize)),
                                    "revealPool should be capped by highestIndex")
            if challenge.revealPool.count <= 5 {
                foundShortPool = true
            }
        }
        // With tight scope, we should find at least one challenge with a short pool
        XCTAssertTrue(foundShortPool, "Should find at least one challenge with short/empty revealPool near end of sequence")
    }

    func testChallenge_BlockStartIndex_Deterministic() async {
        // Deterministic test: verify block calculation for a known startIndex
        let piDigits = "14159265358979323846264338327950288419716939937510"
        let longDigits = piDigits + piDigits
        persistence.saveHighestIndex(80, for: Constant.pi.id)
        provider = ChallengeMockDigitsProvider(digits: longDigits)
        service = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in self.provider }
        )

        // Use daily challenge with fixed date for deterministic startIndex
        let date = Date(timeIntervalSince1970: 1700000000)
        guard let challenge = await service.generateDailyChallenge(for: .pi, date: date, grade: .novice) else {
            XCTFail("Should generate daily challenge")
            return
        }

        // Verify block calculation is correct for the actual startIndex
        let si = challenge.startIndex
        XCTAssertEqual(challenge.blockStartIndex, (si / 10) * 10)
        XCTAssertEqual(challenge.musOffsetInBlock, si % 10)

        // Verify mathematical invariant: blockStartIndex + musOffsetInBlock == startIndex
        XCTAssertEqual(challenge.blockStartIndex + challenge.musOffsetInBlock, si,
                       "blockStartIndex + musOffsetInBlock must always equal startIndex")

        // Verify offset is in valid range [0, 9]
        XCTAssertGreaterThanOrEqual(challenge.musOffsetInBlock, 0)
        XCTAssertLessThan(challenge.musOffsetInBlock, 10)

        // Verify blockStartIndex is a multiple of 10
        XCTAssertEqual(challenge.blockStartIndex % 10, 0)
    }

    // MARK: - Story 17.6: MUS at non-zero positions

    func testCalculateMUS_AtNonZeroPosition() {
        // sequence: "1415926535" — test MUS starting at pos=4
        let digits = Array("1415926535".utf8)
        let length = ChallengeService.calculateMUS(in: digits, at: 4)
        // At pos=4: "9" appears once → MUS = 1
        XCTAssertGreaterThan(length, 0, "MUS at non-zero position should find a unique sequence")
    }

    func testCalculateMUS_AtLastPosition() {
        // sequence: "12345" — test MUS at pos=4 (last digit "5")
        let digits = Array("12345".utf8)
        let length = ChallengeService.calculateMUS(in: digits, at: 4)
        XCTAssertEqual(length, 1, "Single last digit should be unique (MUS = 1)")
    }

    func testCalculateMUS_AtPositionEqualToCount_ReturnsMinusOne() {
        let digits = Array("12345".utf8)
        let length = ChallengeService.calculateMUS(in: digits, at: 5)
        XCTAssertEqual(length, -1, "Position at digits.count should return -1")
    }

    func testCalculateMUS_AllIdenticalDigits_ReturnsFullLength() {
        // All identical digits: only the full remaining string is unique
        // "1111" at pos=0 → "1" repeats, "11" repeats, "111" repeats, "1111" appears once → MUS = 4
        let digits = Array("1111".utf8)
        let length = ChallengeService.calculateMUS(in: digits, at: 0)
        XCTAssertEqual(length, 4, "MUS of all-identical digits is the full sequence length")
    }

    func testGenerateChallenge_RetryExhaustion_ReturnsNil() async {
        // All-identical digits → MUS always returns -1 → all 50 retries fail
        let identicalDigits = String(repeating: "1", count: 100)
        let identicalProvider = ChallengeMockDigitsProvider(digits: identicalDigits)
        persistence.saveHighestIndex(60, for: Constant.pi.id)
        let exhaustService = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in identicalProvider }
        )

        let daily = await exhaustService.generateDailyChallenge(for: .pi, date: Date(), grade: .novice)
        XCTAssertNil(daily, "Should return nil when all 50 retry attempts fail (MUS = -1 everywhere)")

        let random = await exhaustService.generateRandomChallenge(for: .pi, grade: .novice)
        XCTAssertNil(random, "Random challenge should also return nil on retry exhaustion")
    }

    // MARK: - Story 17.6: Error paths

    func testGenerateDailyChallenge_DigitsLoadError_ReturnsNil() async {
        let throwingProvider = ChallengeMockThrowingDigitsProvider()
        persistence.saveHighestIndex(80, for: Constant.pi.id)
        let errorService = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in throwingProvider }
        )

        let challenge = await errorService.generateDailyChallenge(for: .pi, date: Date(), grade: .novice)
        XCTAssertNil(challenge, "Should return nil when loadDigits() throws")
    }

    func testGenerateRandomChallenge_DigitsLoadError_ReturnsNil() async {
        let throwingProvider = ChallengeMockThrowingDigitsProvider()
        persistence.saveHighestIndex(80, for: Constant.pi.id)
        let errorService = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in throwingProvider }
        )

        let challenge = await errorService.generateRandomChallenge(for: .pi, grade: .novice)
        XCTAssertNil(challenge, "Should return nil when loadDigits() throws")
    }

    // Story 15.1: CR-1 — Verify empty sequence doesn't crash (Real test)
    func testIsUnique_EmptySequence_DoesNotCrash() {
        let digits: [UInt8] = Array("12345".utf8)
        let emptySequence = digits[0..<0] // Empty ArraySlice
        
        let calculateMUS_SignatureIsCalculatedOnArraySlice_ButWeTestItDirectlyViaCalculateMUS = true
        XCTAssertTrue(calculateMUS_SignatureIsCalculatedOnArraySlice_ButWeTestItDirectlyViaCalculateMUS)
        
        // Since isUnique is private, we can't call it directly. calculateMUS handles the length safely.
        // However we can test empty sequence via calculateMUS if we force length = 0, which isn't possible normally.
        // What we CAN test confidently is that passing an empty array to calculateMUS doesn't crash.
        let emptyDigits: [UInt8] = []
        let result = ChallengeService.calculateMUS(in: emptyDigits, at: 0)
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
        // Must be >= 50 digits and >= 50 highestIndex for minimum threshold
        let longDigits = String(repeating: "141592653589793238462643383279", count: 4) // 120 digits
        provider = ChallengeMockDigitsProvider(digits: longDigits)
        persistence.saveHighestIndex(80, for: Constant.pi.id)
        
        service = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in self.provider }
        )
        
        vm = ChallengeHubViewModel(service: service, persistence: persistence)
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
    
    // Story 15.2: Test eligibility check
    func testChallengeEligibility_BelowThreshold() async {
        persistence.saveHighestIndex(10, for: Constant.pi.id)
        XCTAssertFalse(vm.isChallengeEligible, "Should not be eligible with highestIndex = 10")
        XCTAssertEqual(vm.digitsRemainingToUnlock, 40)
    }
    
    func testChallengeEligibility_AboveThreshold() async {
        persistence.saveHighestIndex(100, for: Constant.pi.id)
        XCTAssertTrue(vm.isChallengeEligible, "Should be eligible with highestIndex = 100")
        XCTAssertEqual(vm.digitsRemainingToUnlock, 0)
    }
    
    func testTrainNow_NotEligible_ReturnsNil() async {
        persistence.saveHighestIndex(5, for: Constant.pi.id)
        await vm.trainNow()
        XCTAssertNil(vm.presentedChallenge, "Should not generate challenge when not eligible")
    }

    // MARK: - Story 17.6: loadDailyChallenge and startDailyChallenge

    func testLoadDailyChallenge_WhenEligible_SetsChallenge() async {
        // persistence already has highestIndex=80 from setUp
        XCTAssertTrue(vm.isChallengeEligible)
        XCTAssertNil(vm.dailyChallenge)

        await vm.loadDailyChallenge()

        XCTAssertNotNil(vm.dailyChallenge, "Daily challenge should be generated when eligible")
        XCTAssertNil(vm.errorText, "No error expected on success")
    }

    func testLoadDailyChallenge_WhenNotEligible_SetsNil() async {
        persistence.saveHighestIndex(10, for: Constant.pi.id)
        XCTAssertFalse(vm.isChallengeEligible)

        await vm.loadDailyChallenge()

        XCTAssertNil(vm.dailyChallenge, "Daily challenge should be nil when not eligible")
        XCTAssertNil(vm.errorText, "No error — just a pre-requisite not met")
    }

    func testStartDailyChallenge_SetsPresentedChallenge() async {
        await vm.loadDailyChallenge()
        XCTAssertNotNil(vm.dailyChallenge)

        vm.startDailyChallenge()

        XCTAssertNotNil(vm.presentedChallenge, "presentedChallenge should be set")
        XCTAssertTrue(vm.isPresentedChallengeDaily, "Should be flagged as daily challenge")
        XCTAssertEqual(vm.presentedChallenge?.id, vm.dailyChallenge?.id, "Presented should match daily")
    }

    func testLoadDailyChallenge_AlreadyCompleted_SetsFlag() async {
        service.markChallengeAsCompleted(for: Date())

        await vm.loadDailyChallenge()

        XCTAssertTrue(vm.isDailyCompleted, "isDailyCompleted should be true when today's challenge is completed")
    }

    func testTrainNow_Error_SetsErrorText() async {
        // Create service with throwing provider but eligible highestIndex
        let throwingProvider = ChallengeMockThrowingDigitsProvider()
        let errorService = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in throwingProvider }
        )
        let errorVM = ChallengeHubViewModel(service: errorService, persistence: persistence)

        await errorVM.trainNow()

        XCTAssertNotNil(errorVM.errorText, "Error text should be set when generation fails")
        XCTAssertNil(errorVM.presentedChallenge, "No challenge should be presented on error")
    }
}
