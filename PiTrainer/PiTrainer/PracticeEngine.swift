//
//  PracticeEngine.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 10/01/2026.
//

import Foundation

/// Core practice engine for Pi digit training
struct PracticeEngine {
    
    // MARK: - Types
    
    /// Practice mode
    /// Practice mode
    enum Mode: String, Codable {
        case strict   // Wrong digit does not advance; user must retry
        case learning // Wrong digit reveals answer and advances
    }
    
    /// Result of a digit input
    struct InputResult {
        let isCorrect: Bool
        let expectedDigit: Int
        let indexAdvanced: Bool
        let currentIndex: Int
    }
    
    // MARK: - Properties
    
    // MARK: - Properties
    
    private var digitsProvider: any DigitsProvider
    
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
    
    init(provider: any DigitsProvider) {
        self.digitsProvider = provider
    }
    
    // MARK: - Public Methods
    
    /// Starts a new practice session
    /// - Parameter mode: The practice mode (strict or learning)
    mutating func start(mode: Mode) {
        self.mode = mode
        self.isActive = true
        self.currentIndex = 0
        self.attempts = 0
        self.errors = 0
        self.currentStreak = 0
        self.bestStreak = 0
        self.startTime = Date()
        self.elapsedTimeInternal = 0
        
        // Ensure digits are loaded
        try? digitsProvider.loadDigits()
    }
    
    /// Processes a digit input
    /// - Parameter digit: The digit entered by the user (0-9)
    /// - Returns: InputResult with details about the input
    mutating func input(digit: Int) -> InputResult {
        guard isActive else {
            // If not active, return current state without changes
            let expected = digitsProvider.getDigit(at: currentIndex) ?? 0
            return InputResult(
                isCorrect: false,
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
                isCorrect: false,
                expectedDigit: 0,
                indexAdvanced: false,
                currentIndex: currentIndex
            )
        }
        
        // Increment attempts
        attempts += 1
        
        // Check if input is correct
        let isCorrect = digit == expectedDigit
        var indexAdvanced = false
        
        if isCorrect {
            // Correct input
            currentStreak += 1
            if currentStreak > bestStreak {
                bestStreak = currentStreak
            }
            currentIndex += 1
            indexAdvanced = true
        } else {
            // Incorrect input
            errors += 1
            currentStreak = 0
            
            // Mode-specific behavior
            switch mode {
            case .strict:
                // Do NOT advance index; user must retry
                indexAdvanced = false
                
            case .learning:
                // Reveal answer and advance to keep flow
                currentIndex += 1
                indexAdvanced = true
            }
        }
        
        return InputResult(
            isCorrect: isCorrect,
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
