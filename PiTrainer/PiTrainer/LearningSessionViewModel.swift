//
//  LearningSessionViewModel.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 12/01/2026.
//

import Foundation
import Combine
import SwiftUI

/// Manages an active learning session
class LearningSessionViewModel: ObservableObject {
    
    // MARK: - Types
    
    enum SessionPhase {
        case overview      // Today's plan
        case encoding      // Showing new chunk digits
        case testing       // Active recall input
        case feedback      // Rating the recall (Again/Hard/Good/Easy)
        case summary       // Session complete
    }
    
    struct SessionItem: Identifiable, Equatable {
        let chunk: ChunkProgress
        let digits: String // The actual digits to learn
        
        var id: Int { chunk.chunkIndex }
    }
    
    // MARK: - Published Properties
    
    @Published private(set) var phase: SessionPhase = .overview
    @Published private(set) var currentItem: SessionItem?
    @Published private(set) var currentInput: String = ""
    @Published private(set) var sessionQueue: [SessionItem] = []
    
    // Feedback/UI flags
    @Published var showErrorFlash: Bool = false
    @Published var revealedDigits: String? // If user fails 2nd time or asks
    @Published var allowedRatings: [RecallRating] = RecallRating.allCases
    
    // Session Stats
    @Published var itemsReviewedCount: Int = 0
    
    // MARK: - Private Properties
    
    private let learningStore: LearningStore
    private let constant: Constant
    private var digitsProvider: FileDigitsProvider
    private var cancellables = Set<AnyCancellable>()
    
    // Testing logic
    private var hintsUsed: Int = 0
    private var errorsCount: Int = 0
    
    // MARK: - Initialization
    
    init(learningStore: LearningStore, constant: Constant) {
        self.learningStore = learningStore
        self.constant = constant
        // Reuse existing provider logic, but we need random access by index range
        self.digitsProvider = FileDigitsProvider(constant: constant)
        
        prepareSession()
    }
    
    // MARK: - Flow Control
    
    /// Prepares the session queue based on due items and new quota
    private func prepareSession() {
        let state = learningStore.state(for: constant)
        try? digitsProvider.loadDigits() // Ensure loaded
        
        // 1. Due items
        let dueChunks = learningStore.dueChunks(for: constant, limit: state.dailyReviewLimit)
        
        // 2. New items (fill remaining quota if needed, or just add dailyNewChunks based on user pref)
        // For V1, simplest: always add dailyNewChunks ? Or fill up to a session limit?
        // Requirement: "Aujourd’hui affiche: Révisions dues (...) Nouveaux chunks (si pas assez de dues)"
        // Let's implement: Max session items = dailyReviewLimit.
        // If due < 10, add new until 10? Or explicitly add N new.
        // Let's stick to: Due items + state.dailyNewChunks
        
        let newChunks = learningStore.newChunksToLearn(for: constant, count: state.dailyNewChunks)
        
        let allChunks = dueChunks + newChunks
        
        self.sessionQueue = allChunks.compactMap { chunk -> SessionItem? in
            let start = chunk.chunkIndex * state.chunkSize
            let length = state.chunkSize
            // Get digits string
            // digitsProvider gives 1-by-1. Need a helper or loop.
            var digits = ""
            for i in 0..<length {
                if let d = digitsProvider.getDigit(at: start + i) {
                    digits += String(d)
                } else {
                    return nil // Out of digits
                }
            }
            return SessionItem(chunk: chunk, digits: digits)
        }
        
        self.phase = .overview
    }
    
    func startSession() {
        nextItem()
    }
    
    private func nextItem() {
        guard !sessionQueue.isEmpty else {
            phase = .summary
            currentItem = nil
            return
        }
        
        let item = sessionQueue.removeFirst()
        self.currentItem = item
        self.currentInput = ""
        self.hintsUsed = 0
        self.errorsCount = 0
        self.revealedDigits = nil
        self.allowedRatings = RecallRating.allCases
        
        if item.chunk.state == .new {
            phase = .encoding
        } else {
            phase = .testing
        }
    }
    
    // MARK: - Interaction
    
    func encodingDone() {
        phase = .testing
    }
    
    func processDigitInput(_ digit: Int) {
        guard phase == .testing, let item = currentItem else { return }
        
        let expectedIndex = currentInput.count
        let indexInChunk = expectedIndex
        
        guard indexInChunk < item.digits.count else { return }
        
        let expectedChar = item.digits[item.digits.index(item.digits.startIndex, offsetBy: indexInChunk)]
        let expectedDigit = Int(String(expectedChar)) ?? -1
        
        if digit == expectedDigit {
            // Correct
            currentInput.append(String(digit))
            // Check formatted completeness?
            if currentInput.count == item.digits.count {
                // Done test
                finishTest()
            }
        } else {
            // Error
            handleError(digit: digit, expected: expectedDigit)
        }
    }
    
    func backspace() {
        if !currentInput.isEmpty {
            currentInput.removeLast()
        }
    }
    
    private func handleError(digit: Int, expected: Int) {
        // Haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        
        errorsCount += 1
        
        withAnimation {
            showErrorFlash = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showErrorFlash = false
        }
        
        if errorsCount == 1 {
            // Rule: 1st error => Hint (show 1 digit) + cap at Hard
            // Reveal: The prompt should show the correct next digit?
            // "surligner position + bouton Montrer 1 chiffre"
            // For simplicity V1: We flash the correct digit into the input field for a second?
            // Or just allow the user to see it.
            // Constraint says: "hint (montrer 1 chiffre)"
            // Let's implement: show hint momentarily or permanently for this attempt?
            // Let's reveal the next correct digit in the UI as a hint.
            
            // Constrain ratings
            allowedRatings = [.again, .hard]
            
        } else if errorsCount >= 2 {
            // Rule: 2nd error => Reveal chunk + Force Again
            revealedDigits = currentItem?.digits
            currentInput = currentItem?.digits ?? "" // Fill it to complete visual
            allowedRatings = [.again]
            finishTest(forcedFail: true)
        }
    }
    
    // Explicit hint button action
    func showHint() {
        guard let item = currentItem, currentInput.count < item.digits.count else { return }
        
        // This counts as an error/penalty
        if errorsCount == 0 {
            errorsCount = 1
            allowedRatings = [.again, .hard]
        }
        
        let nextIndex = currentInput.count
        let nextChar = item.digits[item.digits.index(item.digits.startIndex, offsetBy: nextIndex)]
        // Just append it? Or show it?
        // "hint" usually implies showing without typing.
        // But for flow, let's append it as if typed, but visual diff?
        // Let's just append it for simplicity in V1 logic.
        currentInput.append(nextChar)
        
        if currentInput.count == item.digits.count {
            finishTest()
        }
    }
    
    private func finishTest(forcedFail: Bool = false) {
        // Delay slightly for UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.phase = .feedback
        }
    }
    
    func submitRating(_ rating: RecallRating) {
        guard let item = currentItem else { return }
        
        // Save
        learningStore.saveReview(for: constant, chunkIndex: item.chunk.chunkIndex, rating: rating)
        
        itemsReviewedCount += 1
        
        // Should we re-queue if "Again"?
        // Constraint: "Again: interval = 0 (revoir aujourd’hui, dueDate = now + 10 min)"
        // This implies it's rescheduled for later. It doesn't necessarily mean "in this immediate session loop".
        // But typically users want to re-do it until correct in the session.
        // Let's stick to strict scheduling: it goes to DB with due date + 10min.
        // If user restarts session later, it will appear.
        // For THIS session, it's done.
        
        nextItem()
    }
}
