import XCTest
@testable import PiTrainer

@MainActor
class ChallengeViewModelTests: XCTestCase {

    var viewModel: ChallengeViewModel!
    var mockChallenge: Challenge!

    override func setUp() {
        super.setUp()
        let constant = Constant.pi
        mockChallenge = Challenge(
            id: UUID(),
            date: Date(),
            constant: constant,
            startIndex: 0,
            referenceSequence: "3.",
            expectedNextDigits: "14159",
            revealPool: "1415926535"
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
        XCTAssertFalse(viewModel.isInGuessingMode)
        XCTAssertEqual(viewModel.guessingInput, "")
        XCTAssertFalse(viewModel.isSuccessfulCompletion)
    }

    // MARK: - Story 17.2: Progressive Reveal

    func testRevealNextDigit_IncrementsCount() {
        // setUp challenge has revealPool: "1415926535" (10 digits)
        XCTAssertEqual(viewModel.revealedCount, 0)
        viewModel.revealNextDigit()
        XCTAssertEqual(viewModel.revealedCount, 1)
        viewModel.revealNextDigit()
        XCTAssertEqual(viewModel.revealedCount, 2)
    }

    func testRevealNextDigit_DoesNotExceedPoolCount() {
        // revealPool has 10 digits
        for _ in 0..<20 {
            viewModel.revealNextDigit()
        }
        XCTAssertEqual(viewModel.revealedCount, 10, "revealedCount should not exceed revealPool.count")
    }

    func testCanReveal_TrueWhenPoolNotExhausted() {
        XCTAssertTrue(viewModel.canReveal)

        // Exhaust the pool (10 digits)
        for _ in 0..<10 {
            viewModel.revealNextDigit()
        }
        XCTAssertFalse(viewModel.canReveal, "canReveal should be false when pool is exhausted")
    }

    func testVisibleDigits_ContainsMUSPlusRevealed() {
        // MUS = "3.", revealPool = "1415926535"
        XCTAssertEqual(viewModel.visibleDigits, "3.")

        viewModel.revealNextDigit()
        XCTAssertEqual(viewModel.visibleDigits, "3.1")

        viewModel.revealNextDigit()
        XCTAssertEqual(viewModel.visibleDigits, "3.14")

        viewModel.revealNextDigit()
        XCTAssertEqual(viewModel.visibleDigits, "3.141")
    }

    func testRevealDigits_BulkReveal() {
        viewModel.revealDigits(count: 5)
        XCTAssertEqual(viewModel.revealedCount, 5)
        XCTAssertEqual(viewModel.visibleDigits, "3.14159")
    }

    func testRevealDigits_ClampsToPoolSize() {
        viewModel.revealDigits(count: 100)
        XCTAssertEqual(viewModel.revealedCount, 10, "Should clamp to revealPool.count (10)")
        XCTAssertEqual(viewModel.visibleDigits, "3.1415926535")
    }

    func testRevealDigits_EmptyPool() {
        // Test the boundary: reveal all then try more
        viewModel.revealDigits(count: 10) // Exhaust pool
        XCTAssertFalse(viewModel.canReveal)
        let countBefore = viewModel.revealedCount
        viewModel.revealNextDigit() // Should be no-op
        XCTAssertEqual(viewModel.revealedCount, countBefore)
    }

    func testHintCounterLabel() {
        XCTAssertEqual(viewModel.hintCount, 0)
        viewModel.revealNextDigit()
        XCTAssertEqual(viewModel.hintCount, 1)
        viewModel.revealDigits(count: 3)
        XCTAssertEqual(viewModel.hintCount, 4)
    }

    // MARK: - Story 17.3: Guessing Mode

    func testActivateGuessingMode_SetsFlag() {
        XCTAssertFalse(viewModel.isInGuessingMode)
        viewModel.activateGuessingMode()
        XCTAssertTrue(viewModel.isInGuessingMode)
    }

    func testActivateGuessingMode_IdempotentWhenAlreadyActive() {
        viewModel.activateGuessingMode()
        viewModel.revealNextDigit() // This should now fail silently since mode is guessing
        viewModel.activateGuessingMode() // Should not crash or reset state
        XCTAssertTrue(viewModel.isInGuessingMode)
    }

    func testActivateGuessingMode_BlockedWhenPoolExhausted() {
        // Reveal all 10 digits — pool is now exhausted
        viewModel.revealDigits(count: 10)
        XCTAssertFalse(viewModel.canReveal)

        // activateGuessingMode should be a no-op when pool is fully revealed
        viewModel.activateGuessingMode()
        XCTAssertFalse(viewModel.isInGuessingMode, "Guessing mode cannot be activated when pool is exhausted")
    }

    func testHandleInput_NoOpInRevealPhase() {
        // In reveal phase, handleInput is ignored — no state change
        viewModel.handleInput(1)
        XCTAssertEqual(viewModel.guessingInput, "")
        XCTAssertFalse(viewModel.isCompleted)
        XCTAssertEqual(viewModel.correctGuessCount, 0)
    }

    func testGuessing_CorrectInputExtendsGuessingInput() {
        // revealPool = "1415926535", revealedCount = 0
        // First expected digit = revealPool[0] = "1"
        viewModel.activateGuessingMode()
        viewModel.handleInput(1)
        XCTAssertEqual(viewModel.guessingInput, "1")
        XCTAssertEqual(viewModel.correctGuessCount, 1)
        XCTAssertFalse(viewModel.isCompleted)

        // Second expected digit = revealPool[1] = "4"
        viewModel.handleInput(4)
        XCTAssertEqual(viewModel.guessingInput, "14")
        XCTAssertEqual(viewModel.correctGuessCount, 2)
    }

    func testGuessing_IncorrectInput_EndsSession() {
        // revealPool[0] = "1", typing "5" is wrong
        viewModel.activateGuessingMode()
        viewModel.handleInput(5)  // Wrong digit

        XCTAssertTrue(viewModel.isCompleted)
        XCTAssertFalse(viewModel.isSuccessfulCompletion)
        XCTAssertTrue(viewModel.isErrorShakeActive)
        XCTAssertTrue(viewModel.isShowingRecovery, "Recovery button should appear after wrong guess in guessing mode")
        XCTAssertEqual(viewModel.guessingInput, "", "No digit should be added on error")
    }

    func testGuessing_StartsAfterRevealedDigits() {
        // Reveal 3 digits: "141" from revealPool
        viewModel.revealDigits(count: 3)
        XCTAssertEqual(viewModel.revealedCount, 3)

        viewModel.activateGuessingMode()

        // Guessing should start at revealPool[3] = "5"
        viewModel.handleInput(5)  // Correct (revealPool[3] = "5")
        XCTAssertEqual(viewModel.guessingInput, "5")
        XCTAssertEqual(viewModel.correctGuessCount, 1)

        // Next should be revealPool[4] = "9"
        viewModel.handleInput(1)  // Wrong
        XCTAssertTrue(viewModel.isCompleted)
        XCTAssertFalse(viewModel.isSuccessfulCompletion)
    }

    func testGuessing_CorrectGuessCountMatchesInput() {
        viewModel.activateGuessingMode()

        // revealPool = "1415926535"
        viewModel.handleInput(1)  // "1" ✓
        viewModel.handleInput(4)  // "4" ✓
        viewModel.handleInput(1)  // "1" ✓

        XCTAssertEqual(viewModel.correctGuessCount, 3)
        XCTAssertEqual(viewModel.guessingInput, "141")
    }

    func testGuessing_Backspace_RemovesLastGuessingDigit() {
        viewModel.activateGuessingMode()
        viewModel.handleInput(1)  // "1" ✓
        viewModel.handleInput(4)  // "4" ✓
        XCTAssertEqual(viewModel.guessingInput, "14")

        viewModel.handleBackspace()
        XCTAssertEqual(viewModel.guessingInput, "1")
        XCTAssertEqual(viewModel.correctGuessCount, 1)
    }

    func testGuessing_Backspace_NoOpWhenEmpty() {
        viewModel.activateGuessingMode()
        // guessingInput is empty — backspace is a no-op
        viewModel.handleBackspace()
        XCTAssertEqual(viewModel.guessingInput, "")
        XCTAssertFalse(viewModel.isCompleted)
    }

    func testGuessing_SuccessWhenPoolExhausted() {
        // revealPool = "1415926535" (10 digits), revealedCount = 0
        // Guessing all 10 digits correctly → success
        viewModel.activateGuessingMode()
        let poolDigits = [1, 4, 1, 5, 9, 2, 6, 5, 3, 5]
        for digit in poolDigits {
            viewModel.handleInput(digit)
        }

        XCTAssertTrue(viewModel.isCompleted)
        XCTAssertTrue(viewModel.isSuccessfulCompletion)
        XCTAssertEqual(viewModel.correctGuessCount, 10)
    }

    func testGuessing_NoFurtherInputAfterCompletion() {
        viewModel.activateGuessingMode()
        viewModel.handleInput(5)  // Wrong — session ends
        XCTAssertTrue(viewModel.isCompleted)

        // Further input should be no-op
        let countBefore = viewModel.guessingInput.count
        viewModel.handleInput(1)
        XCTAssertEqual(viewModel.guessingInput.count, countBefore)
    }

    // MARK: - Story 17.4: computedScore

    func testComputedScore_AllCorrectNoHints() {
        // revealedCount = 0, type all 10 correctly → correctGuessCount = 10
        viewModel.activateGuessingMode()
        let poolDigits = [1, 4, 1, 5, 9, 2, 6, 5, 3, 5]
        for digit in poolDigits {
            viewModel.handleInput(digit)
        }
        XCTAssertEqual(viewModel.correctGuessCount, 10)
        XCTAssertEqual(viewModel.revealedCount, 0)
        XCTAssertEqual(viewModel.computedScore, 100)  // 10×10 - 0×5 = 100
    }

    func testComputedScore_WithHints() {
        // Reveal 3 hints → revealedCount = 3, then guess 3 more correctly
        viewModel.revealDigits(count: 3)
        viewModel.activateGuessingMode()
        // revealPool[3] = "5", [4] = "9", [5] = "2"
        viewModel.handleInput(5)  // correct
        viewModel.handleInput(9)  // correct
        viewModel.handleInput(2)  // correct
        XCTAssertEqual(viewModel.correctGuessCount, 3)
        XCTAssertEqual(viewModel.revealedCount, 3)
        XCTAssertEqual(viewModel.computedScore, 15)  // 3×10 - 3×5 = 30-15 = 15
    }

    func testComputedScore_CanBeNegative() {
        // Reveal 5 hints, then error immediately → correctGuessCount = 0
        viewModel.revealDigits(count: 5)
        viewModel.activateGuessingMode()
        viewModel.handleInput(9)  // Wrong: revealPool[5] = "2" → error
        XCTAssertEqual(viewModel.correctGuessCount, 0)
        XCTAssertEqual(viewModel.revealedCount, 5)
        XCTAssertEqual(viewModel.computedScore, -25)  // 0×10 - 5×5 = -25
    }

    // MARK: - Story 17.6: reset() Tests

    func testReset_ClearsAllState() {
        // Enter guessing mode with some state
        viewModel.revealDigits(count: 2)
        viewModel.activateGuessingMode()
        viewModel.handleInput(1) // correct: revealPool[2] = "1"
        XCTAssertTrue(viewModel.isInGuessingMode)
        XCTAssertEqual(viewModel.guessingInput, "1")

        viewModel.reset()

        XCTAssertFalse(viewModel.isInGuessingMode)
        XCTAssertEqual(viewModel.guessingInput, "")
        XCTAssertEqual(viewModel.currentInput, "")
        XCTAssertFalse(viewModel.isErrorShakeActive)
        XCTAssertFalse(viewModel.isShowingRecovery)
        XCTAssertFalse(viewModel.isSuccessfulCompletion)
        // Note: revealedCount is intentionally NOT reset
        XCTAssertEqual(viewModel.revealedCount, 2)
    }

    func testReset_BlockedWhenCompleted() {
        // Complete the session via error
        viewModel.activateGuessingMode()
        viewModel.handleInput(5) // Wrong → isCompleted = true
        XCTAssertTrue(viewModel.isCompleted)
        XCTAssertTrue(viewModel.isErrorShakeActive)

        // reset() should be no-op
        viewModel.reset()

        XCTAssertTrue(viewModel.isCompleted)
        XCTAssertTrue(viewModel.isErrorShakeActive)
        XCTAssertTrue(viewModel.isShowingRecovery)
    }

    // MARK: - Story 17.6: triggerRecovery() Tests

    func testTriggerRecovery_InGuessingMode_SetsShouldNavigateToPractice() {
        viewModel.revealDigits(count: 3)
        viewModel.activateGuessingMode()
        viewModel.handleInput(5) // correct: revealPool[3] = "5"
        viewModel.handleInput(1) // wrong: revealPool[4] = "9" → error, isCompleted
        XCTAssertTrue(viewModel.isCompleted)

        viewModel.triggerRecovery()

        XCTAssertTrue(viewModel.shouldNavigateToPractice)
    }

    func testTriggerRecovery_InRevealMode_SetsShouldNavigateToPractice() {
        // In reveal mode (not guessing), triggerRecovery uses currentInput.count
        // Set non-empty currentInput to exercise the UsesCurrentInputCount path
        viewModel.currentInput = "314"
        XCTAssertFalse(viewModel.isInGuessingMode)

        viewModel.triggerRecovery()

        XCTAssertTrue(viewModel.shouldNavigateToPractice)
    }

    // MARK: - Story 17.6: revealNextDigit in guessing mode

    func testRevealNextDigit_InGuessingMode_StillIncrements() {
        // Document current behavior: revealNextDigit() has no guard against guessing mode
        viewModel.activateGuessingMode()
        XCTAssertEqual(viewModel.revealedCount, 0)

        viewModel.revealNextDigit()

        // The code increments revealedCount even during guessing — no guard exists.
        // This is a latent behavioral concern but the UI hides the reveal button in guessing mode.
        XCTAssertEqual(viewModel.revealedCount, 1, "revealNextDigit has no isInGuessingMode guard — documents current behavior")
    }

    // MARK: - Story 17.6: handleBackspace in non-guessing mode

    func testHandleBackspace_InRevealPhase_ClearsErrorFlags() {
        // In non-guessing mode, backspace clears isErrorShakeActive and isShowingRecovery
        // To test: we need currentInput to be non-empty.
        // Since handleInput is a no-op in reveal phase, we directly set currentInput via the property.
        // However currentInput is a var so we can modify it for test purposes.
        viewModel.currentInput = "1"
        viewModel.isErrorShakeActive = true
        viewModel.isShowingRecovery = true

        viewModel.handleBackspace()

        XCTAssertEqual(viewModel.currentInput, "")
        XCTAssertFalse(viewModel.isErrorShakeActive)
        XCTAssertFalse(viewModel.isShowingRecovery)
    }

    func testHandleBackspace_WhenCompleted_InGuessingMode_IsNoOp() {
        viewModel.activateGuessingMode()
        viewModel.handleInput(1) // correct
        viewModel.handleInput(5) // wrong → isCompleted
        XCTAssertTrue(viewModel.isCompleted)

        viewModel.handleBackspace()

        // No change — guard prevents backspace after completion
        XCTAssertEqual(viewModel.guessingInput, "1")
    }

    // MARK: - Story 17.6: activateGuessingMode when completed

    func testActivateGuessingMode_BlockedWhenCompleted() {
        viewModel.activateGuessingMode()
        viewModel.handleInput(5) // wrong → isCompleted
        XCTAssertTrue(viewModel.isCompleted)

        // Force isInGuessingMode = false to isolate the isCompleted guard
        viewModel.isInGuessingMode = false
        XCTAssertFalse(viewModel.isInGuessingMode)

        viewModel.activateGuessingMode()

        XCTAssertFalse(viewModel.isInGuessingMode, "activateGuessingMode should be blocked by isCompleted guard")
    }
}
