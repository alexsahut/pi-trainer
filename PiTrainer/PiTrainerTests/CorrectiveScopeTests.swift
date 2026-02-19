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
        // Pi: 141592653589793238462 (index up to 20 for first 21 digits)
        provider = ChallengeMockDigitsProvider(digits: "14159265358979323846264338") 
        service = ChallengeService(
            persistence: persistence,
            digitsProviderFactory: { _ in self.provider }
        )
    }
    
    func testGenerationWithSmallPR() async {
        // User has PR 21.
        persistence.saveHighestIndex(21, for: Constant.pi.id)
        
        // Even with higher grades, we should get a challenge (clamped)
        for grade in Grade.allCases {
            print("Testing Grade: \(grade.displayName) (Default Length: \(grade.challengeLength))")
            let challenge = await service.generateRandomChallenge(for: .pi, grade: grade)
            
            XCTAssertNotNil(challenge, "Challenge should be generated for grade \(grade.displayName) even with small PR 21")
            
            if let c = challenge {
                let end = c.startIndex + c.referenceSequence.count + c.expectedNextDigits.count
                XCTAssertLessThanOrEqual(end, 21, "Challenge for \(grade.displayName) must stay within PR 21. Reached \(end)")
                XCTAssertGreaterThan(c.expectedNextDigits.count, 0, "Challenge should have at least 1 target digit")
            }
        }
    }
}
