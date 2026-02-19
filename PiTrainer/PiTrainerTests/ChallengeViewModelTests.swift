import XCTest
@testable import PiTrainer

@MainActor
class ChallengeViewModelTests: XCTestCase {
    
    var viewModel: ChallengeViewModel!
    var mockChallenge: Challenge!
    
    override func setUp() {
        super.setUp()
        // Create a mock challenge
        // Constant: Pi, index: 0 (3.), Mus: 1415 (example)
        // referenceSequence: "3."
        // expectedNextDigits: "1415"
        
        
        let constant = Constant.pi
        mockChallenge = Challenge(
            id: UUID(),
            date: Date(),
            constant: constant,
            startIndex: 0,
            referenceSequence: "3.", // Prompt
            expectedNextDigits: "14159" // Target 5 digits
        )
        
        viewModel = ChallengeViewModel(challenge: mockChallenge)
    }
    
    override func tearDown() {
        viewModel = nil
        mockChallenge = nil
        super.tearDown()
    }
    
    func testInitialization() {
        XCTAssertEqual(viewModel.prompt, "3.")
        XCTAssertEqual(viewModel.targetLength, 5)
        XCTAssertEqual(viewModel.currentInput, "")
        XCTAssertEqual(viewModel.isCompleted, false)
        XCTAssertFalse(viewModel.isErrorShakeActive)
    }
    
    func testCorrectInput() {
        // "1"
        viewModel.handleInput(1)
        XCTAssertEqual(viewModel.currentInput, "1")
        XCTAssertFalse(viewModel.isErrorShakeActive)
        
        // "4"
        viewModel.handleInput(4)
        XCTAssertEqual(viewModel.currentInput, "14")
        
        // "1"
        viewModel.handleInput(1)
        XCTAssertEqual(viewModel.currentInput, "141")
        
        // "5"
        viewModel.handleInput(5)
        XCTAssertEqual(viewModel.currentInput, "1415")
        
        // "9" (Complete)
        viewModel.handleInput(9)
        XCTAssertEqual(viewModel.currentInput, "14159")
        XCTAssertTrue(viewModel.isCompleted)
    }
    
    func testIncorrectInput() {
        // "1" (Correct)
        viewModel.handleInput(1)
        
        // "5" (Wrong, expected 4)
        viewModel.handleInput(5)
        
        // Should trigger error state
        XCTAssertTrue(viewModel.isErrorShakeActive)
        XCTAssertTrue(viewModel.isShowingRecovery) // New Req
    }
    
    func testBackspace() {
        viewModel.handleInput(1)
        XCTAssertEqual(viewModel.currentInput, "1")
        
        viewModel.handleBackspace()
        XCTAssertEqual(viewModel.currentInput, "")
    }
    
    func testDisplayString() {
        XCTAssertEqual(viewModel.displayTarget, "_ _ _ _ _")
        
        viewModel.handleInput(1)
        XCTAssertEqual(viewModel.displayTarget, "1 _ _ _ _")
        
        viewModel.handleInput(4)
        XCTAssertEqual(viewModel.displayTarget, "1 4 _ _ _")
    }

    func testRecoveryLogic() {
        // Fail at index 1 (second digit)
        viewModel.handleInput(1)
        viewModel.handleInput(5) // Error
        
        XCTAssertTrue(viewModel.isShowingRecovery)
        
        // Trigger recovery
        viewModel.triggerRecovery()
        
        // Verify SegmentStore update
        // Current index was 1. Segment chunk size is 10.
        // So segment should be 0-10.
        // We need to access the dependency to verify.
        // Check if VM exposes it or if we check shared (assuming shared usage for now if no DI)
        XCTAssertEqual(SegmentStore.shared.segmentStart, 0)
        XCTAssertEqual(SegmentStore.shared.segmentEnd, 10)
        
        // Verify Navigation Signal
        XCTAssertTrue(viewModel.shouldNavigateToPractice)
    }
    
    func testCompletionXP() {
        // Setup initial XP
        let initialXP = StatsStore.shared.totalCorrectDigits
        
        // Complete challenge (5 digits)
        viewModel.handleInput(1)
        viewModel.handleInput(4)
        viewModel.handleInput(1)
        viewModel.handleInput(5)
        viewModel.handleInput(9)
        
        XCTAssertTrue(viewModel.isCompleted)
        
        // Requirement: XP should be credited
        // 5 digits correct = +5 XP
        XCTAssertEqual(StatsStore.shared.totalCorrectDigits, initialXP + 5)
    }
}
