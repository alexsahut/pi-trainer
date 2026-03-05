import Foundation
import SwiftUI

@Observable
class ChallengeViewModel {
    let challenge: Challenge

    var currentInput: String = ""
    var isCompleted: Bool = false
    var isErrorShakeActive: Bool = false

    var isShowingRecovery: Bool = false
    var shouldNavigateToPractice: Bool = false

    // Story 17.2: Progressive reveal state
    var revealedCount: Int = 0

    var canReveal: Bool {
        revealedCount < challenge.revealPool.count
    }

    /// MUS + revealed decimals from the pool
    var visibleDigits: String {
        let revealed = String(challenge.revealPool.prefix(revealedCount))
        return challenge.referenceSequence + revealed
    }

    /// Alias for revealedCount — used by the hint counter UI
    var hintCount: Int { revealedCount }

    // Story 17.3: Guessing mode state
    var isInGuessingMode: Bool = false
    var guessingInput: String = ""
    var isSuccessfulCompletion: Bool = false

    /// Number of correctly guessed digits — for Story 17.4 scoring
    var correctGuessCount: Int { guessingInput.count }

    /// Story 17.4: score = (correctGuessCount × 10) - (revealedCount × 5)
    /// Score can be negative — intentional signal of over-reliance on hints.
    var computedScore: Int {
        correctGuessCount * 10 - revealedCount * 5
    }

    // Dependencies
    private let hapticService: HapticService
    private let statsStore: StatsStore
    private let segmentStore: SegmentStore

    // Derived properties
    var prompt: String {
        challenge.referenceSequence
    }

    var targetLength: Int {
        challenge.expectedNextDigits.count
    }

    var targetDigits: String {
        challenge.expectedNextDigits
    }

    // Story 13.2: Dependency Injection for better testability
    init(challenge: Challenge,
         hapticService: HapticService = .shared,
         statsStore: StatsStore = .shared,
         segmentStore: SegmentStore = .shared) {
        self.challenge = challenge
        self.hapticService = hapticService
        self.statsStore = statsStore
        self.segmentStore = segmentStore
    }

    // MARK: - Story 17.3: Guessing Mode

    /// Transitions from reveal phase to guessing phase.
    /// Blocked if pool is fully revealed — nothing left to guess.
    func activateGuessingMode() {
        guard !isInGuessingMode, !isCompleted else { return }
        guard revealedCount < challenge.revealPool.count else { return }
        isInGuessingMode = true
    }

    func handleInput(_ digit: Int) {
        guard !isCompleted, isInGuessingMode else { return }
        handleGuessDigit(digit)
    }

    /// Validates a guessed digit against the reveal pool at the correct offset.
    /// Offset = revealedCount (hints shown) + guessingInput.count (digits already typed).
    /// Precondition: activateGuessingMode() already verified revealedCount < pool.count.
    private func handleGuessDigit(_ digit: Int) {
        let input = String(digit)
        let poolOffset = revealedCount + guessingInput.count

        // Defensive guard: unreachable in normal flow since activateGuessingMode() blocks
        // this state, but prevents a crash if revealNextDigit() is called during guessing.
        guard poolOffset < challenge.revealPool.count else { return }

        let expectedCharIndex = challenge.revealPool.index(
            challenge.revealPool.startIndex, offsetBy: poolOffset)
        let expectedDigit = String(challenge.revealPool[expectedCharIndex])

        if input == expectedDigit {
            guessingInput += input
            // Last correct digit → celebrate; otherwise per-digit success sound
            if revealedCount + guessingInput.count >= challenge.revealPool.count {
                isCompleted = true
                isSuccessfulCompletion = true
                hapticService.playDoubleBang()
            } else {
                hapticService.playSuccess()
            }
        } else {
            // Wrong digit — end session immediately, no retry
            triggerError()
            isCompleted = true
            // isSuccessfulCompletion stays false
        }
    }

    func handleBackspace() {
        if isInGuessingMode {
            guard !isCompleted, !guessingInput.isEmpty else { return }
            guessingInput.removeLast()
        } else {
            guard !currentInput.isEmpty else { return }
            currentInput.removeLast()
            isErrorShakeActive = false
            isShowingRecovery = false
        }
    }

    func reset() {
        guard !isCompleted else { return }
        currentInput = ""
        isErrorShakeActive = false
        isShowingRecovery = false
        isInGuessingMode = false
        guessingInput = ""
        isSuccessfulCompletion = false
    }

    /// Story 14.1: Recovery Bridge - Transitions to Learn mode for the failed pattern context
    func triggerRecovery() {
        // Story 17.3: In guessing mode the fail index accounts for revealed hints + typed digits.
        // In practice mode (pre-17.3 flow) it uses currentInput.count.
        let localFailIndex: Int
        if isInGuessingMode {
            localFailIndex = revealedCount + guessingInput.count
        } else {
            localFailIndex = currentInput.count
        }
        let absoluteIndex = challenge.startIndex + challenge.referenceSequence.count + localFailIndex

        // Align to chunk
        let segmentStart = (absoluteIndex / DesignSystem.Constants.chunkSize) * DesignSystem.Constants.chunkSize
        let segmentEnd = segmentStart + DesignSystem.Constants.chunkSize

        // Update Stores
        segmentStore.segmentStart = segmentStart
        segmentStore.segmentEnd = segmentEnd
        statsStore.selectedMode = .learn

        // Trigger Navigation
        withAnimation {
            shouldNavigateToPractice = true
        }
    }

    // MARK: - Story 17.2: Progressive Reveal

    func revealNextDigit() {
        guard canReveal else { return }
        revealedCount += 1
    }

    func revealDigits(count: Int) {
        revealedCount = min(revealedCount + count, challenge.revealPool.count)
    }

    private func triggerError() {
        hapticService.playError()
        withAnimation {
            isErrorShakeActive = true
            isShowingRecovery = true // Reveal the bridge
        }
    }
}
