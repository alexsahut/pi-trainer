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
@MainActor
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
    private let persistence: PracticePersistenceProtocol
    private let providerFactory: (Constant) -> any DigitsProvider

    
    // MARK: - Derived Properties
    
    var isActive: Bool { engine.isActive }
    var currentIndex: Int { engine.currentIndex }
    var attempts: Int { engine.attempts }
    var errors: Int { engine.errors }
    var bestStreak: Int { engine.bestStreak }
    
    var keypadLayout: KeypadLayout {
        statsStore.keypadLayout
    }
    
    var integerPart: String {
        statsStore.selectedConstant.integerPart
    }
    
    var displayString: String {
        return statsStore.selectedConstant.integerPart + "." + typedDigits
    }
    
    var constantSymbol: String {
        return statsStore.selectedConstant.symbol
    }
    
    // MARK: - Initialization
    
    init(statsStore: StatsStore, 
         persistence: PracticePersistenceProtocol = PracticePersistence(),
         providerFactory: @escaping (Constant) -> any DigitsProvider = { FileDigitsProvider(constant: $0) }) {
        self.statsStore = statsStore
        self.persistence = persistence
        self.providerFactory = providerFactory
        
        // Initialize with the selected constant from store
        let constant = statsStore.selectedConstant
        let provider = providerFactory(constant)
        self.engine = PracticeEngine(provider: provider, persistence: persistence)
    }
    
    // MARK: - Public Methods
    
    /// Starts a new session with the selected mode
    func startSession() {
        // Always refresh the engine with the currently selected constant
        let constant = statsStore.selectedConstant
        var provider = providerFactory(constant)
        
        do {
            try provider.loadDigits()
            self.engine = PracticeEngine(provider: provider, persistence: persistence)
            engine.start(mode: selectedMode)
        } catch {
            print("Failed to start engine: \(error)")
            // Fallback to empty engine if load fails to prevent crash
            self.engine = PracticeEngine(provider: provider, persistence: persistence)
        }
        typedDigits = ""
        showErrorFlash = false
        lastCorrectDigit = nil
        expectedDigit = nil
        
        // Pre-warm the haptic engine
        HapticService.shared.prewarm()
    }
    
    /// Processes a digit input from the keypad
    /// - Parameter digit: The digit (0-9)
    func processInput(_ digit: Int) {
        objectWillChange.send()
        let result = engine.input(digit: digit)
        
        if result.isCorrect {
            // Success feedback
            lastCorrectDigit = digit
            expectedDigit = nil
            
            // Update displayed digits
            typedDigits.append(String(digit))
            
            // Light haptic for success (instant)
            HapticService.shared.playSuccess()
        } else {
            // Error feedback
            expectedDigit = result.expectedDigit
            HapticService.shared.playError()
            
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
        objectWillChange.send()
        engine.backspace()
        if !typedDigits.isEmpty {
            typedDigits.removeLast()
        }
    }
    
    /// Resets the current session
    func reset() {
        let constant = statsStore.selectedConstant
        let provider = providerFactory(constant)
        engine = PracticeEngine(provider: provider, persistence: persistence) // Re-initialize to clear all state
        typedDigits = ""
        showErrorFlash = false
        lastCorrectDigit = nil
        expectedDigit = nil
    }
    
    /// Ends the session and saves stats
    func endSession() {
        if engine.isActive {
            let record = SessionRecord(
                id: UUID(),
                date: Date(),
                constant: statsStore.selectedConstant,
                mode: selectedMode,
                attempts: engine.attempts,
                errors: engine.errors,
                bestStreakInSession: engine.bestStreak,
                durationSeconds: engine.elapsedTime,
                digitsPerMinute: engine.digitsPerMinute
            )
            statsStore.addSessionRecord(record)
            engine.reset()
            HapticService.shared.stop()
        }
    }
}
