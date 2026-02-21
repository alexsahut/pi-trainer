import XCTest
@testable import PiTrainer

@MainActor
final class CorrectiveScopeTests: XCTestCase {
    
    var persistence: ChallengeMockPersistence!
    var provider: ChallengeMockDigitsProvider!
    var service: ChallengeService!
    
    override func setUp() {
        super.setUp()
        persistence = ChallengeMockPersistence()
        // 50 real Pi digits — satisfies minimumHighestIndex threshold (Story 15.2)
        provider = ChallengeMockDigitsProvider(digits: "14159265358979323846264338327950288419716939937510")
        service = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in self.provider }
        )
    }

    // Note: "SmallPR" in the test name means "PR at minimum threshold" (50), not an arbitrarily
    // small value. The threshold of 50 was introduced in Story 15.2 as the cold-start guard.
    func testGenerationWithSmallPR() async {
        // User has PR at minimum threshold (50 — introduced by Story 15.2 cold start fix).
        // Even with higher grades, a challenge should be generated (clamped to available scope).
        persistence.saveHighestIndex(50, for: Constant.pi.id)

        for grade in Grade.allCases {
            print("Testing Grade: \(grade.displayName) (Default Length: \(grade.challengeLength))")
            let challenge = await service.generateRandomChallenge(for: .pi, grade: grade)

            XCTAssertNotNil(challenge, "Challenge should be generated for grade \(grade.displayName) even with minimum PR 50")

            if let c = challenge {
                let end = c.startIndex + c.referenceSequence.count + c.expectedNextDigits.count
                XCTAssertLessThanOrEqual(end, 50, "Challenge for \(grade.displayName) must stay within PR 50. Reached \(end)")
                XCTAssertGreaterThan(c.expectedNextDigits.count, 0, "Challenge should have at least 1 target digit")
            }
        }
    }
}
