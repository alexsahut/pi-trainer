//
//  PracticeEngine.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 10/01/2026.
//

import Foundation

/// Represents the result of a digit validation attempt.
enum ValidationResult: Equatable {
    /// The input digit matches the expected digit.
    case correct
    
    /// The input digit does not match the expected digit.
    /// - expected: The digit that was expected.
    /// - actual: The digit that was input.
    case incorrect(expected: Int, actual: Int)
}


/// Core practice engine for Pi digit training
class PracticeEngine {
    
    // MARK: - Types
    
    /// Practice mode
    enum Mode: String, Codable {
        case strict   // Wrong digit ends the session immediately
        case learning // Wrong digit reveals answer and advances
    }
    
    /// Engine State
    enum State: Equatable {
        case idle      // Initial state, nothing loaded
        case ready     // Loaded and ready to start
        case running   // Active session
        case finished  // Session ended (completed or failed)
    }
    
    /// Result of a digit input
    struct InputResult {
        let validationResult: ValidationResult
        let expectedDigit: Int
        let indexAdvanced: Bool
        let currentIndex: Int
        
        var isCorrect: Bool {
            return validationResult == .correct
        }
    }
    
    // MARK: - Properties
    
    private let constant: Constant
    private var digitsProvider: any DigitsProvider
    private let persistence: PracticePersistenceProtocol
    
    // Session state
    private(set) var currentIndex: Int = 0
    private(set) var attempts: Int = 0
    private(set) var errors: Int = 0
    private(set) var currentStreak: Int = 0
    private(set) var bestStreak: Int = 0
    
    private(set) var state: State = .idle
    private(set) var mode: Mode = .strict
    
    /// Returns true if the session is currently running (timer active)
    var isActive: Bool {
        return state == .running
    }
    
    /// Returns true if input is allowed (ready or running)
    var isReadyOrRunning: Bool {
        return state == .ready || state == .running
    }
    
    // Time tracking
    private(set) var startTime: Date?
    private var elapsedTimeInternal: TimeInterval = 0
    
    /// Total elapsed time in the current session
    var elapsedTime: TimeInterval {
        guard let start = startTime else {
            return elapsedTimeInternal
        }
        return elapsedTimeInternal + Date().timeIntervalSince(start)
    }
    
    /// Digits per minute (correct digits / elapsed minutes)
    var digitsPerMinute: Double {
        let elapsed = elapsedTime
        guard elapsed > 0 else { return 0 }
        let correctDigits = attempts - errors
        return Double(correctDigits) / (elapsed / 60.0)
    }
    
    // MARK: - Initialization
    
    init(constant: Constant, provider: any DigitsProvider, persistence: PracticePersistenceProtocol = PracticePersistence()) {
        self.constant = constant
        self.digitsProvider = provider
        self.persistence = persistence
    }
    
    // MARK: - Public Methods
    
    /// Starts a new practice session
    /// - Parameter mode: The practice mode (strict or learning)
    func start(mode: Mode) {
        self.mode = mode
        self.state = .ready // Ready to accept input, but timer hasn't started
        
        self.currentIndex = 0
        self.attempts = 0
        self.errors = 0
        self.currentStreak = 0
        self.bestStreak = 0
        self.startTime = nil // clear start time
        self.elapsedTimeInternal = 0
    }
    
    /// Processes a digit input
    /// - Parameter digit: The digit entered by the user (0-9)
    /// - Returns: InputResult with details about the input
    func input(digit: Int) -> InputResult {
        // Auto-start logic: Transition from Ready to Running on first input
        if state == .ready {
            state = .running
            startTime = Date()
        }
        
        guard state == .running else {
            // If not running (e.g. idle or finished), return current state without changes
            let expected = digitsProvider.getDigit(at: currentIndex) ?? 0
            return InputResult(
                validationResult: .incorrect(expected: expected, actual: digit),
                expectedDigit: expected,
                indexAdvanced: false,
                currentIndex: currentIndex
            )
        }
        
        guard let expectedDigit = digitsProvider.getDigit(at: currentIndex) else {
            // Reached end of available digits
            finishSession()
            return InputResult(
                validationResult: .incorrect(expected: 0, actual: digit), // Or specific error state
                expectedDigit: 0,
                indexAdvanced: false,
                currentIndex: currentIndex
            )
        }
        
        // Increment attempts
        attempts += 1
        
        // Check if input is correct
        let isCorrect = digit == expectedDigit
        let validationResult: ValidationResult
        var indexAdvanced = false
        
        if isCorrect {
            // Correct input
            validationResult = .correct
            currentStreak += 1
            if currentStreak > bestStreak {
                bestStreak = currentStreak
            }
            
            // Persist progress
            persistence.saveHighestIndex(currentIndex, for: constant.id)
            
            currentIndex += 1
            indexAdvanced = true
        } else {
            // Incorrect input
            validationResult = .incorrect(expected: expectedDigit, actual: digit)
            errors += 1
            currentStreak = 0
            
            // Mode-specific behavior
            switch mode {
            case .strict:
                // Strict Mode = Sudden Death. End session immediately.
                finishSession()
                indexAdvanced = false
                
            case .learning:
                // Reveal answer and advance to keep flow
                currentIndex += 1
                indexAdvanced = true
            }
        }
        
        return InputResult(
            validationResult: validationResult,
            expectedDigit: expectedDigit,
            indexAdvanced: indexAdvanced,
            currentIndex: currentIndex
        )
    }
    
    /// Goes back one digit (if possible)
    func backspace() {
        // Only allow backspace if running or ready (though ready implies index 0)
        guard isReadyOrRunning && currentIndex > 0 else { return }
        currentIndex -= 1
    }
    
    /// Resets all state and statistics
    func reset() {
        finishSession()
        state = .idle
        currentIndex = 0
        attempts = 0
        errors = 0
        currentStreak = 0
        bestStreak = 0
        startTime = nil
        elapsedTimeInternal = 0
    }
    
    // MARK: - Private Methods
    
    private func finishSession() {
        if state == .running {
            pauseTimer()
        }
        state = .finished
    }
    
    private func pauseTimer() {
        guard let start = startTime else { return }
        elapsedTimeInternal += Date().timeIntervalSince(start)
        startTime = nil
    }
}
