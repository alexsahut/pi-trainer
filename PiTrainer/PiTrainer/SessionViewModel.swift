//
//  SessionViewModel.swift
//  PiTrainer
//
//  Created by Alexandre SAHUT on 11/01/2026.
//

import Foundation
import SwiftUI
import Combine

/// Manages the state and logic for a Pi practice session
class SessionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var engine: PracticeEngine
    @Published private(set) var typedDigits: String = ""
    @Published private(set) var showErrorFlash: Bool = false
    @Published private(set) var lastCorrectDigit: Int?
    @Published private(set) var expectedDigit: Int? // For learning mode feedback
    
    // UI selection state
    @Published var selectedMode: PracticeEngine.Mode = .strict
    
    // MARK: - Properties
    
    private let statsStore: StatsStore
    private var hapticFeedback = UINotificationFeedbackGenerator()
    
    // MARK: - Derived Properties
    
    var isActive: Bool { engine.isActive }
    var currentIndex: Int { engine.currentIndex }
    var attempts: Int { engine.attempts }
    var errors: Int { engine.errors }
    var bestStreak: Int { engine.bestStreak }
    
    var keypadLayout: KeypadLayout {
        statsStore.keypadLayout
    }
    
    var displayString: String {
        return "3." + typedDigits
    }
    
    // MARK: - Initialization
    
    init(statsStore: StatsStore, engine: PracticeEngine = PracticeEngine()) {
        self.statsStore = statsStore
        self.engine = engine
    }
    
    // MARK: - Public Methods
    
    /// Starts a new session with the selected mode
    func startSession() {
        engine.start(mode: selectedMode)
        typedDigits = ""
        showErrorFlash = false
        lastCorrectDigit = nil
        expectedDigit = nil
    }
    
    /// Processes a digit input from the keypad
    /// - Parameter digit: The digit (0-9)
    func processInput(_ digit: Int) {
        let result = engine.input(digit: digit)
        
        if result.isCorrect {
            // Success feedback
            lastCorrectDigit = digit
            expectedDigit = nil
            
            // Update displayed digits
            typedDigits.append(String(digit))
            
            // Light haptic for success (optional, can be subtle)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        } else {
            // Error feedback
            expectedDigit = result.expectedDigit
            hapticFeedback.notificationOccurred(.error)
            
            withAnimation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
                showErrorFlash = true
            }
            
            // Reset flash after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.showErrorFlash = false
            }
            
            if engine.mode == .learning {
                // In learning mode, we still advance
                typedDigits.append(String(result.expectedDigit))
            }
        }
    }
    
    /// Goes back one digit
    func backspace() {
        engine.backspace()
        if !typedDigits.isEmpty {
            typedDigits.removeLast()
        }
    }
    
    /// Resets the current session
    func reset() {
        engine = PracticeEngine() // Re-initialize to clear all state
        typedDigits = ""
        showErrorFlash = false
        lastCorrectDigit = nil
        expectedDigit = nil
    }
    
    /// Ends the session and saves stats
    func endSession() {
        if engine.isActive {
            let snapshot = SessionSnapshot(
                attempts: engine.attempts,
                errors: engine.errors,
                bestStreak: engine.bestStreak,
                elapsedTime: engine.elapsedTime,
                digitsPerMinute: engine.digitsPerMinute,
                date: Date()
            )
            statsStore.saveSession(snapshot)
            engine.reset()
        }
    }
}
