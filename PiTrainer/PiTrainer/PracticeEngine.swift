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

/// Protocol defining persistence operations for practice sessions.
protocol PracticePersistenceProtocol {
    /// Saves the highest index reached in a practice session for a specific constant.
    /// - Parameters:
    ///   - index: The 0-based index of the digit.
    ///   - constantKey: The identifier for the constant (e.g., "pi").
    func saveHighestIndex(_ index: Int, for constantKey: String)
    
    /// Retrieves the highest index reached for a specific constant.
    /// - Parameter constantKey: The identifier for the constant.
    /// - Returns: The 0-based index, or 0 if none saved.
    func getHighestIndex(for constantKey: String) -> Int
}

/// Concrete implementation of PracticePersistence using UserDefaults.
class PracticePersistence: PracticePersistenceProtocol {
    private let userDefaults: UserDefaults
    private let keyPrefix = "practice_highest_index_"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    private func key(for constant: String) -> String {
        return keyPrefix + constant
    }
    
    func saveHighestIndex(_ index: Int, for constantKey: String) {
        let storageKey = key(for: constantKey)
        let currentHigh = getHighestIndex(for: constantKey)
        if index > currentHigh {
            userDefaults.set(index, forKey: storageKey)
        }
    }
    
    func getHighestIndex(for constantKey: String) -> Int {
        return userDefaults.integer(forKey: key(for: constantKey))
    }
}

/// Core practice engine for Pi digit training
struct PracticeEngine {
    
    // MARK: - Types
    
    /// Practice mode
    enum Mode: String, Codable {
        case strict   // Wrong digit ends the session immediately
        case learning // Wrong digit reveals answer and advances
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
    
    private var digitsProvider: any DigitsProvider
    private let persistence: PracticePersistenceProtocol
    
    // Session state
    private(set) var currentIndex: Int = 0
    private(set) var attempts: Int = 0
    private(set) var errors: Int = 0
    private(set) var currentStreak: Int = 0
    private(set) var bestStreak: Int = 0
    private(set) var isActive: Bool = false
    private(set) var mode: Mode = .strict
    
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
    
    init(provider: any DigitsProvider, persistence: PracticePersistenceProtocol = PracticePersistence()) {
        self.digitsProvider = provider
        self.persistence = persistence
    }
    
    // MARK: - Public Methods
    
    /// Starts a new practice session
    /// - Parameter mode: The practice mode (strict or learning)
    mutating func start(mode: Mode) throws {
        self.mode = mode
        self.isActive = true
        self.currentIndex = 0
        self.attempts = 0
        self.errors = 0
        self.currentStreak = 0
        self.bestStreak = 0
        self.startTime = Date()
        self.elapsedTimeInternal = 0
        
        // Ensure digits are loaded - propagate error if fails
        try digitsProvider.loadDigits()
    }
    
    /// Processes a digit input
    /// - Parameter digit: The digit entered by the user (0-9)
    /// - Returns: InputResult with details about the input
    mutating func input(digit: Int) -> InputResult {
        guard isActive else {
            // If not active, return current state without changes
            let expected = digitsProvider.getDigit(at: currentIndex) ?? 0
            return InputResult(
                validationResult: .incorrect(expected: expected, actual: digit),
                expectedDigit: expected,
                indexAdvanced: false,
                currentIndex: currentIndex
            )
        }
        
        // Get expected digit
        guard let expectedDigit = digitsProvider.getDigit(at: currentIndex) else {
            // Reached end of available digits
            isActive = false
            pauseTimer()
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
            
            // Persist progress (assuming Pi for now as default, needs context in future)
            // Ideally Constant enum should be passed, but sticking to simple string generic for now
            // FIXME: Pass actual constant key. defaulting to 'pi' for MVP of Story 1.4
            persistence.saveHighestIndex(currentIndex, for: "pi")
            
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
                isActive = false
                pauseTimer()
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
    mutating func backspace() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }
    
    /// Resets all state and statistics
    mutating func reset() {
        pauseTimer()
        isActive = false
        currentIndex = 0
        attempts = 0
        errors = 0
        currentStreak = 0
        bestStreak = 0
        startTime = nil
        elapsedTimeInternal = 0
    }
    
    // MARK: - Private Methods
    
    private mutating func pauseTimer() {
        guard let start = startTime else { return }
        elapsedTimeInternal += Date().timeIntervalSince(start)
        startTime = nil
    }
}
